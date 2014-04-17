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

- (NSDictionary*)initalizeInterestDictionary
{
    NSDictionary* dictionary = @{@"movies":@YES, @"food":@YES, @"travel":@YES,  @"books":@NO, @"tv": @NO};
    
    return dictionary;
}


- (void)similarityForUser:(NSDictionary*)firstUser toUser:(NSDictionary*)secondUser
{
    //NSDictionary* firstUserDict = [self initalizeInterestDictionary];
    
    //NSDictionary* secondUserDict = [self initalizeInterestDictionary];
    
    int similar = 0;
    
    //loop throught the current user's (first user) dictionary and compare
    //each value to the other user. For each mathc, increase the count by 1
    for (NSDictionary* item in firstUser)
    {
        if([firstUser objectForKey:item] == [secondUser objectForKey:item])
        {
            similar++;
        }
    }
    
    NSLog(@"total similarity %i", similar);
    
}


@end
