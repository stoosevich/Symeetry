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

//user related methods
+(PFUser*)currentUser;
+(NSArray*)getUsers;
+(NSArray*)retrieveUsersWithInterests:(void(^)(void))completionBlock;
+(BOOL)isCurrentUser:(PFUser*)user;

+(PFObject*)getInterest:(PFUser*)user;

+(void)logInOrSignUp:(NSString*)username
            password:(NSString*)password
          comfirming:(NSString*)comfirmPassword
               email:(NSString*)email
     completionBlock:(void (^)(void))completionBlock;


//saving and object update methods
+(void)saveInfo:(PFUser*)user objectToSet:(id)object forKey:(NSString*)key completionBlock:(void(^)(void))completionBlock;
+(void)updateInterest:(NSDictionary*)interests forUser:(NSString*)userId;
+(void)addLocation:(CLLocation*)location forUser:(NSString*)userId atBeacon:(NSString*)uuid;

//helper method
+(void)addBeaconWithName:(NSString*)name withUUID:(NSString*)uuid;



@end
