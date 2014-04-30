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
@property int easterEgg;
@property BOOL unlocked;
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
    self.easterEgg = 0;
    self.unlocked = NO;
    self.myTableView.scrollsToTop = YES;
    self.myTableView.frame = CGRectMake(0, 0, 180, self.myTableView.frame.size.height);
    self.options = @[@"My Profile", @"Settings", @"About", @"Logout", @"Loom™"];
    // Do any additional setup after loading the view.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemReuseID"];
    if ((indexPath.row == self.options.count-1)&&(self.unlocked)) {
        cell.textLabel.text = self.options[indexPath.row];
    }
    else if (indexPath.row != self.options.count-1){
        cell.textLabel.text = self.options[indexPath.row];
    }
    else{
        cell.textLabel.text = @"";
    }
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


    if (indexPath.row == 3)
    {
        [PFUser logOut];
        
        MMDrawerController* draw = (id)self.view.window.rootViewController;
        [draw toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        UIViewController* login = [self.storyboard instantiateViewControllerWithIdentifier:@"RootNavController"];
        [self presentViewController:login animated:YES completion:nil];
        
        [ChatManager sharedChatManager].on = NO;
        [[ChatManager sharedChatManager] checkoutChat];

    }
    else if(indexPath.row == self.options.count - 1)
    {
        if (self.unlocked) {
            UIAlertView* ask = [[UIAlertView alloc] initWithTitle:@"Loom™?" message:@"Ask Charles" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [ask show];
        }
    }
    else if (indexPath.row == 2)
    {
        if ((self.easterEgg == 0)||(self.easterEgg == 3)||(self.easterEgg == 5)) {
            self.easterEgg ++;
        }
        else{
            self.easterEgg = 0;
        }
        UIViewController* aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
        [self presentViewController:aboutViewController animated:YES completion:nil];
    }
    else if (indexPath.row == 0)
    {
        if ((self.easterEgg == 1)||(self.easterEgg == 2)||(self.easterEgg == 6)) {
            self.easterEgg ++;
            if (self.easterEgg == 7) {
                self.unlocked = YES;
                NSIndexPath* path = [NSIndexPath indexPathForRow:(self.options.count -1) inSection:0];
                [self.myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
            }
        }
        else
        {
            self.easterEgg = 0;
        }
    }
    else if(indexPath.row == 1)
    {
        if (self.easterEgg == 4) {
            self.easterEgg++;
        }
        else
        {
            self.easterEgg = 0;
        }
        
    }
}


@end
