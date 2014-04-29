//
//  MenuViewController.m
//  Symeetry
//
//  Created by Charles Northup on 4/28/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "MenuViewController.h"


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

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
    // Do any additional setup after loading the view.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemReuseID"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Settings";
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = @"Logout";
    }
    else if(indexPath.row == 99)
    {
        cell.textLabel.text = @"Loom™?";
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

@end
