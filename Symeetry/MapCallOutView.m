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
    if (self) {
        // Initialization code
    }
    return self;
}

+ (MapCallOutView *)newViewFromNib:(NSString*)viewName
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"MapCallOutView" owner:nil options:nil];
    
    MapCallOutView* view = nibViews.firstObject;
    return view;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
