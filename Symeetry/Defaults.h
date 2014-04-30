//
//  Defaults.h
//  Symeetry
//
//  Created by Symeetry Team on 4/18/14.
//  Copyright (c) 2014 Symeetry Team All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Defaults : NSObject

extern NSString *BeaconIdentifier;

+ (Defaults *)sharedDefaults;

//update the list of uuids
- (void)saveUUIDListToFile;

@property (nonatomic) NSMutableArray *supportedProximityUUIDs;
@property (nonatomic, copy, readonly) NSUUID *defaultProximityUUID;
@property (nonatomic, copy, readonly) NSNumber *defaultPower;

@end
