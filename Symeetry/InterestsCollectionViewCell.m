//
//  InterestsCollectionViewCell.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/14/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "InterestsCollectionViewCell.h"
#import "ParseManager.h"

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

- (IBAction)adjustInterest:(id)sender {
    self.chosenInterests = [NSMutableDictionary new];
    self.rankTestLabel.text = [NSString stringWithFormat:@"%d", (int)self.interestSlider.value];
    [self.chosenInterests setObject:@((int)self.interestSlider.value) forKey:self.interestTextField.text];
    NSLog(@"%@", self.chosenInterests);
}


@end
