//
//  AppDelegate.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/14/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "AvailableUsersViewController.h"
#import "ChatManager.h"
#import "PageViewController.h"
#import "NumberedViewController.h"
#import "OpeningViewController.h"
#import "StoryViewController.h"
#import "CreateNewUserViewController.h"
#import "CameraViewController.h"
#import "InterestDemoViewController.h"
#import "ContainerViewController.h"
#import "MenuViewController.h"
#import "MMDrawerController.h"

@interface AppDelegate()

@property (nonatomic) NSUserDefaults *standardDefaults;
@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{


    [Parse setApplicationId:@"1iPVJY5CmOx54bzcklwgtQn8wswi0H5ipKfisuJ8"
                  clientKey:@"fXgWT23ACGa7uOPagCsaEuBM1xu8bOjWSGWFwTKF"];
    
    //intialize a location manager to be notified of state transitions. We need this in the app
    //delegate to handle the call back from the delegate when the app is not active
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    //initialize the set of regions we have seen
    self.regionsMonitored = [NSMutableSet new];
    
    //determines how often the app receives updates. This is the minimum number of seconds that must
    //elapse before another background fetch is initiated
    [[UIApplication sharedApplication]setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    
  
    
    self.standardDefaults = [NSUserDefaults standardUserDefaults];
    
    //PageView Controller
      NSMutableArray *viewControllers = NSMutableArray.new;
////    for (int i = 1; i <= 10; i++) {
////       [viewControllers addObject:[NumberedViewController.alloc initWithNumber:@(i)]];
////    }
//    
//    //get a reference to the storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];

    OpeningViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"OpeningViewController"];
    [viewControllers addObject:vc];
    
    UIViewController* storyViewController = [storyboard instantiateViewControllerWithIdentifier:@"StoryViewController"];
    [viewControllers addObject:storyViewController];
    
    UIViewController* createViewController = [storyboard instantiateViewControllerWithIdentifier:@"CreateNewUserViewController"];
    [viewControllers addObject:createViewController];
    
    UIViewController* cameraViewController = [storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    [viewControllers addObject:cameraViewController];
    
    UIViewController* interestDemoViewController = [storyboard instantiateViewControllerWithIdentifier:@"InterestDemoViewController"];
    [viewControllers addObject:interestDemoViewController];
    
    UIViewController* containerViewController = [storyboard instantiateViewControllerWithIdentifier:@"ContainerViewController"];
    [viewControllers addObject:containerViewController];
    
    UIViewController* photoViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    [viewControllers addObject:photoViewController];

    
    PageViewController* pvc = [storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    
    UIViewController* login = [storyboard instantiateViewControllerWithIdentifier:@"RootNavController"];
    UIViewController* menu = [storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    
    MMDrawerController* drawerController = [[MMDrawerController alloc]
                                            initWithCenterViewController:containerViewController
                                            leftDrawerViewController:menu];
    [drawerController setMaximumLeftDrawerWidth:180];
    drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    
    self.window.rootViewController = drawerController;
    
    
    
//    self.window = [UIWindow.alloc initWithFrame:UIScreen.mainScreen.bounds];
//    self.window.backgroundColor = [UIColor colorWithRed:186.f/255.f green:228.f/255.f blue:217.f/255.f alpha:1];
//    self.window.rootViewController = [PageViewController.alloc initWithViewControllerClassNames:@[@"OpeningViewController", @"StoryViewController", @"CreateNewUserViewController", @"CameraViewController",@"InterestDemoViewController"] transitionStyle:UIPageViewControllerTransitionStyleScroll];
//    [self.window makeKeyAndVisible];

    //[PFUser logOut];
    
    [PFUser logInWithUsernameInBackground:@"dennis" password:@"password"];
    
    return YES;
}

/*
 * Monitor location manager for state changes, send a notifcation if the region has been
 * entered/exited
 */
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
   
    
    //if we enter a region, and we have not been notified about that region in the last 24 hours, post a local notication
    if(state == CLRegionStateInside)
    {

        //always post a global notification for the app to respond too
        [self postGlobalNotificationOnRegionEntry:region withState:state];
        
        //get the region from the user defaults
        NSDictionary* regionFound = [self.standardDefaults objectForKey:region.identifier];

        //if we have not stored this region already,then show a local notifcation
        if (!regionFound)
        {
            [self postLocalNotificationOnRegionEntry:region withState:state];
            [self addRegionToUserDefaults:region];
        }
        else if(regionFound)
        {

            //check if the timestamp is more then 24 hours old
            NSDate* entryDate =[self.standardDefaults objectForKey:region.identifier][@"date"];
            if ([entryDate timeIntervalSinceNow] < -86400.00f)
            {
                [self postLocalNotificationOnRegionEntry:region withState:state];
                
                //add region to list of notified regions
                [self addRegionToUserDefaults:region];
            }
        }

    }
    else if(state == CLRegionStateOutside)
    {
        return;
    }
    else
    {
        return;
    }
}

- (void)postLocalNotificationOnRegionEntry:(CLRegion*)region withState:(CLRegionState)state
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertBody = [NSString stringWithFormat:@"iBeacon found"];
    //notification.soundName = UILocalNotificationDefaultSoundName;  //play a chime sound
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}


- (void)postGlobalNotificationOnRegionEntry:(CLRegion*)region withState:(CLRegionState)state
{
    
    //create dictionary to pass the region identifier and state
    NSDictionary* notificationInfo = @{@"identifier":region.identifier, @"state":@"CLRegionStateInside"};
    
    //post the local notifcation to the notification center so the appropiate observer can respond
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CLRegionStateInsideNotification" object:self userInfo:notificationInfo];
    

}

- (void)addRegionToUserDefaults:(CLRegion*)region
{
    //add region to list of notified regions
    NSDate* currentDate = [NSDate date];
    NSDictionary* defaults = @{@"region":region.identifier , @"date":currentDate};
    [self.standardDefaults setObject:defaults forKey:region.identifier]; //store the data encountered
    [self.standardDefaults synchronize];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    // If the application is in the foreground, we could notify the user of the region's state via an alert.
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    [[ChatManager sharedChatManager] checkoutChat];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    [[ChatManager sharedChatManager] checkoutChat];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
