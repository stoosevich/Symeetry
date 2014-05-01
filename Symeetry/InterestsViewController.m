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
@property NSArray* images;
@property NSArray* interestNames;
@property PFObject* myInterests;

@end

@implementation InterestsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [self.interests removeAllObjects];
    [self updateInterest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"interests" ofType:@"plist"];
    NSMutableDictionary *interestNamesDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    interestNamesDictionary = [[NSMutableDictionary alloc]initWithDictionary:interestNamesDictionary copyItems:YES];
 
    // Local images
   self.images = @[[UIImage imageNamed:@"ic_interest_music@2x"],
                   [UIImage imageNamed:@"ic_interest_movies"],
                   [UIImage imageNamed:@"ic_interest_food"],
                   [UIImage imageNamed:@"ic_interest_school"],
                   [UIImage imageNamed:@"ic_interest_dancing"],
                   [UIImage imageNamed:@"ic_interest_books"],
                   [UIImage imageNamed:@"ic_interest_tv"],
                   [UIImage imageNamed:@"ic_interest_art"],
                   [UIImage imageNamed:@"ic_interest_tech"],
                   [UIImage imageNamed:@"ic_interest_games"],
                   [UIImage imageNamed:@"ic_interest_fashion"],
                   [UIImage imageNamed:@"ic_interest_volunteer"]];
    
    self.interestNames = @[@"music",
                           @"movies",
                           @"food",
                           @"school",
                           @"dancing",
                           @"books",
                           @"tv",
                           @"art",
                           @"technology",
                           @"games",
                           @"fashion",
                           @"volunteer"];
    
    self.interests = [NSMutableArray new];
}

-(void)updateInterests:(void(^)(PFObject* object, NSError* error)) completion
{
    NSLog(@"Getting Interests");
    [ParseManager userInterest:[PFUser currentUser] completionBlock:^(PFObject *object, NSError *error)
    {
        completion(object, error);
    }];
}

-(void)updateInterest
{
    [self updateInterests:^(PFObject *object, NSError *error) {
        NSLog(@"Anaylsing Interests");
        self.myInterests = object;
        for (NSString*string in self.interestNames)
        {
            NSNumber* number = [object objectForKey:string];
            [self.interests addObject:number];
        }
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.interestsCollectionView reloadData];
        });
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.interests.firstObject == nil)
    {
        return 0;
    }
    else
    {
        return self.images.count;
    }
}

-(InterestsCollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    InterestsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"interestsReuseCellID" forIndexPath:indexPath];
    
    cell.imageView.image = self.images[indexPath.row];
    cell.interestTextField.text = self.interestNames[indexPath.row];
    cell.backgroundView.backgroundColor = [UIColor grayColor];
    cell.interestSlider.value = [self.interests[indexPath.row] floatValue];
    cell.currentUsersInterests = self.myInterests;
    cell.tag = (int)self.images[indexPath.row];
    
    return cell;
}

@end
