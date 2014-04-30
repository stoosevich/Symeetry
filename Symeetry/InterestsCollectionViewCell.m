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
    
    NSNumber* number = @(sender.value);
    
//    self.chosenInterests = [NSMutableDictionary new];
    self.rankTestLabel.text = [NSString stringWithFormat:@"%d", (int)self.interestSlider.value];
//    [self.chosenInterests setObject:@((int)self.interestSlider.value) forKey:self.interestTextField.text];
//    NSLog(@"%@", self.chosenInterests);
    
    //Change background color with slider
    NSArray *backgroundColors = [[NSArray alloc]initWithObjects:[UIColor whiteColor],[UIColor blueColor],[UIColor greenColor],[UIColor yellowColor],[UIColor orangeColor],[UIColor redColor], nil];
    self.backgroundView.backgroundColor = [backgroundColors objectAtIndex:number.intValue];
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InterestsViewController* iVC = [storyBoard instantiateViewControllerWithIdentifier:@"InterestsViewController"];
    [iVC.interests replaceObjectAtIndex:self.tag withObject:number];
    
    [self.currentUsersInterests setObject:number forKey:self.interestTextField.text];
    [self.currentUsersInterests saveInBackground];
    
//    [ParseManager saveUserInterestsByKey:self.interestTextField.text withValue:(int)self.interestSlider.value];

}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    //set the default value of the cell for reuse
    self.interestTextField.text = @"";
    
    //set the value of the slider to the value in Parse
}


@end
