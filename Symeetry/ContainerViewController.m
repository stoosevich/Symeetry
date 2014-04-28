//
//  ContainerViewController.m
//  Symeetry
//
//  Created by user on 4/26/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ContainerViewController.h"
#import "ProfileHeaderView.h"
#import "InterestsViewController.h"
#import "MapViewController.h"
#import "AvailableUsersViewController.h"
#import "ParseManager.h"
#import "UIView+Circlify.h"
#import "ChatManager.h"
#import "ProfileViewController.h"
#import "PresentAnimationController.h"


@interface ContainerViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property AvailableUsersViewController* availableUsersViewController;
@property InterestsViewController* interestsViewController;
@property MapViewController* mapViewController;
@property PFUser* user;
@property PresentAnimationController* presentAnimationController;

@end

@implementation ContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadHeaderView];
    
    [[ChatManager sharedChatManager] setPeerID];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    _availableUsersViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    
    _interestsViewController = [storyboard instantiateViewControllerWithIdentifier:@"InterestsViewController"];
    
    _mapViewController = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    
    _availableUsersViewController.delegate = (id)self;
    
    [self showInterestsViewController];
}

/*
 * Load the custom view used for the users profile
 */
- (void)loadHeaderView
{
    //create the view from a xib file
    ProfileHeaderView *headerView =  [ProfileHeaderView newViewFromNib:@"ProfileHeaderView"];
    
    //quick hack to make the view appear in the correct location
    CGRect frame = CGRectMake(0.0, 20.0f, headerView.frame.size.width, headerView.frame.size.height);
    
    //set the frame
    headerView.frame = frame;
    
    [headerView.imageView circlify];
    
    //get the user's image from Parse
    PFFile* file = [[PFUser currentUser]objectForKey:@"photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             headerView.imageView.image = [UIImage imageWithData:data];
         });
         
     }];
    
    //add the new view to the array of subviews
    [self.view addSubview:headerView];
}



- (IBAction)segmentedControl:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex)
    {
        case 0: //Leftmost segment
            [self showInterestsViewController];
            break;
        case 1: //Center segment
            [self showMapViewController];
            break;
        case 2: //Rightmost segment
            [self showAvailableUserViewController];
            break;
        default:
            NSLog(@"Unexpected segment! %ld", (long)sender.selectedSegmentIndex);
            break;
    }
}

-(void)displayUserProfile:(PFUser*)user
{
    self.user = user;
    [self performSegueWithIdentifier:@"showProfileDetail" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showProfileDetail"])
    {
        NSLog(@"prepare for segue\n");

        ProfileViewController* viewController = segue.destinationViewController;
        viewController.user = self.user;
        viewController.transitioningDelegate = (id)self;
    }
}

- (IBAction)unwindFromProfileDetailView:(UIStoryboardSegue*)segue
{
    //
}

- (void)showInterestsViewController
{
    
    [self removeMapVCViewIfNeeded];
    [self removeHomeVCViewIfNeeded];

    
   [UIView transitionWithView:self.containerView duration:2.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
       
       self.interestsViewController.view.frame = CGRectMake(0, 0, 320, 568);
       
   } completion:nil];

    [self.containerView addSubview:self.interestsViewController.view];
}

- (void)showMapViewController
{
    [self removeInterestsVCViewIfNeeded];
    [self removeHomeVCViewIfNeeded];
    
//    [UIView transitionWithView:self.containerView duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
//        [self.containerView addSubview:self.mapViewController.view];
//    } completion:nil];
    
    [self.containerView addSubview:self.mapViewController.view];
}

- (void)showAvailableUserViewController
{
    [self removeInterestsVCViewIfNeeded];
    [self removeMapVCViewIfNeeded];
    
 
//    
//    [UIView transitionWithView:self.containerView duration:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        [self.containerView addSubview:self.availableUsersViewController.view];
//    } completion:nil];
    [self.containerView addSubview: self.availableUsersViewController.view];
}

- (void)removeInterestsVCViewIfNeeded
{
    if (self.interestsViewController.view.superview != nil)
    {
        [self.interestsViewController.view removeFromSuperview];
    }
}

- (void)removeMapVCViewIfNeeded
{
    if (self.mapViewController.view.superview != nil)
    {
        [self.mapViewController.view removeFromSuperview];
    }
}

- (void)removeHomeVCViewIfNeeded
{
    if (self.availableUsersViewController.view.superview != nil)
    {
        [self.availableUsersViewController.view removeFromSuperview];
    }
}




@end
