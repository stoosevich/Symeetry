//
//  ViewController.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/14/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Parse/Parse.h>
#import "HomeViewController.h"
#import "ProfileHeaderView.h"
#import "ParseManager.h"
#import "ProfileViewController.h"
#import "Defaults.h"


@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIAlertViewDelegate>

@property CLLocationManager* locationManager;
@property NSMutableDictionary* beacons;
@property NSMutableDictionary* rangedRegions;


//status related
@property BOOL didRequestCheckin;
@property (nonatomic, getter=isCheckedIn) BOOL checkedIn;

//local data source
@property NSArray* users;
@property NSArray* images;


@end

@implementation HomeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadHeaderView];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    //begin creating regions for monitoring
    self.activeRegions = [NSMutableArray new];
    [self createRegionsForMonitoring];
    
    //set flags for requesting check-in to service and if checked-in to service
    self.didRequestCheckin = NO;
    self.checkedIn = NO;
    
    [self getUsers];

}


//method in the calling object to pass block with weak reference
- (void)getUsers
{
    //Create a weak reference to pass into the block
    __weak HomeViewController *weakSelf = self;
    
    [ParseManager getUsersWithCompletion:^(NSArray *objects, NSError *error)
    {
        //[weakSelf doStuffWithUsers:objects];
        weakSelf.users = objects;
        [weakSelf.homeTableView reloadData];
        
    }];
    
}

//method in the calling object to deal with the results of the block
- (void)doStuffWithUsers:(NSArray*)results
{
    self.users = results;
    [self.homeTableView reloadData];
}



/*
 * Load the custom view used for the users profile
 */
- (void)loadHeaderView
{
    //create the view from a xib file
    ProfileHeaderView *headerView =  [ProfileHeaderView newViewFromNib:@"ProfileHeaderView"];
    
    //quick hack to make the view appear in the correct location
    CGRect frame = CGRectMake(0.0, 60.0f, headerView.frame.size.width, headerView.frame.size.height);

    //set the frame
    headerView.frame = frame;
    
    //update the profile header details
    headerView.nameTextField.text = [[PFUser currentUser]username];
    NSNumber* age  = [[PFUser currentUser]objectForKey:@"age"];
    
    headerView.ageTextField.text = age.description;
    headerView.genderTextField.text = [[PFUser currentUser]objectForKey:@"gender"];
    
    //convert the file to a UIImage
    PFFile* file = [[PFUser currentUser]objectForKey:@"photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
    {
        if (!error)
        {
            headerView.imageView.image = [UIImage imageWithData:data];
            
        }
        else
        {
            //do something, like load a default image
        }
    }];
    
    //add the new view to the array of subviews
    [self.view addSubview:headerView];
}


- (void)viewWillAppear:(BOOL)animated
{
    
    //register for notifications from the app delegate about region entry/exit
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRegionBoundaryNotification:)
                                                 name:@"CLRegionStateInsideNotification" object:nil];
    // Start ranging when the view appears.
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    // Stop ranging when the view appears.
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
        
        //initialize the dictionary for ranged regions with an empty array. Each region array will contain the ibeacons
        //ranged for that region.
        self.rangedRegions[region] = [NSArray array];
        
        //
        [self.locationManager startMonitoringForRegion:region];

        //NSLog(@"region uuid %@",region.proximityUUID);

    }
}

/*
 * This method is called the first time a user encounters a region which is being monitored.
 * The location manager updates are started, along with the beacon monitoring for all known regions
 * @param void
 * @return void
 */
- (void)checkUserIntoSymeetry
{

    //if the user has not checked in
    if (!self.isCheckedIn )
    {
        // start ranging beacons when the user checksin
        for (CLBeaconRegion *region in self.rangedRegions)
        {
            [self.locationManager startRangingBeaconsInRegion:region];
        }
        
        //whenever a user checks in, update their location
        [ParseManager setUsersPFGeoPointLocation];
        
        //find users near the current user
        [self retrieveUsersInLocalVicinityWithSimilarity:self.activeRegions];
        
        self.checkedIn = YES;
    }

    NSLog(@"checkUserIntoSymeetry: active regions %@",self.activeRegions);
}


