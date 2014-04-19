//
//  Defaults.h
//  Symeetry
//
//  Created by user on 4/18/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Defaults : NSObject

extern NSString *BeaconIdentifier;

+ (Defaults *)sharedDefaults;

@property (nonatomic, copy, readonly) NSArray *supportedProximityUUIDs;
@property (nonatomic, copy, readonly) NSUUID *defaultProximityUUID;
@property (nonatomic, copy, readonly) NSNumber *defaultPower;

@end
