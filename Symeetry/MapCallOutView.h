//
//  MapCallOutView.h
//  Symeetry
//
//  Created by user on 4/23/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapCallOutView : UIView
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property IBOutlet UIImageView* imageView;

@property (weak, nonatomic) IBOutlet UIView *backGroundView;
+ (MapCallOutView *)newViewFromNib:(NSString*)viewName;
@end
