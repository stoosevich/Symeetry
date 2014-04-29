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


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

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
    self.options = @[@"Profile", @"Settings", @"Report", @"About", @"Logout", @"", @"", @"", @"", @"",
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
    if (indexPath.row == 1) {
        
    }
}


@end