/*
 * Handle notifications from the App Delegate about entry and exit of
 * regions
 */
- (void)handleRegionBoundaryNotification:(NSNotification*)notification
{
    //if the region entered is new, add it to the active regions
    NSString* uuidString = [[notification userInfo] objectForKey:@"identifier"];
    NSString* state = [[notification userInfo] objectForKey:@"state"];
    
    //check if we enterd a new region
    if ([state isEqualToString:@"CLRegionStateInside"])
    {
        
        //if the user is not checked in and the region is "new"
        if (!self.isCheckedIn && ![self.activeRegions containsObject:uuidString])
        {
            [self.activeRegions addObject:uuidString];
            [self showSymeetryCheckinScreen];
        }
        //if the user is already checked in, just add the region and update the users
        else if (self.checkedIn && ![self.activeRegions containsObject:uuidString])
        {
            [self.activeRegions addObject:uuidString];
            [self retrieveUsersInLocalVicinityWithSimilarity:self.activeRegions];
            [self.homeTableView reloadData];
            //whenever a user enters a new region, update their location
            [ParseManager setUsersPFGeoPointLocation];
        }
    }
    else if ([state isEqualToString:@"CLRegionStateOutside"])
    {
        //do something when we leave a region
        [self.activeRegions removeObject:uuidString];
        [self retrieveUsersInLocalVicinityWithSimilarity:self.activeRegions];
        [self.homeTableView reloadData];
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
    NSString* formatString = [NSString stringWithFormat:@"%@ %@",user.username,[user[@"similarityIndex"] description]];
    cell.textLabel.text = formatString;
    
    CLBeacon *beacon = [self retrieveNearestBeaconFromBeaconDictionary];
    NSString *beaconFormatString = NSLocalizedString(@"Major: %@, Minor: %@, Acc: %.2fm", @"Format string for ranging table cells.");
    cell.detailTextLabel.text = [NSString stringWithFormat:beaconFormatString, beacon.major, beacon.minor, beacon.accuracy];
    
    //cell.detailTextLabel.text = @"likes and interests";
    PFFile* file = [user objectForKey:@"photo"];
    
    //load the image asynchronously
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
    {
        cell.imageView.image = [UIImage imageWithData:data];
    }];
    
    return cell;
    
}

#pragma mark - Prepare for Segue Method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showProfileView"])
    {
        NSIndexPath *indexPath = [self.homeTableView indexPathForSelectedRow];
        ProfileViewController *viewController = segue.destinationViewController;
        viewController.user = self.users[indexPath.row];
    }
    else if ([[segue identifier] isEqualToString:@"showMapView"])
    {
        
    }
}

#pragma mark - CLLocationManager Delegate Methods


/*
 * tells the delegate that the user entered the specified region
 */
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Entering region %@", region.identifier);
    
    //if the users has not already checked in, confirm they want to checkin, otherwise
    //just add the region to the list of active regions, and update the list of available users
    if (!self.isCheckedIn)
    {
        [self showSymeetryCheckinScreen];
    }
    else if (self.checkedIn && self.activeRegions.count >0)
    {
        //if the user is already checkedin, then add the new region entered
        //and update the list of user available
        [self.activeRegions addObject:region.identifier];
        [self retrieveUsersInLocalVicinityWithSimilarity:self.activeRegions];
        [self.homeTableView reloadData];
        
        //whenever a user enters a new region, update their location
        [ParseManager setUsersPFGeoPointLocation];
    }
}


/*
 * tells the delegate that the user exited a specified region
 */
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
    //stop ranging beacons for region exited
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
    
    [ParseManager setUsersPFGeoPointLocation];
    [self.activeRegions removeObject:region.identifier];
    
    NSString* formatString = [NSString stringWithFormat:@"region\n%@",region.identifier];
    UIAlertView *beaconAlert = [[UIAlertView alloc]initWithTitle:@"Leaving region" message:formatString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [beaconAlert show];
    
    //update the list of available users
    [self retrieveUsersInLocalVicinityWithSimilarity:self.activeRegions];
    [self.homeTableView reloadData];
}


