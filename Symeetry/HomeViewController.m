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


@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *homeTableView;

@property CLLocationManager* locationManager;
@property NSUUID* beaconId;
@property CLBeaconRegion* beaconRegion;

///bluetooth related
@property CBCentralManager* centralManager;
@property NSMutableArray *beacons;

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
    self.users = @[@"dennis",@"steve",@"charles"];
    
    self.images = @[[UIImage imageNamed:@"dennis.jpg"],[UIImage imageNamed:@"steve.jpg"], [UIImage imageNamed:@"charles.jpg"]];
    
    //set flags for requesting check-in to service and if checked-in to service
    self.didRequestCheckin = NO;
    self.didCheckin = NO;
    
    //intialize the location manager
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    //create the beacon to monitor for services
    self.beaconId = [[NSUUID alloc]initWithUUIDString:@"6C0FCA40-77D1-48DC-B5ED-A52817AD81B2"];
    
    //initialze the beacon region with a UUID and indentifier
    self.beaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:nil identifier:nil];
    
    
    //the location manager sends beacon notifications when the user turns on the display and the device is already inside the region. These notifications are sent even if your app is not running. In that situation
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    
    
    //assign the location manager to start monitoring the region
    //[self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    //turn on the monitoring manually, rather then waiting for us to enter a region
    //[self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    

    /***********CORE BLUETOOTH***********/
    self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    [self startScan];
    
    //    PFUser *newUser = [PFUser user];
    //    newUser.username = @"charles";
    //    newUser.password = @"password";
    //    newUser.email = @"symeetry@hotmail.com";
    //
    //    [newUser signUpInBackground];
	
}


#pragma mark - UITableViewDelegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeReuseCellID"];
    cell.textLabel.text = self.users[indexPath.row];
    cell.detailTextLabel.text = @"like and interests";
    cell.imageView.image = self.images[indexPath.row];
    return cell;
    
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
    
    NSLog(@"Did range beacons");
    
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
            [self showSymeetryAlertScreen];
        }
        
        self.view.backgroundColor = [UIColor redColor];
        
        NSLog(@"Beacon accurary %f", beacon.accuracy);
    }
    else if (beacon.proximity == CLProximityNear)
    {
        //regarless of range, only check user in once
        if ( !self.didRequestCheckin)
        {
            self.didRequestCheckin = !self.didRequestCheckin;
            [self showSymeetryAlertScreen];
        }
        
        self.view.backgroundColor = [UIColor greenColor];
        
    }
    else if (beacon.proximity == CLProximityFar)
    {
        //regarless of range, only check user in once
        if(!self.didRequestCheckin)
        {
            self.didRequestCheckin = !self.didRequestCheckin;
            [self showSymeetryAlertScreen];
        }
        self.view.backgroundColor = [UIColor orangeColor];
        
    }
    else if (beacon.proximity == CLRegionStateUnknown)
    {
        self.view.backgroundColor = [UIColor grayColor];
    }
    
}


/*
 * The location manager calls this method whenever there is a boundary transition for a region.
 * The location manager also calls this method in response to a call to its requestStateForRegion: method,
 * which runs asynchronously
 */
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside)
    {
        //we are inside the region being monitored
        [self showRegionStateAlertScreen:@"region state: inside"];
        
    }
    else if (state == CLRegionStateOutside)
    {
        //we are outside the region state being monitored
        [self showRegionStateAlertScreen:@"region state: outside"];
        
    }
    else if (state == CLRegionStateUnknown)
    {
        //we are in a unknow region state
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


#pragma mark - CoreBluetoothDelegate Methods
- (void)startScan
{
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}



- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSLog(@"peripheral name: %@\nUUID: %@\nservices:%@\n",peripheral.name, peripheral.identifier.description,peripheral.services);
    
    NSMutableArray* peripherals = [NSMutableArray new]; //[self mutableArrayValueForKey:@"estimote"];
    
    if(peripheral.name)
    {
        PFObject* beacon = [PFObject objectWithClassName:@"Beacon"];
        NSString* str = [(NSUUID*)peripheral.identifier UUIDString];
        beacon[@"uuid"]= str;
        beacon[@"name"]= peripheral.name;
        [beacon saveInBackground];
    }
    //add device to list. A device can be found more then once
    if(![self.beacons containsObject:peripheral])
    {
        [peripherals addObject:peripheral];
    }
    
}

- (void)connectToPerihperal
{
    [self.centralManager stopScan];
    
    [self.centralManager connectPeripheral:self.beacons.firstObject options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:(id)self];
    [peripheral discoverServices:nil];
    
    NSLog(@"didConnectPeripheral");
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services)
    {
        if(true)//check for the desired service
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic* characteristic in service.characteristics)
    {
        //pull out the characteristics we are interested in, we can also set the
        //notification value for the characteristic if we need to be updated constantly
        NSLog(@"Characteristics of service %@", characteristic);
    }
}


//callback for the update from the peripheral
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
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
        NSLog(@"did checkin");
    }
}


@end
