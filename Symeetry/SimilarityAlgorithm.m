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
    NSDictionary* firstUserDict = [self initalizeInterestDictionary];
    
    NSDictionary* secondUserDict = [self initalizeInterestDictionary];
    
    int similar = 0;
    
    for (NSDictionary* item in firstUserDict)
    {
        if([firstUserDict objectForKey:item] == [secondUserDict objectForKey:item])
        {
            similar++;
            NSLog(@"similar:%i", similar);
        }
    }
    
}


@end
