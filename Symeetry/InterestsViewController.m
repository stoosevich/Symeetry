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
//@property NSMutableDictionary* chosenInterests;
@property NSArray* images;
@property NSArray* interestNames;
@property NSMutableArray* interests;
@property PFObject* myInterests;
//@property UISwipeGestureRecognizer *swipeLeftRecognizer;
//@property UISwipeGestureRecognizer *swipeRightRecognizer;

@end

@implementation InterestsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [self.interests removeAllObjects];
    [ParseManager getUserInterest:[PFUser currentUser] WithCompletion:^(PFObject *object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.myInterests = object;
            for (NSString*string in self.interestNames) {
                NSNumber* number = [object objectForKey:string];
                [self.interests addObject:number];
            }
            [self.interestsCollectionView reloadData];
        });
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
 //   self.interestsCollectionView.backgroundColor = [UIColor orangeColor];

    self.interestsCollectionView.backgroundColor = [UIColor colorWithRed:186.f/255.f green:228.f/255.f blue:217.f/255.f alpha:1];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"interests" ofType:@"plist"];
    NSMutableDictionary *interestNamesDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    interestNamesDictionary = [[NSMutableDictionary alloc]initWithDictionary:interestNamesDictionary copyItems:YES];
   // NSLog(@"contents %@", interestNamesDictionary);
    
    // Local images
   self.images = @[[UIImage imageNamed:@"music_note240x240"], [UIImage imageNamed:@"movies_crop.jpg"], [UIImage imageNamed:@"Food_crop.jpg"], [UIImage imageNamed:@"school.jpg"], [UIImage imageNamed:@"dancing.jpg"], [UIImage imageNamed:@"books.jpg"], [UIImage imageNamed:@"tv.jpg"], [UIImage imageNamed:@"art.jpg"], [UIImage imageNamed:@"technology.jpg"], [UIImage imageNamed:@"games.jpg"], [UIImage imageNamed:@"fashion.jpg"], [UIImage imageNamed:@"volunteer.jpg"]];
    
    self.interestNames = @[@"music", @"movies", @"food", @"school", @"dancing", @"books", @"tv", @"art", @"technology", @"games", @"fashion", @"volunteer"];
    self.interests = [NSMutableArray new];

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
//    UISwipeGestureRecognizer* swipeRightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
//    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//    [cell addGestureRecognizer:swipeRightRecognizer];
//    
//    UISwipeGestureRecognizer* swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
//    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//    [cell addGestureRecognizer:swipeLeftRecognizer];

    cell.imageView.image = self.images[indexPath.row];
    cell.interestTextField.text = self.interestNames[indexPath.row];
    cell.backgroundView.backgroundColor = [UIColor whiteColor];
    cell.interestSlider.value = [self.interests[indexPath.row] floatValue];
    cell.currentUsersInterests = self.myInterests;
  //  cell.backgroundColor = [UIColor blueColor];
 //   cell.backgroundColor = [UIColor colorWithRed:186 green:228 blue:217 alpha:1];
    
    return cell;
}



//- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)sender
//
//{
//
//    if(sender.direction == UISwipeGestureRecognizerDirectionRight)
//    {
//        NSLog(@"swiped right");
//        NSLog(@"%@", [sender.view class]);
//        NSIndexPath* indexPath = [self.interestsCollectionView indexPathForCell:(InterestsCollectionViewCell*)sender.view];
//        InterestsCollectionViewCell* cell = (InterestsCollectionViewCell*)[self.interestsCollectionView cellForItemAtIndexPath:indexPath];
//        cell.interestsStarImageView.hidden = NO;
//        
//        [self.chosenInterests setObject:@YES forKey: self.interestNames[indexPath.row]];
//        NSLog(@"dictionary keys %@",self.chosenInterests);
//        
//        
//    }
//   else if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
//    {
//        NSLog(@"swiped left");
//        NSLog(@"%@", [sender.view class]);
//        NSIndexPath* indexPath = [self.interestsCollectionView indexPathForCell:(InterestsCollectionViewCell*)sender.view];
//        InterestsCollectionViewCell* cell = (InterestsCollectionViewCell*)[self.interestsCollectionView cellForItemAtIndexPath:indexPath];
//        cell.interestsStarImageView.hidden = YES;
//
//        [self.chosenInterests setObject:@NO forKey: self.interestNames[indexPath.row]];
//        NSLog(@"dictionary keys %@",self.chosenInterests);
//    }
//    
//
//}



@end
