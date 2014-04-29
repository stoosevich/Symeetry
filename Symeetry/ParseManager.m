//
//  ParseManager.m
//  Symeetry
//
//  Created by Symeetry Team on 4/15/14.
//  Copyright (c) 2014 Symeetry Team. All rights reserved.
//

#import "ParseManager.h"
#import "AvailableUsersViewController.h"


@interface ParseManager()

@end


@implementation ParseManager


#pragma mark -  USER QUERY RELATED METHODS

/*
 * Get the current user logged into the system
 */
+(PFUser*)currentUser
{
    return [PFUser currentUser];
}


/*
 * @ param PFUser user
 * @ return BOOL yes if it is the current user, no otherwise
 */
+(BOOL)isCurrentUser:(PFUser*)user
{
    if ([user.username isEqualToString:[[PFUser currentUser] username]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


/* Logs in User if not already logged in
 * Signs the user up if they are new
 * Logs the new user in
 */
+(void)logIn:(NSString*)username
            password:(NSString*)password
     completionBlock:(void (^)(void))completionBlock
 failedBlock:(void (^)(void))failedBlock
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (error)
        {
            UIAlertView* denied = [[UIAlertView alloc] initWithTitle:@"Invalid" message:@"The username and/or password is invalid" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [denied show];
            failedBlock();
            
        }
        else {
            NSLog(@"saving");
            completionBlock();
            NSLog(@"saved");
        }
    }];
}


/*
 * Query the Parse backend to find the list of all users in the system who are not
 * the current user. This query is syncronous and will cause the main thread to wait
 * until it completes
 * @return NSArray array of PFUser objects
 */
+(void)getUsers
{
    PFQuery* query = [PFUser query];
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [query whereKey:@"hidden" equalTo:@NO];
    NSLog(@"Get Users: finding objects");
    [query findObjects];
    NSLog(@"Get Users: found objects");
}


/*
 * Query the Parse backend to find the list of all users in the system who are not
 * the current user. This query is asyncronous and will allow the main thread to
 * process other activites
 * @param block object with NSArray and NSError parameters
 * @return void
 */
+(void)getUsersWithCompletion:(MyCompletion)completion
{
    PFQuery* query = [PFUser query];
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [query whereKey:@"hidden" equalTo:@NO];
    NSLog(@"Get Users With Completion: finding objects");
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         completion(objects, error);
         NSLog(@"Get Users With Completion: found objects");

     }];
}


#pragma mark -  USER RANKING AND RETRIEVAL RELATED METHODS

/*
 *
 *@ NSArray regions
 *@ Block completion block
 *@ return void
 */
+(void)retrieveUsersInLocalVicinityWithSimilarity:(NSArray*)regions WithComplettion:(MyCompletion)completion
{
    //NSLog(@"PARSE: begin retrieveUsersInLocalVicinityWithSimilarity");
    NSMutableArray* uuids = [NSMutableArray new];
    
    for (CLRegion* region in regions)
    {
        [uuids addObject:region.identifier];
    }
    
    PFQuery* query = [PFUser query];
    
    //exclude the current user
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [query whereKey:@"nearestBeacon" containedIn:uuids];
    [query whereKey:@"hidden" equalTo:@NO];
    
    //include the actual interest objecst not just a link
    [query includeKey:@"interests"];
    
    //sort by by user name, this will be resorted once the similarity index is assigned
    [query addAscendingOrder:@"username"];
    
    NSLog(@"Finding users in Local Vicinity");
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        NSLog(@"Found users in Local Vicinity");
        //NSLog(@"PARSE: retrieveUsersInLocalVicinityWithSimilarity findObjectsInBackgroundWithBlock");
        completion(objects,error);
    }];

}





/*
 * Save/update the users interest when they are changed in the interest
 * view controller
 * @ param NSString key
 * @ param int value
 * @ return void
 */
