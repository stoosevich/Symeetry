//
//  ProfileHeaderView.m
//  Symeetry
//
//  Created by user on 4/14/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ProfileHeaderView.h"

@interface ProfileHeaderView()


@end

@implementation ProfileHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

+ (ProfileHeaderView *)newViewFromNib:(NSString*)viewName
{
     NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"ProfileHeaderView" owner:nil options:nil];
    
    return nibViews.firstObject;
}

@end
