//
//  ViewController.m
//  Symeetry
//
//  Copyright (c) 2014 Symeetry Team. All rights reserved.
//


#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Parse/Parse.h>
#import "AvailableUsersViewController.h"
#import "ParseManager.h"
#import "ProfileHeaderView.h"
#import "ProfileViewController.h"
#import "Defaults.h"
#import "MapViewController.h"
#import "PresentAnimationController.h"
#import "InterestsViewController.h"
#import "ChatManager.h"
#import "Utilities.h"
#import "UIView+Circlify.h"



//define a block for the call back
typedef void (^MyCompletion)(NSArray *objects, NSError *error);

@interface AvailableUsersViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIAlertViewDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

@property PresentAnimationController* presentAnimationController;

@property CLLocationManager* locationManager;
@property NSMutableDictionary* beacons;
@property NSMutableDictionary* rangedRegions;


//status related
@property BOOL didRequestCheckin;
@property (nonatomic, getter=isCheckedIn) BOOL checkedIn;

//local data source
@property NSArray* users;


@end

@implementation AvailableUsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize the location manager for ibeacon scanning
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;

    //initialize required data structures
    self.beacons = [NSMutableDictionary new];
    self.activeRegions = [NSMutableArray new];
    
    //create the regions to monitor
    [self createRegionsForMonitoring];
    
    //set flags for requesting check-in to YES, user can opt-out in settings
    self.checkedIn = YES;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.availableUsersTableView addSubview:refreshControl];

}


- (void)viewWillAppear:(BOOL)animated
{
    
    //register for notifications from the app delegate about region entry/exit
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRegionBoundaryNotification:)
                                                 name:@"CLRegionStateInsideNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"refreshView" object:nil];
    
    //assume there are no near beacons
    self.nearestBeacon = nil;
    
    // Start ranging when the view appears
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager startRangingBeaconsInRegion:region];
    }
    
    if (self.activeRegions.count)
    {
        [ParseManager setUsersPFGeoPointLocation];
        [self getUserWithSimlarityRank];
    }
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    
    // Stop ranging when the view disappears
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//allow user to refresh list as desired
- (void)refresh:(UIRefreshControl *)refreshControl
{
    [self getUserWithSimlarityRank];
    [refreshControl endRefreshing];
}


//respond to notification that we have entered the foreground
//after being in the background
-(void)refreshView:(NSNotification *) notification
{
    [self viewWillAppear:YES];
}


#pragma mark - Beacon Helper Methods

/*
 * Create one region for each known uuid and begin monitoring the regions for notifications
 */
- (void)createRegionsForMonitoring
{
    // Populate the regions we will range once
    self.rangedRegions = [[NSMutableDictionary alloc] init];
    
    //create a region for all the "known" uuids
    for (NSUUID *uuid in [Defaults sharedDefaults].supportedProximityUUIDs)
    {
        /*
         *proximity UUID -  The unique ID of the beacons being targeted, this must not be nil
         *identifier -  A unique identifier to associate with the returned region object. This 
         *identifier is used to differentiate regions within your application
         */
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        
        //set the entry state on display to receive notifications
        region.notifyEntryStateOnDisplay = YES;
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        
        //initialize the dictionary for ranged regions with an empty array. Each region array will contain the ibeacons ranged for that region.
        self.rangedRegions[region] = [NSArray array];
 
        //start monitoring all known regions
        [self.locationManager startMonitoringForRegion:region];
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}



/*
 * Handle notifications from the App Delegate about entry and exit of
 * regions. Each time an new entry/exit is detected we add or remove
 * the region UUID, update the list of avialable users and update the user's
 * location
 */
- (void)handleRegionBoundaryNotification:(NSNotification*)notification
{
    //if the region entered is new, add it to the active regions
    NSString* stringUUID = [[notification userInfo] objectForKey:@"identifier"];
    NSUUID* uuid = [[NSUUID alloc]initWithUUIDString:stringUUID];
    NSString* state = [[notification userInfo] objectForKey:@"state"];
    
    //create a temporary region since we cannot pass the region object in the notification user info
    CLBeaconRegion* region = [[CLBeaconRegion alloc]initWithProximityUUID:uuid identifier:[uuid UUIDString]];

    
    //make sure the region is not empty first
    if(region)
    {
        //check if we enterd a new region
        if ([state isEqualToString:@"CLRegionStateInside"])
        {
            //NSString* formatString = [NSString stringWithFormat:@"App exited region:%@",region.identifier];
            //[self showRegionStateAlertScreen:formatString];
            
            //if we are notified that we entered a new region, add it to the active list
            if (![self.activeRegions containsObject:region])
            {
                [self.activeRegions addObject:region];
            }
        }
        else if ([state isEqualToString:@"CLRegionStateOutside"])
        {
            //NSString* formatString = [NSString stringWithFormat:@"App exited region:%@",region.identifier];
            //[self showRegionStateAlertScreen:formatString];
            
            //if we are notified that we left a region
            [self.activeRegions removeObject:region];
        }
        
        [self getUserWithSimlarityRank];
        
        //whenever a user enters a new region, update their location
        [ParseManager setUsersPFGeoPointLocation];
    }
}


#pragma mark - UITableViewDelegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    PFUser* user = self.users[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeReuseCellID"];
    int x = [user[@"similarityIndex"]intValue];
    NSString* formatString = [NSString stringWithFormat:@"%@ %d",user.username,((x*100)/60)];
    
    cell.textLabel.text = formatString;
    cell.detailTextLabel.text = user[@"biography"];
    

    PFFile* file = [user objectForKey:@"thumbnail"];
    
    //load the image asynchronously
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            
            [cell.imageView circlify];
            NSNumber* index = (NSNumber*)user[@"similarityIndex"];
            [cell.imageView.layer setBorderColor:[Utilities colorBasedOnSimilarity:[index intValue]]];
             cell.imageView.image = [UIImage imageWithData:data];
        });
       
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get the users from the list
    PFUser* user = self.users[indexPath.row];
    
    //call the delegate's method to display the profile
    [self.delegate displayUserProfile:user];
}

