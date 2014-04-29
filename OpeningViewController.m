//
//  OpeningViewController.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/26/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "OpeningViewController.h"
#import "Parse/Parse.h"
#import "ParseManager.h"


@interface OpeningViewController ()
@property (nonatomic) NSNumber *number;


@end

@implementation OpeningViewController

- (instancetype)initWithNumber:(NSNumber *)number;
{
    if (!(self = [super initWithNibName:nil bundle:nil])) return nil;
    
    self.number = number;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.imageView.image = [UIImage imageNamed:@"View1"];
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    if ([PFUser currentUser] != nil) {
//        
//        //[self performSegueWithIdentifier:@"LoginSegue" sender:self];
//        [self performSegueWithIdentifier:@"showContainerView" sender:self];
//    }
//}


- (CGFloat)randomFloat:(CGFloat)floatMaximum;
{
    return ((CGFloat)arc4random() / (CGFloat)4294967296) * floatMaximum;
}

@end
