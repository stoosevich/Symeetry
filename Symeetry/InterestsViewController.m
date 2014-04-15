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

@interface InterestsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>


@property (strong, nonatomic) IBOutlet UICollectionView *interestsCollectionView;

//local data source
@property NSArray* interests;
@property NSArray* images;

@end

@implementation InterestsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *headerView =  [ProfileHeaderView newViewFromNib:@"ProfileHeaderView"];
    
    //quick hack to make the view appear in the correct location
    CGRect frame = CGRectMake(0.0, 60.0f, headerView.frame.size.width, headerView.frame.size.height);
    headerView.frame = frame;
    
    [self.view addSubview:headerView];
    
    // Local test users and images
    self.interests = @[@"music", @"movies", @"food"];
    self.images = @[[UIImage imageNamed:@"music_crop.jpg"], [UIImage imageNamed:@"movies_crop.jpg"], [UIImage imageNamed:@"food_crop"]];
    
    
}

// Add animation to cells
-(void)viewDidAppear:(BOOL)animated
{
    int index_start = -1;
    int index_finish = 0;
    CGFloat dx_start = index_start*960;
    CGFloat dx_finish =index_finish*960;
    
    [self.interestsCollectionView setContentOffset:CGPointMake(dx_start, 0) animated:animated];
    
    
    [UIView animateWithDuration:0.67 animations:
     ^{
         // Animate the views on and off the screen. This will appear to slide.
         [self.interestsCollectionView setContentOffset:CGPointMake(dx_finish, 0) animated:animated];
         
     }
                     completion:^(BOOL finished)
     {
         if (finished)
         {
             
             
         }
     }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.interests.count;
}


-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"interestsReuseCellID" forIndexPath:indexPath];
    
    
    return cell;
}

@end
