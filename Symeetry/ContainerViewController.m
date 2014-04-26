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

@interface ContainerViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property AvailableUsersViewController* homeViewController;
@property InterestsViewController* interestsViewController;
@property MapViewController* mapViewController;
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
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    _homeViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    
    _interestsViewController = [storyboard instantiateViewControllerWithIdentifier:@"InterestsViewController"];
    
    _mapViewController = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    
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
    
    CALayer *imageLayer = headerView.imageView.layer;
    [imageLayer setCornerRadius: headerView.imageView.frame.size.width/2];
    [imageLayer setBorderWidth:5.0f];
    [imageLayer setBorderColor:[[UIColor redColor]CGColor]];
    [imageLayer setMasksToBounds:YES];
    
    //set the color
    //headerView.imageView.layer.backgroundColor = [[UIColor redColor]CGColor];
    headerView.imageView.image = [UIImage imageNamed:@"textfieldbackground"];
    
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
            [self showHomeViewController];
            break;
        default:
            NSLog(@"Unexpected segment! %d", sender.selectedSegmentIndex);
            break;
    }
}


- (void)showInterestsViewController
{
 
    [self removeMapVCViewIfNeeded];
    [self removeHomeVCViewIfNeeded];
    [self.containerView addSubview:self.interestsViewController.view];
}

- (void)showMapViewController
{
    [self removeInterestsVCViewIfNeeded];
    [self removeHomeVCViewIfNeeded];
    [self.containerView addSubview:self.mapViewController.view];
}

- (void)showHomeViewController
{
    [self removeInterestsVCViewIfNeeded];
    [self removeMapVCViewIfNeeded];
    [self.containerView addSubview: self.homeViewController.view];
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
    if (self.homeViewController.view.superview != nil)
    {
        [self.homeViewController.view removeFromSuperview];
    }
}

@end