+(void)saveUserInterestsByKey:(NSString*)key withValue:(int)value
{
    //get the current user
    PFUser* user = [PFUser currentUser];
    
    [self getUserInterest:user WithComplettion:^(NSArray *objects, NSError *error)
    {
        //get the first object, there should only be one per user
        PFUser* user = objects.firstObject;
        
        //update the category with the new value
        
        PFObject* interests = user[@"interests"];
        
        //NSLog(@"PARSE: key: %@  slider value %i",key, value);
        
        interests[key] = [NSNumber numberWithInt:value];
        
        [interests saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if(error)
            {
                //handle error 
            }
        }];
    }];

}


/*
 * Query the Parse backend to find the interest of the user based on the
 * user's specific id. This uses the PFUser query as performance using the
 * query on the interest class itself is inefficient (slow!)
 * @return PFObject the Parse Interest object for the specified user
 */
+(void)getUserInterest:(PFUser*)user WithComplettion:(MyCompletion)completion
{
    PFQuery* query = [PFUser query];
    [query whereKey:@"objectId" equalTo:user.objectId];
    [query includeKey:@"interests"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         //NSLog(@"getUserInterest - findObjectsInBackgroundWithBlock");
         completion(objects,error);
     }];
}


/*
 * Query the Parse backend to find the interest of the user based on the
 * user's specific id. This uses the PFUser query as performance using the
 * query on the interest class itself is inefficient (slow!)
 * @return PFObject the Parse Interest object for the specified user
 */
+(void)getUserInterest:(PFUser*)user WithCompletion:(InterestCompletion)completion
{
    //NSLog(@"PARSE: begin getUserInterest WithCompletion");

    PFQuery* query = [PFUser query];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query includeKey:@"interests"];
    
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        completion(object,error);
    }];
    
}


/*
 * checks to see if current user is true then modifies the object(object) at the desired key(key)
 * then saves in background
 * @ param PFUser user
 * @ param id object
 * @ param forKey key
 * @ return void
 */
+(void)saveInfo:(PFUser*)user objectToSet:(id)object forKey:(NSString*)key completionBlock:(void (^)(void))completionBlock
{
    if ([self isCurrentUser:user])
    {
        [[PFUser currentUser] setObject:object forKey:key];
        
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error)
            {
                completionBlock();
            }];
        }];
    }
}



/*
 * This method users the Parse geopoint object to find users in close proximity
 * to the current user. This is limited to 50 users and uses the Parse default
 * geopoint location query
 * @return NSArray array of users near the current users location.
 */
+ (void)retrieveSymeetryUsersForMapView:(MyCompletion)completion
{
    // User's location
    PFUser* user = [PFUser currentUser];
    
    //get the users geopoint
    PFGeoPoint *userGeoPoint = user[@"location"];
    
    if (userGeoPoint)
    {
        
        
        // Create a query for places
        PFQuery *query = [PFUser query];
        
        // Interested in locations near user.
        [query whereKey:@"location" nearGeoPoint:userGeoPoint];
        [query whereKey:@"objectId" notEqualTo:[user objectId]];
        [query whereKey:@"hidden" equalTo:@NO];
        
        // Limit what could be a lot of points.
        query.limit = 50;
        
        // Final list of objects
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            if(!error)
            {
                completion(objects,error);
            }
        }];
    }
}


/*
 * Set the users geopoint use Parse
 * @return void
 */
+(void)setUsersPFGeoPointLocation
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error)
    {
        if (!error)
        {
            [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if (error)
                {
                    NSLog(@"error: %@",[error userInfo]);
                }
            }];
        }
        else
        {
            NSLog(@"error: %@",[error userInfo]);
        }
    }];
}



#pragma mark - BEACON RETRIEVE AND UPDATE RELATED METHODS

/*
 * Update the users reference to the nearest beacon
 */
+(void)updateUserNearestBeacon:(CLBeacon*)beacon
{
    if (beacon == nil)
    {
        [PFUser currentUser][@"nearestBeacon"] = @"";
        [PFUser currentUser][@"accuracy"] = [NSNumber numberWithFloat:0.0f];
        [PFUser currentUser][@"major"] = [NSNumber numberWithInt:0];
        [PFUser currentUser][@"minor"] = [NSNumber numberWithInt:0];
    }
    else
    {
        NSString* uuidString = [beacon.proximityUUID UUIDString];
        [PFUser currentUser][@"nearestBeacon"] = uuidString;
        [PFUser currentUser][@"accuracy"] = [NSNumber numberWithFloat:beacon.accuracy];
        [PFUser currentUser][@"major"] = beacon.major;
        [PFUser currentUser][@"minor"] = beacon.minor;
    }
    
    [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error)
         {
             //handle eror
         }
     }];
}


