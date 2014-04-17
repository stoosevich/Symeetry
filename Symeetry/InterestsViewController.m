//
//  InterestsViewController.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/14/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "InterestsViewController.h"
#import "InterestsCollectionViewCell.h"
#import "ProfileHeaderView.h"
#import "ParseManager.h"

@interface InterestsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>


@property (strong, nonatomic) IBOutlet UICollectionView *interestsCollectionView;

//local data source
@property NSMutableDictionary* chosenInterests;
@property NSArray* images;
@property NSArray* interestNames;
//@property UISwipeGestureRecognizer *swipeLeftRecognizer;
//@property UISwipeGestureRecognizer *swipeRightRecognizer;

@end

@implementation InterestsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.chosenInterests = [NSMutableDictionary new];
    UIView *headerView =  [ProfileHeaderView newViewFromNib:@"ProfileHeaderView"];
    
    //quick hack to make the view appear in the correct location
    CGRect frame = CGRectMake(0.0, 60.0f, headerView.frame.size.width, headerView.frame.size.height);
    headerView.frame = frame;
    
    [self.view addSubview:headerView];
    
    // Local images
   self.images = @[[UIImage imageNamed:@"Music_crop"], [UIImage imageNamed:@"movies_crop.jpg"], [UIImage imageNamed:@"Food_crop.jpg"]];
    self.interestNames = @[@"Music", @"Movies", @"Food"];
    
    
    
}

// Add animation to cells
//-(void)viewDidAppear:(BOOL)animated
//{
//    int index_start = -1;
//    int index_finish = 0;
//    CGFloat dx_start = index_start*960;
//    CGFloat dx_finish =index_finish*960;
//    
//    [self.interestsCollectionView setContentOffset:CGPointMake(dx_start, 0) animated:animated];
//    
//    
//    [UIView animateWithDuration:0.67 animations:
//     ^{
//         // Animate the views on and off the screen. This will appear to slide.
//         [self.interestsCollectionView setContentOffset:CGPointMake(dx_finish, 0) animated:animated];
//         
//     }
//                     completion:^(BOOL finished)
//     {
//         if (finished)
//         {
//             
//             
//         }
//     }];
//}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}


-(InterestsCollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    InterestsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"interestsReuseCellID" forIndexPath:indexPath];
    
    // Setting swipe gestures on cells.
    UISwipeGestureRecognizer* swipeRightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [cell addGestureRecognizer:swipeRightRecognizer];
    
    UISwipeGestureRecognizer* swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [cell addGestureRecognizer:swipeLeftRecognizer];

    cell.imageView.image = self.images[indexPath.row];
    cell.interestTextField.text = self.interestNames[indexPath.row];

//    if (swipeRightRecognizer.direction == UISwipeGestureRecognizerDirectionLeft)
//    {
//        [self.chosenInterests setObject:cell.interestTextField.text forKey:@"Music"];
//    }
//    
//    else if (swipeRightRecognizer.direction == UISwipeGestureRecognizerDirectionRight)
//    {
//        [self.chosenInterests setObject:cell.interestTextField.text forKey:@"false"];
// 
//    }
//    
    
    return cell;
}
- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)sender

//- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)sender
{
  //  [self.chosenInterests setObject: forKey:true;
if(sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@"swiped right");
        NSLog(@"%@", [sender.view class]);
        NSIndexPath* indexPath = [self.interestsCollectionView indexPathForCell:(InterestsCollectionViewCell*)sender.view];
        int x = indexPath.row;
        NSLog(@"%d", x);
    }
   else if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        NSLog(@"swiped left");
        NSLog(@"%@", [sender.view class]);
        NSIndexPath* indexPath = [self.interestsCollectionView indexPathForCell:(InterestsCollectionViewCell*)sender.view];
        int x = indexPath.row;
        NSLog(@"%d", x);
    }
    
    
    
}



@end
