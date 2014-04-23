//
//  ProfileHeaderView.m
//  Symeetry
//
//  Created by Symeetry Team on 4/14/14.
//  Copyright (c) 2014 Symeetry Team. All rights reserved.
//

#import "ProfileHeaderView.h"

@interface ProfileHeaderView() <UITextFieldDelegate>


@end

@implementation ProfileHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

+ (ProfileHeaderView *)newViewFromNib:(NSString*)viewName
{
     NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"ProfileHeaderView" owner:nil options:nil];
    
    ProfileHeaderView* view = nibViews.firstObject;
    view.nameTextField.enabled = NO;
    view.ageTextField.enabled = NO;
    //view.genderTextField.enabled = NO;
    view.nameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    //view.genderTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    view.ageTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    return view;
}

-(void)setDelegates:(id)object
{
    self.nameTextField.delegate = object;
    self.genderTextField.delegate = object;
    self.ageTextField.delegate = object;
}

@end
