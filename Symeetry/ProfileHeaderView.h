//
//  ProfileHeaderView.h
//  Symeetry
//
//  Created by user on 4/14/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeaderView : UIView
@property IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;


//factory method to create view from xib
+ (ProfileHeaderView *)newViewFromNib:(NSString*)viewName;

@end
