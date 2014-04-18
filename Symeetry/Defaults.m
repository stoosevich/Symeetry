//
//  Defaults.m
//  Symeetry
//
//  Created by user on 4/18/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "Defaults.h"
@interface Defaults()

//redefine the properties so they can be set up in the class
@property (nonatomic, copy) NSArray *supportedProximityUUIDs;
@property (nonatomic, copy) NSUUID *defaultProximityUUID;
@property (nonatomic, copy) NSNumber *defaultPower;

@end



@implementation Defaults
NSString *BeaconIdentifier = @"com.Symeetry.beacon";


- (id)init
{
    self = [super init];
    
    if(self)
    {
        // uuidgen should be used to generate UUIDs.
        self.supportedProximityUUIDs = @[[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"],
                                     [[NSUUID alloc] initWithUUIDString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"],
                                     [[NSUUID alloc] initWithUUIDString:@"74278BDA-B644-4520-8F0C-720EAF059935"],
                                         [[NSUUID alloc] initWithUUIDString:@"2F234454-CF6D-4ADF-ADF2-F4911BA9FFA6"],
                                         [[NSUUID alloc] initWithUUIDString:@"AFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"],
                                         [[NSUUID alloc] initWithUUIDString:@"92AB49BE-4127-42F4-B532-90fAF1E26491"],
                                         [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"],
                                         [[NSUUID alloc] initWithUUIDString:@"08D4A950-80F0-4D42-A14B-D53E063516E6"],
                                         [[NSUUID alloc] initWithUUIDString:@"8492E75F-4FD6-469D-B132-043FE94921D8"],
                                         [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"]
                                         
                                         
                                         ];
        self.defaultPower = @-59;
    }
    
    return self;
}


+ (Defaults *)sharedDefaults
{
    static id sharedDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[self alloc] init];
    });
    
    return sharedDefaults;
}


- (NSUUID *)defaultProximityUUID
{
    return self.supportedProximityUUIDs[0];
}

@end