/*
 * Adds a newly found beacon to the database of beacon if it has not already present.
 * A new beacon is currently determined by the UUID of the beacon
 * @param NSString name the name of the beacon as determined by the bluetooth peripheral name
 * @param NSString uuid the uuid of the beacon that was found
 * @return void
 */
+(void)addBeacon:(CLBeacon*)beacon
{

    PFObject* parseBeacon = [PFObject objectWithClassName:@"Beacon"];
    
    //if we have not see this beacon before add it to the list of beacons
    PFQuery *query = [PFQuery queryWithClassName:@"Beacon"];
    [query whereKey:@"uuid" equalTo:[beacon.proximityUUID UUIDString]];
    [query whereKey:@"major" equalTo:beacon.major];
    [query whereKey:@"minor" equalTo:beacon.minor];
    
    NSLog(@"beacon info uuid:%@  major:%@ minor:%@",beacon.proximityUUID, beacon.major, beacon.minor);
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         
         NSLog(@"objects %@ %lu", objects, (unsigned long)objects.count);
         
         //first check if the beacon is in Parse, if not add it, otherwise update it
         if (objects.count == 0)
         {
             [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error)
              {
                  [parseBeacon saveEventually:^(BOOL succeeded, NSError *error)
                   {
                       if (error)
                       {
                           //if the beacon is not added to parse
                       }
                   }];
              }];
         }
         else if (objects.count > 0)
         {
             NSLog(@"Saving beacon");
             
             [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error)
              {
                  if (geoPoint)
                  {
                      PFObject* beacon = objects.firstObject;
                      beacon[@"location"] = geoPoint;
            
                      
                      [parseBeacon saveEventually:^(BOOL succeeded, NSError *error)
                       {
                           if (error)
                           {
                               //if the beacon is not added to parse
                           }
                       }];
                  }
                  
              }];

         }
     }];

}

/*
 * Query Parse for a list of all know beacons
 */
+(void)getListOfAvailableBeaconIds
{
    PFQuery* beaconQuery = [PFQuery queryWithClassName:@"Beacon"];
    
    [beaconQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         
     }];
}

#pragma mark - HELPER METHODS


/*
 * Convert a UIImage to a PFFile object for storage on parse
 * @param UIImage image the UIImage to be converted to a Parse file
 * @return PFFile file the file created from the UIImage object
 */
+(PFFile*)convertUIImageToPFFile:(UIImage*)image
{
    NSData* imagedata = UIImageJPEGRepresentation(image, 0.8f);
    PFFile* file = [PFFile fileWithData:imagedata];
    return file;
}


/*
 * Convert a Parse PFObject into a NSDictionary
 */
+(NSDictionary*)convertPFObjectToNSDictionary:(PFObject*)objectToConvert
{
    
    //extract all the keys from the PFObject
    NSArray* objectToConvertKeys = [objectToConvert allKeys];
 
    //create a mutable dictionary
    NSMutableDictionary* dictionary =[[NSMutableDictionary alloc]init];
    
    //create and enumerator for the array of keys
    NSEnumerator *e = [objectToConvertKeys objectEnumerator];
    
    id object;
    
    //use the iterator to loop through the list of objects and add the value to the key
    while (object = [e nextObject])
    {
        [dictionary setValue:[objectToConvert objectForKey:object] forKey:object];
    }
    
    return dictionary;
}


/*
 *
 */
+(NSArray*)convertArrayOfPFObjectsToDictionaryObjects:(NSArray*)objectsToConvert
{
    NSMutableArray* temp = [NSMutableArray new];
    
    for (PFObject* object in objectsToConvert)
    {
        [temp addObject:[self convertPFObjectToNSDictionary:object]];
    }
    
    return [NSArray arrayWithArray:temp];
}

@end
