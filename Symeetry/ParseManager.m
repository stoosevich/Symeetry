//
//  ParseManager.m
//  Symeetry
//
//  Created by Charles Northup on 4/15/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ParseManager.h"


@implementation ParseManager

+(NSArray*)getUsers
{
    PFQuery* query = [PFUser query];
    return [query findObjects];
}

+(PFObject*)getInterest:(PFUser*)user
{
    PFQuery* query = [PFQuery queryWithClassName:@"Interests"];
    [query whereKey:@"userid" equalTo:user.objectId];
    return [[query findObjects] firstObject];
}

/*
 * @ param PFUser user
 * @ return BOOL yes if it is the current user
 */
+(BOOL)isCurrentUser:(PFUser*)user
{
    if (user == [PFUser currentUser]) {
        return YES;
    }
    else{
        return NO;
    }
}

/*
 * @ param PFUser user
 * @ param id object
 * @ param forKey key
 * checks to see if current user is true then modifies the object(object) at the desired key(key)
 * then saves in background
 */

+(void)saveInfo:(PFUser*)user objectToSet:(id)object forKey:(NSString*)key
{
    if ([self isCurrentUser:user]) {
        [[PFUser currentUser] setObject:object forKey:key];
        [[PFUser currentUser] saveInBackground];
    }
}

/*
 * Adds a newly found beacon to the database of beacon if it has not already present.
 * A new beacon is currentlt determined by the UUID of the beacon
 * @param CLBeacon beacon the beacon to be added to the database
 * @return void
 */
+(void)addBeaconWithName:(NSString*)name withUUID:(NSString*)uuid
{
    
    //convert the beacon object into a parse object
    
    
    PFObject* parseBeacon = [PFObject objectWithClassName:@"Beacon"];
    
    //if we have not see this beacon before add it to the list of beacons
    PFQuery *query = [PFQuery queryWithClassName:@"Beacon"];
    [query whereKey:@"uuid" equalTo:uuid];
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


@end
