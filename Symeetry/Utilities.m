//
//  Utilities.m
//  Symeetry
//
//  Created by user on 4/27/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "Utilities.h"

#define RED [UIColor redColor]
#define ORANGE [UIColor orangeColor]
#define YELLOW [UIColor yellowColor]
#define GREEN [UIColor greenColor]
#define BLUE [UIColor blueColor]
@interface Utilities()

@property NSArray* colors;
@end

@implementation Utilities



+ (CGColorRef)colorBasedOnSimilarity:(int)similarity
{
    NSArray* colors = @[BLUE,GREEN,YELLOW,ORANGE,RED];
    UIColor* rankingColor = nil;
    
    int index = (similarity/12)-1;
    
    if (index > 0)
    {
        rankingColor = colors[index];
    }
    else
    {
        rankingColor = [UIColor whiteColor];
    }
    
    return [rankingColor CGColor];
    
}

@end
