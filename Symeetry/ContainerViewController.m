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
#import "MMDrawerController.h"
#import "BlueToothManager.h"

@interface ContainerViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property AvailableUsersViewController* availableUsersViewController;
@property InterestsViewController* interestsViewController;
@property MapViewController* mapViewController;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

//used in delegate method to display the users detail
@property PFUser* user;


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

-(void)viewDidAppear:(BOOL)animated
{
    [[BlueToothManager sharedBlueToothManager]createCBCentralManager:^{
        if ([PFUser currentUser] == nil)
        {
            UIViewController* login = [self.storyboard instantiateViewControllerWithIdentifier:@"RootNavController"];
            [self presentViewController:login animated:YES completion:nil];
            [ChatManager sharedChatManager].on = NO;
            
        }
        else
        {
            if ([[ChatManager sharedChatManager] on]) {
                NSLog(@"already on");
            }
            else{
                [[ChatManager sharedChatManager] setPeerID];
                [[ChatManager sharedChatManager] checkinChat];
                [self showInterestsViewController];
                [self loadHeaderView];
                
                _availableUsersViewController.delegate = (id)self;
                [ChatManager sharedChatManager].on = YES;
                NSLog(@"BroadCasting Signal");
            }
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    _availableUsersViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    
    _interestsViewController = [storyboard instantiateViewControllerWithIdentifier:@"InterestsViewController"];
    
    _mapViewController = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    
    self.segmentedControl.contentMode = UIViewContentModeScaleAspectFill;
    for (int ii = 0; ii < self.segmentedControl.numberOfSegments; ++ii)
    {
        UIImage *img = [self.segmentedControl imageForSegmentAtIndex:ii];
        img = [img resizableImageWithCapInsets:UIEdgeInsetsZero];
        [self.segmentedControl setImage:img forSegmentAtIndex:ii];
    }
}

/*
 * Load the custom view used for the users profile
 */
- (void)loadHeaderView
{
    //create the view from a xib file
    ProfileHeaderView *headerView =  [ProfileHeaderView newViewFromNib:@"ProfileHeaderView"];
    
    headerView.nameTextField.text =  [[PFUser currentUser] objectForKey:@"username"];
    headerView.bioTextField.text = [[PFUser currentUser] objectForKey:@"biography"];

    
    //quick hack to make the view appear in the correct location
    CGRect frame = CGRectMake(0.0, 20.0f, headerView.frame.size.width, headerView.frame.size.height);
    
    //set the frame
    headerView.frame = frame;
    headerView.menuPressed =^{
        MMDrawerController* draw = (id)self.view.window.rootViewController;
        [draw toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    };
    
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

}

- (void)showInterestsViewController
{
    
    [self removeMapVCViewIfNeeded];
    [self removeAvailableUsersVCViewIfNeeded];
    [self.containerView addSubview:self.interestsViewController.view];
}

- (void)showMapViewController
{
    [self removeInterestsVCViewIfNeeded];
    [self removeAvailableUsersVCViewIfNeeded];
    [self.containerView addSubview:self.mapViewController.view];
}

- (void)showAvailableUserViewController
{
    [self removeInterestsVCViewIfNeeded];
    [self removeMapVCViewIfNeeded];
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

- (void)removeAvailableUsersVCViewIfNeeded
{
    if (self.availableUsersViewController.view.superview != nil)
    {
        [self.availableUsersViewController.view removeFromSuperview];
    }
}




@end
