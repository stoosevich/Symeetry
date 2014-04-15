//
//  ParseManager.h
//  Symeetry
//
//  Created by Charles Northup on 4/15/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

@class CoreLocation;
#import <Foundation/Foundation.h>
#import "Parse/Parse.h"


@interface ParseManager : NSObject

+(NSArray*)getUsers;
+(BOOL)isCurrentUser:(PFUser*)user;
+(PFObject*)getInterest:(PFUser*)user;
+(void)saveInfo:(PFUser*)user objectToSet:(id)object forKey:(NSString*)key;
+(void)addBeaconWithName:(NSString*)name withUUID:(NSString*)uuid;

@end
