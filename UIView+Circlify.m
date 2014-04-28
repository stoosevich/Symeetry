//
//  UIView+Circlify.m
//  Symeetry
//
//  Created by user on 4/27/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "UIView+Circlify.h"

@implementation UIView (Circlify)
- (void)circlify
{
    CALayer *imageLayer = self.layer;
    [imageLayer setCornerRadius: self.frame.size.width/2];
    [imageLayer setBorderWidth:5.0f];
    [imageLayer setBorderColor:[[UIColor whiteColor]CGColor]];
    [imageLayer setMasksToBounds:YES];
}
@end
