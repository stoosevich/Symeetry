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

//single user related methods
+(PFUser*)currentUser;
+(BOOL)isCurrentUser:(PFUser*)user;
+(NSDictionary*)getInterest:(PFUser*)user;
+(void)updateUserNearestBeacon:(NSUUID*)uuid;

//multiple user object queries
+(void)getUsers;

//define a block for the call back
typedef void (^MyCompletion)(NSArray *objects, NSError *error);

//create the public class method with block
+ (void)getUsersWithCompletion:(MyCompletion)completion;


//find users that are in the immediate vicinity based on the uuid of a beacon
+(NSArray*)retrieveUsersInLocalVicinityWithSimilarity:(NSUUID*)uuid;

//user Parse GeoPoint service to find nearby users
+ (NSArray*)retrieveSymeetryUsersNearCurrentUser;

//handle user signon, login and logoff
+(void)logInOrSignUp:(NSString*)username
            password:(NSString*)password
          comfirming:(NSString*)comfirmPassword
               email:(NSString*)email
     completionBlock:(void (^)(void))completionBlock;


//saving and object update methods
+(void)saveInfo:(PFUser*)user objectToSet:(id)object forKey:(NSString*)key completionBlock:(void(^)(void))completionBlock;
+(void)updateInterest:(NSDictionary*)interests forUser:(NSString*)userId;
+(void)setUsersPFGeoPointLocation;
+(void)addLocation:(CLLocation*)location forUser:(NSString*)userId atBeacon:(NSUUID*)uuid;

//core location/bluetooth related methods
+(void)addBeaconWithName:(NSString*)name withUUID:(NSUUID*)uuid;
+(void)getListOfAvailableBeaconIds;

//helper method
+(PFFile*)convertUIImageToPFFile:(UIImage*)image;
+(NSDictionary*)convertPFObjectToNSDictionary:(PFObject*)objectToConvert;
+(NSArray*)convertArrayOfPFObjectsToDictionaryObjects:(NSArray*)objectsToConvert;

@end
