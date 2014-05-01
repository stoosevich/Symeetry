//
//  InterestsCollectionViewCell.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/14/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "InterestsCollectionViewCell.h"
#import "ParseManager.h"
#import "InterestsViewController.h"

@interface InterestsCollectionViewCell()


@end

@implementation InterestsCollectionViewCell

    

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)adjustInterest:(UISlider*)sender {
    
    NSNumber* number = @((int)sender.value);
    
    self.rankTestLabel.text = [NSString stringWithFormat:@"%d", (int)self.interestSlider.value];
    
    //Change background color with slider
    NSArray *backgroundColors = [[NSArray alloc]initWithObjects:[UIColor grayColor],
                                 [UIColor colorWithRed:54.0/255.0 green:155.0/255.0 blue:210.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:136.0/255.0 green:170.0/255.0 blue:63.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:210.0/255.0 green:208.0/255.0 blue:34.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:235.0/255.0 green:107.0/255.0 blue:37.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:207.0/255.0  green:44.0/255.0  blue:74.0/255.0  alpha:1.0], nil];
    
    self.backgroundView.backgroundColor = [backgroundColors objectAtIndex:number.intValue];
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InterestsViewController* iVC = [storyBoard instantiateViewControllerWithIdentifier:@"InterestsViewController"];
    [iVC.interests replaceObjectAtIndex:self.tag withObject:number];
    
    [self.currentUsersInterests setObject:number forKey:self.interestTextField.text];
    [self.currentUsersInterests saveInBackground];

}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    //set the default value of the cell for reuse
    self.interestTextField.text = @"";
}


@end