#pragma mark - Prepare for Segue Method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showProfileDetail"])
    {
        NSIndexPath *indexPath = [self.availableUsersTableView indexPathForSelectedRow];
        ProfileViewController* viewController = segue.destinationViewController;
        viewController.user = self.users[indexPath.row];
        viewController.transitioningDelegate = self;
    }

}

#pragma mark - CLLocationManager Delegate Methods


/*
 * tells the delegate that the user entered the specified region
 */
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if (![self.activeRegions containsObject:region])
    {
        //if the user is already checkedin, then add the new region entered
        //and update the list of user available
        [self.activeRegions addObject:region];
        [self getUserWithSimlarityRank];
 
        //whenever a user enters a new region, update their location
        [ParseManager setUsersPFGeoPointLocation];
    }
}


/*
 * tells the delegate that the user exited a specified region
 */
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{

    if ([self.activeRegions containsObject:region])
    {
        [ParseManager setUsersPFGeoPointLocation];
        [self.activeRegions removeObject:region];
        
        //if there are no active regions left set the nearest beacon to nil
        if (self.activeRegions == nil)
        {
            self.nearestBeacon = nil;
            [ParseManager updateUserNearestBeacon:self.nearestBeacon];
        }
        
        //update the list of available
        [self getUserWithSimlarityRank];
    }
}


/*
 *  tells the delegate that one or more beacons are in range. acquires the data of the available beacons and transforms that data in whatever form the user wants.
 */
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    
    
    //if the region is not part of the active list, add it
    if (![self.activeRegions containsObject:region] && beacons.count)
    {
        [self.activeRegions addObject:region];
        [self getUserWithSimlarityRank];
    }
    else if (self.activeRegions.count == 0 && self.nearestBeacon != nil)
    {
        self.nearestBeacon = nil;
        [ParseManager updateUserNearestBeacon:self.nearestBeacon];
        [self getUserWithSimlarityRank];
    }
    
    
    /*
     Per Apple -  CoreLocation will call this delegate method at 1 Hz with updated range information.
     Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
     regions.  It will be displayed multiple times if that is the case.  If that is not desired,
     use a set instead of an array.
     */
    
    //update the dictionary for ranged regions with the array of beacons which the location manager reported to us for the processed region
    self.rangedRegions[region] = beacons;
    
    //clear the entries currently in the beacons dictionary
    [self.beacons removeAllObjects];
    
    //create an array to hold beacons currently in the rangedRegions dictionary
    NSMutableArray *allBeacons = [NSMutableArray array];
    
    //copy all the beacons in the ranged region dictionary into the new array
    for (NSArray *regionResult in [self.rangedRegions allValues])
    {
        [allBeacons addObjectsFromArray:regionResult];
    }
    
    //for each possible range value (0,1,2,3), find beacons matching the respective range, and add them to a new array, this will put the beacons in numeric order of proximity
    for (NSNumber *range in @[ @(CLProximityUnknown), @(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)])
    {
        //create an array to hold the beacons orderd proximity
        NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
        
        //if there are beacons, update our list of beacons
        if(proximityBeacons.count)
        {
            //store the beacons by proximity for each range in the beacon dictionary.
            //The dictionary holds an array of beacons by their proximity
            self.beacons[range] = proximityBeacons;
            [self determineNearestBeaconToUser];
        }
    }
}



