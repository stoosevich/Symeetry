//
//  MenuViewController.m
//  Symeetry
//
//  Created by Charles Northup on 4/28/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "MenuViewController.h"
#import "Parse/Parse.h"
#import "MMDrawerController.h"
#import "ProfileHeaderView.h"
#import "ChatManager.h"


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property NSArray* options;

@end

@implementation MenuViewController

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
    self.myTableView.scrollsToTop = YES;
    self.myTableView.frame = CGRectMake(0, 0, 180, self.myTableView.frame.size.height);
    self.options = @[@"My Profile", @"Settings", @"Report", @"About", @"Logout", @"", @"", @"", @"", @"",
                   @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",
                   @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",
                   @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",
                   @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",
                   @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",
                   @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",
                   @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",
                   @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",
                   @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",
                   @"", @"", @"", @"", @"", @"", @"", @"", @"", @"Loom™"];
    // Do any additional setup after loading the view.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemReuseID"];
    cell.textLabel.text = self.options[indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.options.count;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"Menu";
//}
//
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, 8, 180, 50);
    myLabel.font = [UIFont boldSystemFontOfSize:18];
    myLabel.text = @"Menu";
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4)
    {
        NSLog(@"set nearest beacon to nil");
        
        [ParseManager updateUserNearestBeacon:nil];
        
        NSTimer* logoutTimer = [[NSTimer alloc]initWithFireDate:[NSDate date] interval:20 target:nil selector:@selector(logoutCurrentUser) userInfo:nil repeats:NO];
        
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:logoutTimer forMode: NSDefaultRunLoopMode];
        
        MMDrawerController* draw = (id)self.view.window.rootViewController;
        [draw toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        UIViewController* login = [self.storyboard instantiateViewControllerWithIdentifier:@"RootNavController"];
        [self presentViewController:login animated:YES completion:nil];
        [ChatManager sharedChatManager].on = NO;
        [[ChatManager sharedChatManager] checkoutChat];
        

    }
    else if(indexPath.row == self.options.count - 1)
    {
        UIAlertView* ask = [[UIAlertView alloc] initWithTitle:@"Loom™?" message:@"Ask Charles" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [ask show];
    }
    else if (indexPath.row == 2)
    {
        UIViewController* aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
        [self presentViewController:aboutViewController animated:YES completion:nil];
    }
}

- (void)logoutCurrentUser
{
    [PFUser logOut];
    NSLog(@"logging out user");
}

@end
