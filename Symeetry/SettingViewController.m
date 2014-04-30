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
@property NSArray* settings;
@property (strong, nonatomic) IBOutlet UIButton *backButton;

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
    self.settings = @[@"Change Password", @"Delete Account", @"Opt-Out",@"Configure UUIDs", @"Reset UUIDs to Default"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_blur_map"]];
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
        [ParseManager optOut];
        [[ChatManager sharedChatManager] checkoutChat];
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
