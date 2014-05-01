//
//  BlueToothManager.m
//  Symeetry
//
//  Created by Symeetry Team on 4/15/14.
//  Copyright (c) 2014 Symeetry Team. All rights reserved.
//

#import "BlueToothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "ParseManager.h"

#define iBEACON_PREFIX NSString  @"02 01 06 1A FF 4C 00 02 15"

@interface BlueToothManager()<CBCentralManagerDelegate,CBPeripheralDelegate>
///bluetooth related
@property CBCentralManager* centralManager;
@property NSMutableArray *beacons;
@end

@implementation BlueToothManager

#pragma mark - CoreBluetoothDelegate Methods

+(instancetype)sharedBlueToothManager
{
    static BlueToothManager *manager = nil;
    if (!manager)
    {
        manager = [BlueToothManager new];
    }
    return manager;
}

- (void)createCBCentralManager:(void(^)(void))onBlock
{

    if (self.centralManager.state == CBCentralManagerStatePoweredOff)
    {
        //bluetooth is off we need to tell the user to turn on the service
            UIAlertView* notOnAlertView = [[UIAlertView alloc] initWithTitle:@"BlueTooth LE Off" message:@"This device has its bluetooth turned off which is required for this application" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [notOnAlertView show];
        
    }
    else if (self.centralManager.state == CBCentralManagerStateUnauthorized)
    {
        UIAlertView* notAuthorizedAlertView = [[UIAlertView alloc] initWithTitle:@"BlueTooth LE Unauthorized" message:@"This device is not authorized to use bluetooth which is required for this application" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [notAuthorizedAlertView show];
        //bluetooth is not authorized for this app, we need to tell the user to adjust settings
        
    }
    else if (self.centralManager.state == CBCentralManagerStateUnsupported)
    {
        UIAlertView* notSupportedAlertView = [[UIAlertView alloc] initWithTitle:@"BlueTooth LE Unsupported" message:@"This device does not support bluetooth LE which is required for this application" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [notSupportedAlertView show];
        //we need to tell the user that the device does not support this action
    }
    else if (self.centralManager.state == CBCentralManagerStateUnknown)
    {
        onBlock();
        
//        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
//        [self startScan];
    }
    
    else if(self.centralManager.state == CBCentralManagerStatePoweredOn)
    {
        onBlock();
//        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
//        [self startScan];
    }
}

/*
 * Scan for bluetooth peripherals of any kind.
 */
- (void)startScan
{
    if (self.centralManager.state == CBCentralManagerStatePoweredOn ||
        self.centralManager.state == CBCentralManagerStateUnknown)
    {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}



- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSMutableArray* peripherals = [NSMutableArray new]; //[self mutableArrayValueForKey:@"estimote"];
    
    //if the perihperal has a name
    if(peripheral.name)
    {

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
    }
}


//callback for the update from the peripheral
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}



@end
