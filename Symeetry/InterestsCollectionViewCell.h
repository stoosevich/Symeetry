//
//  InterestsCollectionViewCell.h
//  Symeetry
//
//  Created by Steve Toosevich on 4/14/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface InterestsCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextField *interestTextField;
@property (strong, nonatomic) IBOutlet UIImageView *interestsStarImageView;
@property (strong, nonatomic) IBOutlet UISlider *interestSlider;
@property (strong, nonatomic) IBOutlet UILabel *rankTestLabel;
@property NSMutableDictionary* chosenInterests;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property PFObject* currentUsersInterests;


@end
