//
//  ViewController.h
//  Symeetry
//
//  Created by Symeetry Team on 4/14/14.
//  Copyright (c) 2014 Symeetry Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *homeTableView;
@property NSMutableArray* activeRegions;

@end
