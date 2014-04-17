//
//  SimilarUser.h
//  Symeetry
//
//  Created by user on 4/16/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimilarUser : NSObject
@property NSString* userId;
@property NSString* userName;
@property NSString* homeTown;
@property NSString* gender;
@property NSNumber* age;
@property UIImage* photo;
@property NSDictionary* interests;

@end
