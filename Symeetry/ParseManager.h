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
+(NSArray*)retrieveUsersWithInterests;
+(BOOL)isCurrentUser:(PFUser*)user;
+(NSDictionary*)getInterest:(PFUser*)user;


//handle user signon, login and logoff
+(void)logInOrSignUp:(NSString*)username
            password:(NSString*)password
          comfirming:(NSString*)comfirmPassword
               email:(NSString*)email
     completionBlock:(void (^)(void))completionBlock;


//saving and object update methods
+(void)saveInfo:(PFUser*)user objectToSet:(id)object forKey:(NSString*)key completionBlock:(void(^)(void))completionBlock;
+(void)updateInterest:(NSDictionary*)interests forUser:(NSString*)userId;
+(void)addLocation:(CLLocation*)location forUser:(NSString*)userId atBeacon:(NSString*)uuid;

//core location/bluetooth related methods
+(void)addBeaconWithName:(NSString*)name withUUID:(NSString*)uuid;

//helper method
+(PFFile*)convertUIImageToPFFile:(UIImage*)image;
+(NSDictionary*)convertPFObjectToNSDictionary:(PFObject*)objectToConvert;
+(NSArray*)convertArrayOfPFObjectsToDictionaryObjects:(NSArray*)objectsToConvert;

@end
