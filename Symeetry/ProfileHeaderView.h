//
//  ProfileHeaderView.h
//  Symeetry
//
//  Created by Symeetry Team on 4/14/14.
//  Copyright (c) 2014 Symeetry Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeaderView : UIView
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;



-(void)setDelegates:(id)object;

//factory method to create view from xib
+ (ProfileHeaderView *)newViewFromNib:(NSString*)viewName;

@end