- (void)determineNearestBeaconToUser
{

    if( self.beacons.count > 0)
    {
        
        CLBeacon* currentBeacon = nil;
        NSArray* beacons = nil;
        
        if (self.beacons[@(CLProximityImmediate)])
        {
            beacons = self.beacons[@(CLProximityImmediate)];
            currentBeacon = beacons.firstObject;
        }
        else if (self.beacons[@(CLProximityNear)])
        {
            beacons = self.beacons[@(CLProximityNear)];
            currentBeacon = beacons.firstObject;
        }
        else if (self.beacons[@(CLProximityFar)])
        {
            beacons = self.beacons[@(CLProximityFar)];
            currentBeacon = beacons.firstObject;
        }
        else if (self.beacons[@(CLProximityUnknown)])
        {
            beacons = self.beacons[@(CLProximityUnknown)];
            currentBeacon = beacons.firstObject;
        }

        
        //if we found at least on beacon in our ranging of regions
        if (currentBeacon)
        {
            /*
              only update if we are actually closer to a different beacon.
            beacons in close proximit (i.e. next to each other) maybe treated as a
            simgle beacon. Since beacon CLProximityUnknown = 0, we exclude this from 
             consideration as the nearest beacon
             */
            
            //if we have not set a nearest beacon yet, then set this as the nearest
            if (self.nearestBeacon == nil)
            {
                self.nearestBeacon = currentBeacon;
                [ParseManager updateUserNearestBeacon:self.nearestBeacon];
            }
            
            //otherwise check if the beacon is is actually closer
            else if ( (currentBeacon.proximity < self.nearestBeacon.proximity) &&
                 currentBeacon.proximity != CLProximityUnknown)
            {
                
                self.nearestBeacon =  currentBeacon;
                [ParseManager updateUserNearestBeacon:self.nearestBeacon];
            }

        }
    }
}

#pragma mark - SymeetryApplicaitonHelperMethods

/*
 * Change the Navigation bar color based on proximity to beacon
 * @param CLBeacon the nearest beacon to the current user
 * @return void
 */
//- (void)updateNavigationBarColorBasedOnProximity:(CLBeacon*)beacon
//{
//    UINavigationBar* navBar = self.navigationController.navigationBar;
//    
//    //change the background color and image of the view
//    if (beacon.proximity == CLProximityImmediate)
//    {
//        navBar.backgroundColor =[UIColor redColor];
//    }
//    else if (beacon.proximity == CLProximityNear)
//    {
//        navBar.backgroundColor = [UIColor blueColor];
//    }
//    else if (beacon.proximity == CLProximityFar)
//    {
//        navBar.backgroundColor = [UIColor greenColor];
//    }
//    else if (beacon.proximity == CLProximityUnknown)
//    {
//        navBar.backgroundColor = [UIColor clearColor];
//    }
//
//}


#pragma mark -  UIAlertViewDelegate Methods


- (void)showRegionStateAlertScreen:(NSString*)state
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Region State Alert" message:state delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
}
#pragma mark - CustomSimilarityRanking Methods

/*
 *
 *@return void
 */
- (void)getUserWithSimlarityRank
{

    [self getCurrentUserInterestWithCompletion:^(PFObject *object, NSError *error)
     {
         if(object)
         {
             NSDictionary* currentUserInterests = [ParseManager convertPFObjectToNSDictionary:object[@"interests"]];
             [self calculateSimilarity:currentUserInterests];
         }
     }];
}


/*
 *@param NSDictionary
 *@return void
 */
