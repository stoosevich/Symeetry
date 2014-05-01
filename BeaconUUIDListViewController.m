//
//  BeaconUUIDListViewController.m
//  Symeetry
//
//  Created by user on 4/27/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "BeaconUUIDListViewController.h"
#import "BeaconDetailViewController.h"

#import "Defaults.h"

@interface BeaconUUIDListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property NSMutableArray* beacons;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation BeaconUUIDListViewController

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
    
    //get the uuid from the default manager
    _beacons = [Defaults sharedDefaults].supportedProximityUUIDs;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.myTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.beacons.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconListID"];
    cell.textLabel.text = [self.beacons[indexPath.row] UUIDString];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.beacons removeObjectAtIndex:indexPath.row];
        [self.myTableView reloadData];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell*)sender
{
    
    if ([segue.identifier isEqualToString:@"showDetailView"])
    {
        BeaconDetailViewController* vc = segue.destinationViewController;
        //pass the uuid
        NSIndexPath* indexPath = [self.myTableView indexPathForCell:sender];
        vc.proximityUUID = self.beacons[indexPath.row];
    }

}

@end
