//
//  SimilarityAlgorithm.h
//  Symeetry
//
//  Created by user on 4/16/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface SimilarityAlgorithm : NSObject

+(void)compareInterestr:(PFObject*)currentUser otherUsers:(NSArray*)otherUsers;

+(id)similarityForUser:(NSDictionary*)firstUser toUser:(NSDictionary*)secondUser;
@end
