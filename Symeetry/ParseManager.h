//
//  ParseManager.h
//  Symeetry
//
//  Created by Symeetry Team on 4/15/14.
//  Copyright (c) 2014 Symeetry Team. All rights reserved.
//

@class CoreLocation;
#import <Foundation/Foundation.h>
#import "Parse/Parse.h"


@interface ParseManager : NSObject

//define a block for the call back
typedef void (^MyCompletion)(NSArray *objects, NSError *error);

//single user related methods
+(PFUser*)currentUser;
+(BOOL)isCurrentUser:(PFUser*)user;

//synchronous method
+(NSDictionary*)getInterest:(PFUser*)user;

//asynchronous method
+(void)getUserInterest:(PFUser*)user WithComplettion:(MyCompletion)completion;

+(void)updateUserNearestBeacon:(CLBeacon*)beacon;

//multiple user object queries
+(void)getUsers;

//public class method with completion block
+ (void)getUsersWithCompletion:(MyCompletion)completion;


//find users that are in the immediate vicinity based on the uuid of a beacon
//+(NSArray*)retrieveUsersInLocalVicinityWithSimilarity:(NSUUID*)uuid;

//find users that are in the immediate vicinity based on the uuid of a beacon
+(void)retrieveUsersInLocalVicinityWithSimilarity:(NSArray*)regions WithComplettion:(MyCompletion)completion;

//user Parse GeoPoint service to find nearby users
+ (NSArray*)retrieveSymeetryUsersForMapView;

//handle user signon, login and logoff
+(void)logInOrSignUp:(NSString*)username
            password:(NSString*)password
          comfirming:(NSString*)comfirmPassword
               email:(NSString*)email
     completionBlock:(void (^)(void))completionBlock;

//saving and object update methods
+(void)saveInfo:(PFUser*)user objectToSet:(id)object forKey:(NSString*)key completionBlock:(void(^)(void))completionBlock;

+(void)setUsersPFGeoPointLocation;
+(void)saveUserInterestsByKey:(NSString*)key withValue:(int)value;


//core location/bluetooth related methods
+(void)addBeaconWithName:(NSString*)name withUUID:(NSUUID*)uuid;
+(void)getListOfAvailableBeaconIds;

//helper method
+(PFFile*)convertUIImageToPFFile:(UIImage*)image;
+(NSDictionary*)convertPFObjectToNSDictionary:(PFObject*)objectToConvert;
+(NSArray*)convertArrayOfPFObjectsToDictionaryObjects:(NSArray*)objectsToConvert;



@end
