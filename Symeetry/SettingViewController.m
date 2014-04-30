//
//  SettingViewController.m
//  Symeetry
//
//  Created by user on 4/29/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "SettingViewController.h"
#import "Defaults.h"
#import "ParseManager.h"
#import "ChatManager.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>
@property NSMutableArray* settings;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property BOOL checkedIN;

@end

@implementation SettingViewController

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_blur_map"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.checkedIN =! [ChatManager sharedChatManager].on;
    if (self.checkedIN) {
        self.settings = [NSMutableArray arrayWithArray:@[@"Change Password", @"Delete Account", @"Opt-In",@"Configure UUIDs", @"Reset UUIDs to Default"]];
    }
    else{
        self.settings = [NSMutableArray arrayWithArray:@[@"Change Password", @"Delete Account", @"Opt-Out",@"Configure UUIDs", @"Reset UUIDs to Default"]];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.settings.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCellId"];
    cell.textLabel.text = self.settings[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //change password
    if (indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"showResetPassword" sender:self];
    }
    else if (indexPath.row == 1)//delete account
    {
        
    }
    else if (indexPath.row == 2)//opt-out
    {
        self.checkedIN =! self.checkedIN;
        if (self.checkedIN) {
            self.settings = [NSMutableArray arrayWithArray:@[@"Change Password", @"Delete Account", @"Opt-In",@"Configure UUIDs", @"Reset UUIDs to Default"]];
            NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [self.settingsTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
            [ParseManager optOut];
            [[ChatManager sharedChatManager] checkoutChat];
            [ChatManager sharedChatManager].on = NO;
        }
        else{
            self.settings = [NSMutableArray arrayWithArray:@[@"Change Password", @"Delete Account", @"Opt-Out",@"Configure UUIDs", @"Reset UUIDs to Default"]];
            NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [self.settingsTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationRight];
            [ParseManager optIn];
            [[ChatManager sharedChatManager] checkinChat];
            [ChatManager sharedChatManager].on = YES;
        }
        

    }
    else if (indexPath.row == 3)//configure UUID
    {
        [self performSegueWithIdentifier:@"showUUIDs" sender:self];
    }
    else if (indexPath.row == 4) //reset UUIDs to default
    {
        [[Defaults sharedDefaults] resetToDefaultUUIDs];
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Reset Defaults" message:@"UUIDs reset to defaults" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}
- (IBAction)onBackButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];

}



@end
