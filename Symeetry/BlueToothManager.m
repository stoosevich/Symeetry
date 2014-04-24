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

- (void)createCBCentralManager
{
    //NSLog(@"state %ld", self.centralManager.state);
    
    if (self.centralManager.state == CBCentralManagerStatePoweredOff)
    {
        //bluetooth is off we need to tell the user to turn on the service
        
    }
    else if (self.centralManager.state == CBCentralManagerStateUnauthorized)
    {
        //bluetooth is not authorized for this app, we need to tell the user to adjust settings
        
    }
    else if (self.centralManager.state == CBCentralManagerStateUnsupported)
    {
        //we need to tell the user that the device does not support this action
    }
    else if (self.centralManager.state == CBCentralManagerStateUnknown)
    {
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        [self startScan];
    }
    
    else if(self.centralManager.state == CBCentralManagerStatePoweredOn)
    {
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        [self startScan];
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
    NSLog(@"central manger did update state");
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSLog(@"peripheral name: %@\nUUID: %@\nservices:%@\n",peripheral.name, peripheral.identifier.description,peripheral.services);
    
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



@end
