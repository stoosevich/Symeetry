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
typedef void (^InterestCompletion)(PFObject *object, NSError *error);
typedef void (^LogoutCompletion)(BOOL succeeded, NSError *error);

//single user related methods
+(PFUser*)currentUser;
+(BOOL)isCurrentUser:(PFUser*)user;


//asynchronous method
+(void)getUserInterest:(PFUser*)user WithCompletion:(InterestCompletion)completion;


//methods to update the nearest beacon to current user
+(void)updateUserNearestBeacon:(CLBeacon*)beacon;
+(void)updateUserNearestBeaconOnLogout:(CLBeacon*)beacon withCompletion:(LogoutCompletion)completion;

//multiple user object queries
+(void)getUsers;

//public class method with completion block
+ (void)getUsersWithCompletion:(MyCompletion)completion;


+(void)userInterest:(PFUser*)user completionBlock:(InterestCompletion)completionBlock;

//find users that are in the immediate vicinity based on the uuid of a beacon
+(void)retrieveUsersInLocalVicinityWithSimilarity:(NSArray*)regions WithComplettion:(MyCompletion)completion;

//user Parse GeoPoint service to find nearby users
+ (void)retrieveSymeetryUsersForMapView:(MyCompletion)completion;

//handle user signon, login and logoff
+(void)logIn:(NSString*)username
    password:(NSString*)password
completionBlock:(void (^)(void))completionBlock
 failedBlock:(void (^)(void))failedBlock;

//saving and object update methods
+(void)saveInfo:(PFUser*)user objectToSet:(id)object forKey:(NSString*)key completionBlock:(void(^)(void))completionBlock;

+(void)setUsersPFGeoPointLocation;
+(void)saveUserInterestsByKey:(NSString*)key withValue:(int)value;


//core location/bluetooth related methods
+(void)addBeacon:(CLBeacon*)beacon;
+(void)getListOfAvailableBeaconIds;

//helper method
+(PFFile*)convertUIImageToPFFile:(UIImage*)image;
+(NSDictionary*)convertPFObjectToNSDictionary:(PFObject*)objectToConvert;
+(NSArray*)convertArrayOfPFObjectsToDictionaryObjects:(NSArray*)objectsToConvert;



@end
