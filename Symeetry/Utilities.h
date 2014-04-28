//
//  Utilities.h
//  Symeetry
//
//  Created by user on 4/27/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface Utilities : NSObject

+ (CGColorRef)colorBasedOnSimilarity:(int)similarity;

+(UIImage *)resizeImage:(UIImage *)image withWidth:(float)width andHeight:(float)height;

@end
