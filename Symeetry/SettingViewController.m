//
//  SettingViewController.m
//  Symeetry
//
//  Created by user on 4/29/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "SettingViewController.h"

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_blur_map"]];
    self.settings = @[@"Change Password", @"Delete Account", @"Configure UUIDs"];
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
    
    NSLog(@"index path %i", indexPath.row);
    
    if (indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"showResetPassword" sender:self];
    }
    else if (indexPath.row == 1)
    {
        
    }
    else if (indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"showUUIDs" sender:self];
        
    }
    
}
- (IBAction)onBackButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];

}



@end
