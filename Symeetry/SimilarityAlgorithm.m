//
//  SimilarityAlgorithm.m
//  Symeetry
//
//  Created by user on 4/16/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "SimilarityAlgorithm.h"


@interface SimilarityAlgorithm()
{
    
}

@end

@implementation SimilarityAlgorithm

+(void)compareInterestr:(PFObject*)currentUser otherUsers:(NSArray*)otherUsers
{
    
    for (PFObject* user in otherUsers)
    {
        [self similarityForUser:currentUser[@"interests"] toUser:user[@"interests"]];
    }
}


+ (NSNumber*)similarityForUser:(NSDictionary*)firstUser toUser:(NSDictionary*)secondUser
{
    int similarity = 0;
    
    //loop throught the current user's (first user) dictionary and compare
    //each value to the other user. For each mathc, increase the count by 1
    for (NSDictionary* item in firstUser)
    {
        if([firstUser objectForKey:item] == [secondUser objectForKey:item])
        {
            similarity++;
        }
    }
    
    //secondUser[@"similarityIndex"] = similarity;
    NSLog(@"total similarity %i", similarity);
    return [NSNumber numberWithInt:similarity];
}


@end
