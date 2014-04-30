//
//  ViewController.h
//  Symeetry
//
//  Created by Symeetry Team on 4/14/14.
//  Copyright (c) 2014 Symeetry Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayUserProfileDelegate.h"

@interface AvailableUsersViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *availableUsersTableView;
@property NSMutableArray* activeRegions;
@property CLBeacon* nearestBeacon;

@property id<DisplayUserProfileDelegate> delegate;

@end
