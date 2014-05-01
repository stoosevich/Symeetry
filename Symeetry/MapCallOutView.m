//
//  MapCallOutView.m
//  Symeetry
//
//  Created by user on 4/23/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "MapCallOutView.h"

@implementation MapCallOutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
       
    }
    return self;
}

+ (MapCallOutView *)newViewFromNib:(NSString*)viewName
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"MapCallOutView" owner:nil options:nil];
    
    MapCallOutView* view = nibViews.firstObject;
    return view;
}


@end
