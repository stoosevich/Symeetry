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
    
}


@end
