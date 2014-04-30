//
//  PageViewController.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/26/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "PageViewController.h"
#import "NumberedViewController.h"
#import "OpeningViewController.h"
#import "StoryViewController.h"
#import "CreateNewUserViewController.h"
#import "CameraViewController.h"
#import "InterestDemoViewController.h"
#import "Parse/Parse.h"
#import "ParseManager.h"

//static const CGFloat kUIPageControlHeight = 36.f;

@interface PageViewController ()
@property (nonatomic) UIPageControl *pageControl;
@end

@implementation PageViewController


+(instancetype)sharedPageViewController {
    static PageViewController *manager = nil;
    if (!manager)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        manager = [storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    }
    return manager;
}


- (id)initWithViewControllers:(NSArray *)viewControllers transitionStyle:(UIPageViewControllerTransitionStyle)style;
{
    if (self = [super initWithTransitionStyle:style
                        navigationOrientation:UIPageViewControllerNavigationOrientationVertical
                                      options:nil]) {
        for (id object in viewControllers) {
            if (![object isKindOfClass:[UIViewController class]]) {
                [NSException raise:@"One of these is not a view controller" format:@""];
                return nil;
            }
        }
        self.controllers = viewControllers;
        NSLog(@"%@", self.controllers);
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}



- (id)initWithViewControllerClassNames:(NSArray *)classNames transitionStyle:(UIPageViewControllerTransitionStyle)style;

{
  //  return [self.storyboard instantiateViewControllerWithIdentifier:[self.controllers objectAtIndex:];
    return [self initWithViewControllers:[self createViewControllersWithClassNames:classNames]
                         transitionStyle:style];
}

- (NSArray *)createViewControllersWithClassNames:(NSArray *)classNames;
{
    NSMutableArray *newControllers = NSMutableArray.new;
    for (NSString *className in classNames) {
        UIViewController *controller = NSClassFromString(className).new;
        if ([controller isKindOfClass:[UIViewController class]]) {
            [newControllers addObject:controller];
        } else {
            NSLog(@"Could not create controller with class name: %@", className);
        }
    }
    return newControllers.copy;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_blur_map"]];
//    self.pageControl = [UIPageControl new];
//    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
//    [self.pageControl addTarget:self
//                         action:@selector(pageControlWasTapped:)
//               forControlEvents:UIControlEventValueChanged];
    self.pageControl.numberOfPages = self.controllers.count;
    self.pageControl.currentPage = 0;
    UIViewController* first = self.controllers[0];
    [self.view addSubview:self.pageControl];
    [self setViewControllers:@[first]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    self.delegate = self;
    self.dataSource = self;
}



- (void)viewDidAppear:(BOOL)animated
{
//    if ([PFUser currentUser] != nil)
//    {
//        [self performSegueWithIdentifier:@"donsWildRide" sender:self];
//        
//    }
}


- (NSUInteger)currentPageIndex
{
    return [self.controllers indexOfObject:self.viewControllers[0]];
}

#pragma mark - UIPageViewController Data Source and Delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isMemberOfClass:[CreateNewUserViewController class]]) {
        CreateNewUserViewController * createVC = [self.controllers objectAtIndex:[self.controllers indexOfObject:viewController]];
        if (createVC.signedUp) {
            
            NSInteger nextIndex = [self.controllers indexOfObject:viewController] + 1;
            return (nextIndex < self.controllers.count) ? self.controllers[nextIndex] : nil;
        }
        else{
            return nil;
        }
    }
    else
    {
        NSInteger nextIndex = [self.controllers indexOfObject:viewController] + 1;
        return (nextIndex < self.controllers.count) ? self.controllers[nextIndex] : nil;
    }
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger previousIndex = [self.controllers indexOfObject:viewController] - 1;
    if (previousIndex >= 2)
    {
        return nil;
    }
    else
    {
        return (previousIndex >= 0) ? self.controllers[previousIndex] : nil;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed;
{
    self.pageControl.currentPage = self.currentPageIndex;
}

#pragma mark - UIPageControl Action

-(void)signUpWasSuccesful
{
    [self setViewControllers:@[self.controllers[3]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

@end
