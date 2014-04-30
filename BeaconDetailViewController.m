//
//  BeaconDetailViewController.m
//  Symeetry
//
//  Created by user on 4/27/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "BeaconDetailViewController.h"

@interface BeaconDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *uuid1TextField;
@property (weak, nonatomic) IBOutlet UITextField *uuid2TextField;
@property (weak, nonatomic) IBOutlet UITextField *uuid3TextField;
@property (weak, nonatomic) IBOutlet UITextField *uuid4TextField;
@property (weak, nonatomic) IBOutlet UITextField *uuid5TextField;

@property (weak, nonatomic) IBOutlet UITextField *majorTextField;
@property (weak, nonatomic) IBOutlet UITextField *minorTextField;
@property (weak, nonatomic) IBOutlet UITextField *powerTextField;

@property NSArray *components;
@end

@implementation BeaconDetailViewController

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
    
    
    if (self.proximityUUID != nil)
    {
        NSString* string = [self.proximityUUID UUIDString];
        self.components = [string componentsSeparatedByString: @"-"];
        
        self.uuid1TextField.text = self.components[0];
        self.uuid2TextField.text = self.components[1];
        self.uuid3TextField.text = self.components[2];
        self.uuid4TextField.text = self.components[3];
        self.uuid5TextField.text = self.components[4];
    }
    
}


@end
