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


@end