/*
 *  tells the delegate that one or more beacons are in range. acquires the data of the available beacons and transforms that data in whatever form the user wants.
 */
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    
    /*
     Per Apple -  CoreLocation will call this delegate method at 1 Hz with updated range information.
     Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
     regions.  It will be displayed multiple times if that is the case.  If that is not desired,
     use a set instead of an array.
     */
    
    //set the property rangedRegions to the beacons which CoreLocation reported to us
    self.rangedRegions[region] = beacons;
    
    //we will update the beacons dictionary with each ranging call
    [self.beacons removeAllObjects];
    
    //create an array of all know beacons
    NSMutableArray *allBeacons = [NSMutableArray array];
    
    //add all the beacons discovered by ranging into a new array
    for (NSArray *regionResult in [self.rangedRegions allValues])
    {
        [allBeacons addObjectsFromArray:regionResult];
    }
    
    //for each possible range value, find beacons matching the respective range, and add them to a new array,
    //this will put the beacons in the array from nearest to farthest
    for (NSNumber *range in @[@(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar),@(CLProximityUnknown)])
    {
        //create an array to hold the beacons orderd proximity
        NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
        
        //if there are beacons, update our list of beacons
        if([proximityBeacons count])
        {
            
            //store the beacons by proximity in the dictionary. The dictionary will hold an arrays
            //of beacons by their proximity
            self.beacons[range] = proximityBeacons;
            
            //change the color of the navbar based on the closest beacon
            [self updateNavigationBarColorBasedOnProximity:proximityBeacons.firstObject];

            //update the user with the beacon they are nearest too
            [ParseManager updateUserNearestBeacon:((CLBeacon*)proximityBeacons.firstObject).proximityUUID
             ];
        }
    }
    
    [self.homeTableView reloadData];
}



/*
 * The location manager calls this method whenever there is a boundary transition for a region.
 * The location manager also calls this method in response to a call to its requestStateForRegion: method, 
 * which runs asynchronously
 */
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
//    //we are inside the region being monitored
//    if (state == CLRegionStateInside)
//    {
//        //add the region to the list of active regions to query
//        [self.activeRegions addObject:region.identifier];
//        
//    }
//    else if (state == CLRegionStateOutside)
//    {
//        //we are outside the region state being monitored
//        [self.activeRegions removeObject:region.identifier];
//    }
//    else if (state == CLRegionStateUnknown )
//    {
//        //we are in a unknow region state
//    }
}

#pragma mark - SymeetryApplicaitonHelperMethods

/*
 * Change the
 * @param CLBeacon the nearest beacon to the current user
 * @return void
 */
- (void)updateNavigationBarColorBasedOnProximity:(CLBeacon*)beacon
{
    UINavigationBar* navBar = self.navigationController.navigationBar;
    
    //change the background color and image of the view
    if (beacon.proximity == CLProximityImmediate)
    {
        //NSLog(@"immed %ld", beacon.proximity);
        navBar.backgroundColor =[UIColor redColor];
    }
    else if (beacon.proximity == CLProximityNear)
    {
        //NSLog(@"near %ld", beacon.proximity);
        navBar.backgroundColor = [UIColor blueColor];
        
    }
    else if (beacon.proximity == CLProximityFar)
    {
        //NSLog(@"far %ld", beacon.proximity);
        navBar.backgroundColor = [UIColor greenColor];
    }
    else if (beacon.proximity == CLProximityUnknown)
    {
        //NSLog(@"unknown %ld", beacon.proximity);
        navBar.backgroundColor = [UIColor clearColor];
    }

}


/*
 * Temporary method to display beacon data in the table view
 */
