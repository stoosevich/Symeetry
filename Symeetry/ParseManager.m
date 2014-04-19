//
//  ParseManager.m
//  Symeetry
//
//  Created by Charles Northup on 4/15/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ParseManager.h"

@implementation ParseManager



/*
 * Block to calculate the similarity between two different users. This block 
 * compares the values between two differnet NSDictionary objects, and for every
 * pair of values that are the same, the similarity index is increased by 1
 */
int (^similarityCalculation)(NSDictionary*, NSDictionary*) = ^(NSDictionary* currUser, NSDictionary* otherUser)
{
    int similarity = 0;

    //loop throught the current user's dictionary of interests and compare
    //each value to the other user. For each match increase the count by 1
    for (NSDictionary* item in currUser)
    {
        if([currUser objectForKey:item] == [otherUser objectForKey:item])
        {
            similarity++;
        }
    }
    return similarity;
};



/*
 * Block to update the similarity index of a user based on comparision
 * to the current user. This blocks loops through an array of users and
 * call another block to calculate the actual similarity index between the
 * two users
 */
void (^updateUserSimilarity)(NSArray*) = ^(NSArray* userObjects)
{

    NSDictionary* currentUser = [ParseManager getInterest:[PFUser currentUser]];
    NSDictionary* otherUser = nil;
    
  for(PFObject* user in userObjects)
  {
      //get the interest for each user in the list of objects returned from the search
      otherUser = [ParseManager convertPFObjectToNSDictionary:user[@"interests"]];

      //only calculate the similarity if there other user has intersts
      if(otherUser)
      {
          //call a block function to calculate the similarity of the two users
          user[@"similarityIndex"] = [NSNumber numberWithInt:similarityCalculation(currentUser,otherUser)];
          //NSLog(@"similarityIndex %@",user[@"similarityIndex"]);
      }
  }

};


/*
 * This method retrieves all users in the current vicinity, based on the beacon uuid
 * and assigns each user a similarity index based on the similarity to the current user.
 * the results are sorted by the user similarity index and/or by user name.
 * @ return NSArray
 */
+(NSArray*)retrieveUsersInLocalVicinityWithSimilarity:(NSUUID*)uuid
{
    
    //NSString* uuidString = [uuid UUIDString];
    
    PFQuery* query = [PFUser query];
    
    //exclude the current user
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    //[query whereKey:@"uuid" equalTo:uuidString];
    
    
    //include the actual interest objecst not just a link
    [query includeKey:@"interests"];
    
    //sort by by user name, this will be resorted once the similarity index is assigned
    [query addAscendingOrder:@"username"];

    
    NSArray* users = [query findObjects];
    
    updateUserSimilarity(users);
    
    
    //sort the object once the similarity index is updated
    NSArray *sortedArray;
    
    //sort the array using a block comparator
    sortedArray = [users sortedArrayUsingComparator:^NSComparisonResult(id user1, id user2)
    {
        //covert each object to a PFObject and retrieve the similarity index
        NSNumber *first =  ((PFObject*)user1)[@"similarityIndex"];
        NSNumber *second = ((PFObject*) user2)[@"similarityIndex"];
        return [second compare:first];
    }];
    
    return sortedArray;
    
    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//    {
//        if (!error)
//        {
//            updateUserSimilarity(objects);
//            NSLog(@"objects %@", objects);
//            
//        }
//
//    }];
    
}



/*
 *
 */
+(NSArray*)retrieveUsersInLocalRegion:(NSNumber*)proximity
{
    PFQuery* currentUserLocation = [PFQuery queryWithClassName:@"Location"];
    [currentUserLocation whereKey:@"userId" equalTo:[[PFUser currentUser] objectId]];
    
    return nil;
}


/*
 * Get the current user logged into the system
 */
+(PFUser*)currentUser
{
    return [PFUser currentUser];
}


/*Logs in User if not already logged in
 *Signs the user up if they are new
 *Logs the new user in
 */
+(void)logInOrSignUp:(NSString*)username
            password:(NSString*)password
          comfirming:(NSString*)comfirmPassword
               email:(NSString*)email
     completionBlock:(void (^)(void))completionBlock
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (error) {
            if ([password isEqualToString:comfirmPassword])
            {
                PFUser* newUser = [PFUser new];
                [newUser setUsername:username];
                [newUser setPassword:password];
                [newUser setEmail:email];
                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        completionBlock();
                    }
                }];
            }
            
        }
        else {
            completionBlock();
        }
    }];
}

/*
 * Query the Parse backend to find the list of all users in the system who are not
 * the current user
 * @return NSArray array of PFUser objects
 */
