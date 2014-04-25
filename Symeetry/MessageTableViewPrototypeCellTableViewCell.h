//
//  MessageTableViewPrototypeCellTableViewCell.h
//  Symeetry
//
//  Created by Charles Northup on 4/25/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewPrototypeCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *myPicture;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (weak, nonatomic) IBOutlet UIImageView *theirPicture;
@property (weak, nonatomic) IBOutlet UITextView *theirTextView;

@end
