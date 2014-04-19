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
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "ProfileHeaderView.h"
#import "ParseManager.h"
#import "ProfileViewController.h"
#import "Defaults.h"




@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate,CBPeripheralDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *homeTableView;
@property CLLocationManager* locationManager;
@property NSUUID* beaconId;
@property CLBeaconRegion* beaconRegion;
@property NSMutableDictionary* beacons;
@property NSMutableDictionary* rangedRegions;

//status related
@property BOOL didRequestCheckin;
@property BOOL didCheckin;

//local data source
@property NSArray* users;
@property NSArray* images;


@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadHeaderView];
    
    //ask the app delegate for the location manager
    AppDelegate* appDelegate =(AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.locationManager  = appDelegate.locationManager;
    self.locationManager.delegate = self;
    
    self. users = [ParseManager retrieveUsersInLocalVicinityWithSimilarity:nil];
    
    [self.homeTableView reloadData];
    
    //set flags for requesting check-in to service and if checked-in to service
    self.didRequestCheckin = NO;
    self.didCheckin = NO;
    
    [self createRegionsForMonitoring];

}


/*
 * Create one region for each known uuid and begin monitoring the regions for notifications
 */
- (void)createRegionsForMonitoring
{
    //create a dictionary of beacons
    self.beacons = [[NSMutableDictionary alloc] init];
    
    // Populate the regions we will range once
    self.rangedRegions = [[NSMutableDictionary alloc] init];
    
    //for all the "known" uuid, create a region to be monitored
    for (NSUUID *uuid in [Defaults sharedDefaults].supportedProximityUUIDs)
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        region.notifyEntryStateOnDisplay = YES;
        self.rangedRegions[region] = [NSArray array];
    }
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
    NSData* data = [file getData];
    headerView.imageView.image = [UIImage imageWithData:data];
    
    //add the new view to the array of subviews
    [self.view addSubview:headerView];
}


- (void)viewWillAppear:(BOOL)animated
{
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

- (void)checkUserIntoSymeetry
{
    [self.locationManager startUpdatingLocation];
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
    cell.detailTextLabel.text = @"likes and interests";
    PFFile* file = [user objectForKey:@"photo"];
    NSData* data = [file getData];
    cell.imageView.image = [UIImage imageWithData:data]; 
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

//TODO: We need to fix the beacon information being transmitted to Parse to be the beacon we are nearest
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    
    //get the date/time of the event
    NSDate* eventDate = location.timestamp;
    
    //determine how recent
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0)
    {
        //update parse with the information
        [ParseManager addPFGeoPointLocation];
        [ParseManager addLocation:location forUser:[[PFUser currentUser] objectId] atBeacon:self.beaconId];
    }
}

/*
 * tells the delegate that the user entered the specified region
 */
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Beacon found");
    
    if ([region.identifier isEqualToString:@"com.Symeetry.beacon"] && !self.didRequestCheckin)
    {
        UIAlertView *beaconAlert = [[UIAlertView alloc]initWithTitle:@"Symeetry Beacon Found" message:@"Check-in?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [beaconAlert show];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
        self.didRequestCheckin = !self.didRequestCheckin;
    }
}


/*
 * tells the delegate that the user exited a specified region
 */
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
    if ([region.identifier isEqualToString:@"ccom.Symeetry.beacon"])
    {
        NSLog(@"Left region");
        UIAlertView *beaconAlert = [[UIAlertView alloc]initWithTitle:@"Out of range of Symeetry Beacon" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [beaconAlert show];
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
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
    
    //we no longer need the beacons created so remove them
    [self.beacons removeAllObjects];
    
    //create an array of all know beacons
    NSMutableArray *allBeacons = [NSMutableArray array];
    
    //add all the beacon discovered by ranging into a new array
    for (NSArray *regionResult in [self.rangedRegions allValues])
    {
        [allBeacons addObjectsFromArray:regionResult];
    }
    
    //for each possible range value, find beacons mathcing the respective range, and add them to a new array,
    //this will put the beacons in the array from farthest to closest
    for (NSNumber *range in @[@(CLProximityUnknown), @(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)])
    {
        //create an array to hold the beacons orderd proximity
        NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
        
        //if there are beacons, update our list of beacons
        if([proximityBeacons count])
        {
            self.beacons[range] = proximityBeacons;
            [self updateNavigationBarColorBasedOnProximity:proximityBeacons.firstObject];
            NSLog(@"neartest beacon %@\n", proximityBeacons.lastObject);
        }
    }

}


/*
 * The location manager calls this method whenever there is a boundary transition for a region.
 * The location manager also calls this method in response to a call to its requestStateForRegion: method, 
 * which runs asynchronously
 */
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside && !self.didRequestCheckin)
    {
        //we are inside the region being monitored
        //[self showRegionStateAlertScreen:@"region state: inside"];
        [self showSymeetryAlertScreen];
        
    }
    else if (state == CLRegionStateOutside && self.didCheckin)
    {
        //we are outside the region state being monitored
        //[self showRegionStateAlertScreen:@"region state: outside"];
        [self showRegionStateAlertScreen:@"Leaving Symeetry region, loggin out of service"];
        
    }
    else if (state == CLRegionStateUnknown )
    {
        //we are in a unknow region state,
        //[self showRegionStateAlertScreen:@"region state: unknown"];
    }
}


/*
 * work around to start ranging the beacons without having to enter a region. This is for testing
 * purposes only
 */
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}



/*
 *
 */
- (void)updateNavigationBarColorBasedOnProximity:(CLBeacon*)beacon
{
    NSLog(@"beacon responsible for color %@\n", beacon);
    
    UINavigationBar* navBar = self.navigationController.navigationBar;
    
    //change the background color and image of the view
    if (beacon.proximity == CLProximityImmediate)
    {
        NSLog(@"immed %d", beacon.proximity);
        //regarless of range, only check user in once
        if(!self.didRequestCheckin)
        {
            self.didRequestCheckin = !self.didRequestCheckin;
        }
        
        navBar.backgroundColor =[UIColor redColor];
    }
    else if (beacon.proximity == CLProximityNear)
    {
        NSLog(@"near %d", beacon.proximity);
        //regarless of range, only check user in once
        if ( !self.didRequestCheckin)
        {
            self.didRequestCheckin = !self.didRequestCheckin;
        }
        
        navBar.backgroundColor = [UIColor blueColor];
        
    }
    else if (beacon.proximity == CLProximityFar)
    {
        NSLog(@"far %d", beacon.proximity);
        //regarless of range, only check user in once
        if(!self.didRequestCheckin)
        {
            self.didRequestCheckin = !self.didRequestCheckin;
        }
        
        
        navBar.backgroundColor = [UIColor greenColor];
        
    }
    else if (beacon.proximity == CLProximityUnknown)
    {
        NSLog(@"unknown %d", beacon.proximity);
    }

}


#pragma mark -  UIAlertViewDelegate Methods

/*
 * Show an alert view when the user enters a region where Symeetry is actively being broadcast
 */
- (void)showSymeetryAlertScreen
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"iBeacon Present" message:@"Check-in?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Check-in", nil];
    
    [alertView show];
}


- (void)showRegionStateAlertScreen:(NSString*)state
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Region State Alert" message:state delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        self.didCheckin = YES;
        [self checkUserIntoSymeetry];
        NSLog(@"did checkin");
    }
    else if (buttonIndex ==0)
    {
        
    }
}

- (IBAction)logoutButton:(UIBarButtonItem *)sender
{
    [PFUser logOut];
    PFUser *currentUser = [PFUser currentUser];
    NSLog(@"%@",currentUser);
}

@end