+(NSArray*)getUsers
{
    PFQuery* query = [PFUser query];
    //[query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    return [query findObjects];
}



/*
 * TODO: THIS QUERY NEEDS TO BE ASYNCHRONOUS
 * Query the Parse backend to find the interest of the user based on the
 * user's specific id
 * @return PFObject the Parse Interest object for the specified user
 */
+(NSDictionary*)getInterest:(PFUser*)user
{
    PFQuery* query = [PFQuery queryWithClassName:@"Interests"];
    [query whereKey:@"userid" equalTo:user.objectId];
    
    NSDictionary* dict = nil;
    PFObject* interests = [query getFirstObject];
    
    if (interests)
    {
        dict = [self convertPFObjectToNSDictionary:interests];
    }
    return dict;
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
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                completionBlock();
            }];
        }];
    }
}



/*
 * Stub method to update the user's interest on Parse
 */
+(void)updateInterest:(NSDictionary*)interests forUser:(NSString*)userId
{
    PFObject* parseInterest = [PFObject objectWithClassName:@"Interests"];
    parseInterest[@"userid"] = userId;
    
    [interests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        parseInterest[key] = obj;
    }];
    
    [parseInterest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (error)
        {
            //handle error
        }
    }];
}

/*
 *
 */
+(void)addPFGeoPointLocation
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


/*
 *
 * @return NSArray array of users near the current users location. This is limited
 * to 50 users and uses the Parse default geopoint location query
 */
+ (NSArray*)retrieveSymeetryUsersNearCurrentUser
{
    // User's location
    PFUser* user = [PFUser currentUser];
    PFGeoPoint *userGeoPoint = user[@"location"];
    
    //NSLog(@"geopoint %@", userGeoPoint.description);
    
    // Create a query for places
    PFQuery *query = [PFUser query];
    
    // Interested in locations near user.
    [query whereKey:@"location" nearGeoPoint:userGeoPoint];
    
    // Limit what could be a lot of points.
    query.limit = 50;
    
    // Final list of objects
    return [query findObjects];
}
/*
 * Add a user's location to parse (if not present), include the user's coordinates, id and the beacon
 * nearest their current location. The user's location is first checked to see if it 
 * exists in Parse already.
 * @ param CLLocation users current location
 * @ param NSString User Id the unique id of the user at the given location
 * @ param NSString uuid the unqiue id of the beacon the user
 * @ return void
 */
+(void)addLocation:(CLLocation*)location forUser:(NSString*)userId atBeacon:(NSUUID*)uuid
{
    NSString* uuidString = [uuid UUIDString];
    
    PFQuery* query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"userId" equalTo:userId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects.count == 0)
        {
            NSNumber* latitude = [NSNumber numberWithDouble: location.coordinate.latitude];
            NSNumber* longitude = [NSNumber numberWithDouble: location.coordinate.longitude];
            
            PFObject* parseLocation = [PFObject objectWithClassName:@"Location"];
            
            parseLocation[@"userId"] = userId;
            parseLocation[@"uuid"] = uuidString;
            parseLocation[@"latitude"] = latitude;
            parseLocation[@"longitude"] = longitude;
            parseLocation[@"locationTime"] = location.timestamp;
            
            [parseLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (error)
                 {
                     //TODO: handle error on save
                     NSLog(@"error saving location");
                 }
             }];
        }
    }];
}



/*
 * Adds a newly found beacon to the database of beacon if it has not already present.
 * A new beacon is currentlt determined by the UUID of the beacon
 * @param NSString name the name of the beacon as determined by the bluetooth peripheral name
 * @param NSString uuid the uuid of the beacon that was found
 * @return void
 */
+(void)addBeaconWithName:(NSString*)name withUUID:(NSUUID*)uuid
{
    
    //convert the beacon object into a parse object
    NSString* uuidString = [uuid UUIDString];
    
    PFObject* parseBeacon = [PFObject objectWithClassName:@"Beacon"];
    
    //if we have not see this beacon before add it to the list of beacons
    PFQuery *query = [PFQuery queryWithClassName:@"Beacon"];
    [query whereKey:@"uuid" equalTo:uuidString];
    [query whereKey:@"name" equalTo:name];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         //first check if the beacon is in Parse, if not then add it
         if (objects.count == 0)
         {
             
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

/*
 * Convert a UIImage to a PFFile object to storage on parse
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
        NSLog(@"%@",temp.firstObject);
    }
    
    return [NSArray arrayWithArray:temp];
}

@end
