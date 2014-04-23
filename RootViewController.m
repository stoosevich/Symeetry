//
//  RootViewController.m
//  Symeetry
//
//  Created by Charles Northup on 4/23/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "RootViewController.h"
#import "ParseManager.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([PFUser currentUser] != nil) {
        [self performSegueWithIdentifier:@"GoToLoginScreen" sender:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];


}

@end
