//
//  MessageTableViewPrototypeCellTableViewCell.m
//  Symeetry
//
//  Created by Charles Northup on 4/25/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "MessageTableViewPrototypeCellTableViewCell.h"
#import "Utilities.h"

@implementation MessageTableViewPrototypeCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    CALayer *myTextViewLayer = [self.myTextView layer];
    [myTextViewLayer setMasksToBounds:YES];
    [myTextViewLayer setCornerRadius:5.0f];
    
    
    CALayer *theirTextViewLayer = [self.theirTextView layer];
    [theirTextViewLayer setMasksToBounds:YES];
    [theirTextViewLayer setCornerRadius:5.0f];
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
