//
//  OpeningViewController.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/26/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "OpeningViewController.h"

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

    //self.view.backgroundColor = [UIColor redColor];
    self.imageView.image = [UIImage imageNamed:@"SymeetryFar"];

    //self.imageView.image = [UIImage imageNamed:@"View1"];
    
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.

}

- (CGFloat)randomFloat:(CGFloat)floatMaximum;
{
    return ((CGFloat)arc4random() / (CGFloat)4294967296) * floatMaximum;
}

@end
