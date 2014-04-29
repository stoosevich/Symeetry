//
//  Utilities.m
//  Symeetry
//
//  Created by user on 4/27/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "Utilities.h"
#import "ParseManager.h"

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

/**
 *Resize an image taken with the camera for uploading to Parse.com
 *@param float New width for the resized image
 *@param float New height for the resized image
 *@return UIImage Resized image
 */
+(UIImage *)resizeImage:(UIImage *)image withWidth:(float)width andHeight:(float)height
{
    UIImage *resizedImage = nil;
    
    //get the new size for the image
    CGSize newSize = CGSizeMake(width, height);
    
    //create a rectangle based on the new size
    CGRect rectangle = CGRectMake(0, 0, newSize.width, newSize.height);
    
    //create a bitmap content for the resized image
    UIGraphicsBeginImageContext(newSize);
    
    //redraw the image in the new rectangle
    [image drawInRect:rectangle];
    
    //assign the new image to resize image variable
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //end the image context
    UIGraphicsEndImageContext();
    
    return resizedImage;
}


@end
