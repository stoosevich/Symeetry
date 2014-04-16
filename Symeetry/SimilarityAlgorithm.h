//
//  SimilarityAlgorithm.h
//  Symeetry
//
//  Created by user on 4/16/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimilarityAlgorithm : NSObject
- (void)similarityForUser:(NSDictionary*)firstUser toUser:(NSDictionary*)secondUser;
@end