- (CLBeacon*)retrieveNearestBeaconFromBeaconDictionary
{
    
    CLBeacon* nearestBeacon = nil;

    //beacons are stored by the number key value
    
    if ( self.beacons[@1] )
    {
        nearestBeacon = [self.beacons[@1] firstObject];
    }
    else if ( self.beacons[@2] )
    {
        nearestBeacon = [self.beacons[@2] firstObject];
    }
    else if ( self.beacons[@3] )
    {
         nearestBeacon = [self.beacons[@3] firstObject];
    }
    
    return nearestBeacon;
}

#pragma mark -  UIAlertViewDelegate Methods

/*
 * Show an alert view when the user enters a region where Symeetry is actively being broadcast
 */
- (void)showSymeetryCheckinScreen
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"iBeacon Region Discovered" message:@"Check-in" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Check-in", nil];
    
    [alertView show];
}


- (void)showRegionStateAlertScreen:(NSString*)state
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Region State Alert" message:state delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:@"Check-in"] && buttonIndex == 1)
    {
        [self checkUserIntoSymeetry];
        NSLog(@"did checkin");
    }
    else if ([alertView.message isEqualToString:@"Check-in"] && buttonIndex == 0)
    {
        self.didRequestCheckin = !self.didRequestCheckin;
    }
    else if (buttonIndex ==0)
    {
        
    }
}

//temporary method to handle user logot
- (IBAction)logoutButton:(UIBarButtonItem *)sender
{
    [PFUser logOut];
    PFUser *currentUser = [PFUser currentUser];
    NSLog(@"%@",currentUser);
}




/*
 * This method retrieves all users in the current vicinity, based on the beacon uuid
 * and assigns each user a similarity index based on the similarity to the current user.
 * the results are sorted by the user similarity index and/or by user name.
 * @ return NSArray
 */
- (void)retrieveUsersInLocalVicinityWithSimilarity:(NSArray*)uuid
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
        for (NSDictionary* item in currUser)
        {
            if([currUser objectForKey:item] == [otherUser objectForKey:item])
            {
                similarity++;
            }
        }
        return similarity;
    };
    
    
    
    /*
     * Block to update the similarity index of a user based on comparision
     * to the current user. This blocks loops through an array of users and
     * call another block to calculate the actual similarity index between the
     * two users
     */
    void (^updateUserSimilarity)(NSArray*) = ^(NSArray* userObjects)
    {
        
        NSDictionary* currentUser = [ParseManager getInterest:[PFUser currentUser]];
        NSDictionary* otherUser = nil;
        
        for(PFObject* user in userObjects)
        {
            //get the interest for each user in the list of objects returned from the search
            otherUser = [ParseManager convertPFObjectToNSDictionary:user[@"interests"]];
            
            //only calculate the similarity if there other user has intersts
            if(otherUser)
            {
                //call a block function to calculate the similarity of the two users
                user[@"similarityIndex"] = [NSNumber numberWithInt:similarityCalculation(currentUser,otherUser)];
                //NSLog(@"similarityIndex %@",user[@"similarityIndex"]);
            }
        }
        
    };

    PFQuery* query = [PFUser query];
    
    //exclude the current user
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [query whereKey:@"nearestBeacon" containedIn:uuid];
    
    
    //include the actual interest objecst not just a link
    [query includeKey:@"interests"];
    
    //sort by by user name, this will be resorted once the similarity index is assigned
    [query addAscendingOrder:@"username"];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        
        updateUserSimilarity(objects);
        
        
        //sort the objects once the similarity index is updated
        NSArray *sortedArray;
        
        //sort the array using a block comparator
        sortedArray = [objects sortedArrayUsingComparator:^NSComparisonResult(id user1, id user2)
                       {
                           //covert each object to a PFObject and retrieve the similarity index
                           NSNumber *first =  ((PFObject*)user1)[@"similarityIndex"];
                           NSNumber *second = ((PFObject*) user2)[@"similarityIndex"];
                           return [second compare:first];
                       }];
        
        self.users = sortedArray;
        [self.homeTableView reloadData];

    }];

}


@end
