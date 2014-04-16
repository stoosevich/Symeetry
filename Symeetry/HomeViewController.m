//
//  ViewController.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/14/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "HomeViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Parse/Parse.h>
#import "ProfileHeaderView.h"
#import "ParseManager.h"
#import "ProfileViewController.h"


//tring to fix 
#define ESTIMOTE_PROXIMITY_UUID             [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]

#define ESTIMOTE_MACBEACON_PROXIMITY_UUID   [[NSUUID alloc] initWithUUIDString:@"08D4A950-80F0-4D42-A14B-D53E063516E6"]

#define ESTIMOTE_IOSBEACON_PROXIMITY_UUID   [[NSUUID alloc] initWithUUIDString:@"8492E75F-4FD6-469D-B132-043FE94921D8"]

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate,CBPeripheralDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *homeTableView;

@property CLLocationManager* locationManager;
@property NSUUID* beaconId;
@property CLBeaconRegion* beaconRegion;

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

    self.users = [ParseManager getUsers];

    
    //set flags for requesting check-in to service and if checked-in to service
    self.didRequestCheckin = NO;
    self.didCheckin = NO;
    
    //intialize the location manager
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    //create the beacon to monitor for services
    
    //track ony the estimote beacon for the time being
    
    
    //self.beaconId = [[NSUUID alloc]initWithUUIDString:@"D943D5F6-7A2E-6CA4-0FB9-D766F5BD135A"];

    
    //initialze the beacon region with a UUID and indentifier
    self.beaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"com.Estimote"];

    
    //the location manager sends beacon notifications when the user turns on the display and the device is already inside the region. These notifications are sent even if your app is not running. In that situation
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    
    
    //assign the location manager to start monitoring the region
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    //turn on the monitoring manually, rather then waiting for us to enter a region
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
	
}


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


- (void)checkUserIntoSymeetry
{
    [self.locationManager startUpdatingLocation];
}


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
         [ParseManager addLocation:location forUser:[[PFUser currentUser] objectId] atBeacon:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
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
    cell.textLabel.text = user.username;
    cell.detailTextLabel.text = user.email;
    PFFile* file = [user objectForKey:@"photo"];
    NSData* data = [file getData];
    cell.imageView.image = [UIImage imageWithData:data]; 
    return cell;
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showProfileView"])
    {
        NSIndexPath *indexPath = [self.homeTableView indexPathForSelectedRow];
        ProfileViewController *viewController = segue.destinationViewController;
        viewController.user = self.users[indexPath.row];
    }
}

#pragma mark - CLLocationManager Delegate Methods

/*
 * tells the delegate that the user entered the specified region
 */
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Beacon found");
    
    if ([region.identifier isEqualToString:@"com.Symeetry.iBeacons"] && !self.didRequestCheckin)
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
    
    if ([region.identifier isEqualToString:@"com.Symeetry.iBeacons"])
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
    
    //NSLog(@"ranging beacons");
    
    UINavigationBar* navBar = self.navigationController.navigationBar;
    
    //create a beacon object
    CLBeacon* beacon = [[CLBeacon alloc]init];
    
    //get the last object our of the array of beacons
    beacon = beacons.lastObject;
    
    
    //change the background color and image of the view
    if (beacon.proximity == CLProximityImmediate)
    {
        //regarless of range, only check user in once
        if(!self.didRequestCheckin)
        {
            self.didRequestCheckin = !self.didRequestCheckin;
            //[self showSymeetryAlertScreen];
        }
        
        navBar.backgroundColor =[UIColor redColor];
//        NSLog(@"Beacon accurary %f", beacon.accuracy);
//        NSLog(@"Beacon accurary CLProximityImmediate");
    }
    else if (beacon.proximity == CLProximityNear)
    {
        //regarless of range, only check user in once
        if ( !self.didRequestCheckin)
        {
            self.didRequestCheckin = !self.didRequestCheckin;
            //[self showSymeetryAlertScreen];
        }
        
        navBar.backgroundColor = [UIColor blueColor];
//        NSLog(@"Beacon accurary CLProximityNear");
        
    }
    else if (beacon.proximity == CLProximityFar)
    {
        //regarless of range, only check user in once
        if(!self.didRequestCheckin)
        {
            self.didRequestCheckin = !self.didRequestCheckin;
            //[self showSymeetryAlertScreen];
        }
        navBar.backgroundColor = [UIColor orangeColor];
//        NSLog(@"Beacon accurary %f", beacon.accuracy);
//        NSLog(@"Beacon accurary CLProximityFar");
        
    }
    else if (beacon.proximity == CLRegionStateUnknown)
    {
        //navBar.backgroundColor = [UIColor grayColor];
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
        [self showRegionStateAlertScreen:@"region state: inside"];
        [self showSymeetryAlertScreen];
        
    }
    else if (state == CLRegionStateOutside && self.didCheckin)
    {
        //we are outside the region state being monitored
        [self showRegionStateAlertScreen:@"region state: outside"];
        [self showRegionStateAlertScreen:@"Leaving Symeetry region, loggin out of service"];
        
    }
    else if (state == CLRegionStateUnknown )
    {
        //we are in a unknow region state,
        [self showRegionStateAlertScreen:@"region state: unknown"];
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
}


@end
