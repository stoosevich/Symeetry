//
//  AppDelegate.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/14/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "HomeViewController.h"
#import "ChatManager.h"

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

    
    //[PFUser logInWithUsername:@"dennis" password:@"password"];
    
    self.standardDefaults = [NSUserDefaults standardUserDefaults];
    
    return YES;
}

/*
 * Monitor location manager for state changes, send a notifcation if the region has been
 * entered/exited
 */
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
   
    
    //if we enter a region, and the region has not yet been added to the set of montiored regions,
    //then create an alert and add it to the set
    if(state == CLRegionStateInside)
    {
        
        NSDictionary* regionFound = [self.standardDefaults objectForKey:region.identifier];

        //if we have not stored this region already,then show a notifcation
        if (!regionFound)
        {
            [self postNotificationOfRegionEntry:region withState:state];
            [self addRegionToUserDefaults:region];
        }
        else if(regionFound)
        {
            
            //check if the timestamp is more then 24 hours old
            NSDate* entryDate =[self.standardDefaults objectForKey:region.identifier][@"date"];
            
            NSTimeInterval elapsedTime = [entryDate timeIntervalSinceNow];
            
            
            if (elapsedTime < -86400.00f)
            {
                [self postNotificationOfRegionEntry:region withState:state];
                
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

- (void)postNotificationOfRegionEntry:(CLRegion*)region withState:(CLRegionState)state
{
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertBody = [NSString stringWithFormat:@"iBeacon found"];
    //notification.soundName = UILocalNotificationDefaultSoundName;  //play a chime sound
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    //create dictionary to pass the region identifier and state
    NSDictionary* notificationInfo = @{@"identifier":region.identifier, @"state":@"CLRegionStateInside"};
    
    //notification.userInfo = notificationInfo;
    
    //post the local notifcation to the notification center so the appropiate observer can respond
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CLRegionStateInsideNotification" object:self userInfo:notificationInfo];
}

- (void)addRegionToUserDefaults:(CLRegion*)region
{
    //add region to list of notified regions
    NSDate* currentDate = [NSDate date];
    NSDictionary* defaults = @{@"region":region.identifier , @"date":currentDate};
    [self.standardDefaults setObject:defaults forKey:region.identifier]; //store the date encountered
    [self.standardDefaults synchronize];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    // If the application is in the foreground, we will notify the user of the region's state via an alert.
//    NSString *cancelButtonTitle = NSLocalizedString(@"OK", @"Title for cancel button in local notification");
//    NSString *checkinButtonTitle = NSLocalizedString(@"Checkin", @"Title for checkin button in local notification");
//    
//    //the main view controller needs to be the delegate for the notification
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertBody message:notification.alertAction delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:checkinButtonTitle,nil];
//    [alert show];
    
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    [[ChatManager sharedChatManager] checkoutChat];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
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
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
