//
//  Utilities.m
//  Symeetry
//
//  Created by user on 4/27/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "Utilities.h"
#import "ParseManager.h"

#define RED [UIColor colorWithRed:207/255.0f green:44/255.0f blue:74/255.0f alpha:1.0] //[UIColor redColor]
#define ORANGE [UIColor colorWithRed:235/255.0f green:107/255.0f blue:37/255.0f alpha:1.0]//[UIColor orangeColor]
#define YELLOW [UIColor colorWithRed:210/255.0f green:208/255.0f blue:34/255.0f alpha:1.0] //[UIColor yellowColor]
#define GREEN [UIColor colorWithRed:136/255.0f green:170/255.0f blue:63/255.0f alpha:1.0] //[UIColor greenColor]
#define BLUE [UIColor colorWithRed:54/255.0f green:155/255.0f blue:210/255.0f alpha:1.0]//[UIColor blueColor]
#define BASE ((int)60)

@interface Utilities()

@property NSArray* colors;

@end

@implementation Utilities



+ (CGColorRef)colorBasedOnSimilarity:(int)similarity
{
    NSArray* colors = @[BLUE,GREEN,YELLOW,ORANGE,RED];
    UIColor* rankingColor = nil;
    
    int index = [self determineColorByPercentage:similarity]; //(similarity/12)-1;
    
    if (index > -1)
    {
        rankingColor = colors[index];
        
    }
    else
    {
        rankingColor = [UIColor whiteColor];
    }
    
    return [rankingColor CGColor];
    
}

+(int)determineColorByPercentage:(int)similarity
{
    
    float percentage = (similarity/60.0)*100;
    
    
    if (percentage >=  81)//red
    {
        return 4;
    }
    else if (percentage >= 61 && percentage < 81)//orange
    {
        return 3;
    }
    else if (percentage >= 41 && percentage < 61)//yellow
    {
        return 2;
    }
    else if (percentage >= 21 && percentage < 41)//green
    {
        return 1;
    }
    else if (percentage >=1 && percentage < 65)//blue
    {
        return 0;
    }
    
    return -1;
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
