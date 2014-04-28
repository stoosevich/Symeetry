//
//  DisplayUserProfileDelegate.h
//  Symeetry
//
//  Created by user on 4/28/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AvailableUsersViewController;

@protocol DisplayUserProfileDelegate <NSObject>

-(void)displayUserProfile:(PFUser*)user;

@end