- (void)calculateSimilarity:(NSDictionary*)currentUserInterests
{
    [self calculateSimilarity:currentUserInterests forRegions:self.activeRegions withCompletion:^(NSArray *objects, NSError *error)
    {
        NSDictionary* otherUserInterests = nil;

        //loop through the list of users return for the regions with beacons
        for(PFObject* user in objects)
        {
                        
            //get the interest for each user in the list of objects returned from the search
            otherUserInterests = [ParseManager convertPFObjectToNSDictionary:user[@"interests"]];
            
            //only calculate the similarity if there other user has intersts
            if(otherUserInterests)
            {
                
                /*
                 * Block to calculate the similarity between two different users. This block
                 * compares the values between two differnet NSDictionary objects, and for every
                 * pair of values that are the same, the similarity index is increased by 1
                 */
                int (^similarityCalculation)(NSDictionary*, NSDictionary*) = ^(NSDictionary* currUser, NSDictionary* otherUser)
                {
                    int similarity = 0;
                    
                    //loop throught the current user's dictionary of interests and compare
                    //each value to the other user. For each match increase the count by 1
                    int count = 0;
                    for (NSDictionary* item in currUser)
                    {
                        count++;
                        if (![item isEqual:@"userid"] && ![item isEqual:@"user"])
                        {
                            //both users need to have interest presents to avoid nil objects, and we
                            //need to skip the user Id in the dictionary object
                            if([currUser objectForKey:item] != nil && [otherUser objectForKey:item] != nil
                               )
                            {
                                int currentUserCategoryValue = [[currUser objectForKey:item] intValue];
                                int otherUserCategoryValue = [[otherUser objectForKey:item] intValue];
                                
                                int categoryValue  = abs( abs(currentUserCategoryValue - otherUserCategoryValue) - 5);
                                similarity += categoryValue;
                            }
                        }

                    }
                    return similarity;
                };
                
                //call a block function to calculate the similarity of the two user
                user[@"similarityIndex"] = [NSNumber numberWithInt:similarityCalculation(currentUserInterests,otherUserInterests)];
            }
        }
       
        self.users = [objects sortedArrayUsingComparator:^NSComparisonResult(id user1, id user2)
                      {
                          //covert each object to a PFObject and retrieve the similarity index
                          NSNumber *first =  ((PFObject*) user1)[@"similarityIndex"];
                          NSNumber *second = ((PFObject*) user2)[@"similarityIndex"];
                          return [second compare:first];
                      }];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.availableUsersTableView reloadData];
        });
        
    }];
    
}


//get the list of user by region asyncronously from parse
- (void)calculateSimilarity:(NSDictionary*)interest forRegions:(NSArray*)regions withCompletion:(MyCompletion)completion
{

    if (regions.count)//if there are no regions, then stop
    {
        [ParseManager retrieveUsersInLocalVicinityWithSimilarity:regions WithComplettion:^(NSArray *objects, NSError *error)
         {
             completion(objects,error);
             
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 [self.availableUsersTableView reloadData];
//                 
//             });
         }];
    }
}



- (void)getCurrentUserInterestWithCompletion:(InterestCompletion)completion
{
    [ParseManager getUserInterest:[PFUser currentUser] WithCompletion:^(PFObject *object, NSError *error)
     {
         completion(object,error);
     }];
    
}


#pragma mark - ApplicationServicesRelated Method

/*
 * Validate all required services are active and notify user via AlertView if they are
 * not active.
 */
-(void)validateApplicationServicesFunctionalityIsEnabled
{
    //check background refesh is avaiable, otherwise notifications will not be recieved
    if([[UIApplication sharedApplication]backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable)
    {
        [self notifyUserBackgroundRefeshIsDisabled:[[UIApplication sharedApplication]backgroundRefreshStatus]];
    }
    
    //check location services are enabled
    if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
    {
        [self notifyUserLocationServicesAreDisabled:[CLLocationManager authorizationStatus]];
    }
}

/*
 * Check the corelocation manager to ensure location services are active
 */
- (void)notifyUserLocationServicesAreDisabled:(NSUInteger)status
{
    if (status == kCLAuthorizationStatusRestricted )
    {
        [self showApplicationServicesAlertView:@"Location services are restricted"];
    }
    else if (status == kCLAuthorizationStatusDenied)
    {
        [self showApplicationServicesAlertView:@"Location services are disabled, please enable in Settings"];
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        [self showApplicationServicesAlertView:@"Location services error, please try again later"];
    }
}

/*
 * If the background refresh service is not active the user will notifications
 * about beacons when the app is not active
 */
- (void)notifyUserBackgroundRefeshIsDisabled:(NSUInteger)status
{
    if (status == UIBackgroundRefreshStatusDenied)
    {
        [self showApplicationServicesAlertView:@"Background resresh disabled, please enable in Settings"];
    }
    else if (status == UIBackgroundRefreshStatusRestricted)
    {
        [self showApplicationServicesAlertView:@"Background refesh is restricted"];
    }
    
}

- (void)showApplicationServicesAlertView:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Required Application Service Disabled" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
}


@end
