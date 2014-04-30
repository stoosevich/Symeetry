//
//  AddBeaconViewController.m
//  Symeetry
//
//  Created by user on 4/27/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "AddBeaconViewController.h"
#import "Defaults.h"

@interface AddBeaconViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *uuid1TextField;
@property (weak, nonatomic) IBOutlet UITextField *uuid2TextField;
@property (weak, nonatomic) IBOutlet UITextField *uuid3TextField;
@property (weak, nonatomic) IBOutlet UITextField *uuid4TextField;
@property (weak, nonatomic) IBOutlet UITextField *uuid5TextField;

@property (weak, nonatomic) IBOutlet UITextField *majorTextField;
@property (weak, nonatomic) IBOutlet UITextField *minorTextField;
@property (weak, nonatomic) IBOutlet UITextField *powerTextField;

@property NSMutableArray* supportedProximityUUIDs;
@end

@implementation AddBeaconViewController

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
    
    self.supportedProximityUUIDs = [[Defaults sharedDefaults]supportedProximityUUIDs];
    
    NSLog(@"uuids %@", self.supportedProximityUUIDs);
    
    self.uuid1TextField.delegate =  self;
    self.uuid2TextField.delegate =  self;
    self.uuid3TextField.delegate =  self;
    self.uuid4TextField.delegate =  self;
    self.uuid5TextField.delegate =  self;
    
}

- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender
{
    
    [[[Defaults sharedDefaults]supportedProximityUUIDs] addObject:[self createUUIDFromTextFields]];
    
    [[Defaults sharedDefaults]saveUUIDListToFile];
    //NSLog(@"uuids %@", self.supportedProximityUUIDs);
}


-(NSUUID*)createUUIDFromTextFields
{

    NSString *uuidFormatString = NSLocalizedString(@"%@-%@-%@-%@-%@", @"Format string for uuid");
    NSString* uuidString = [NSString stringWithFormat:uuidFormatString,self.uuid1TextField.text, self.uuid2TextField.text, self.uuid3TextField.text, self.uuid4TextField.text,self.uuid5TextField.text];
    
    //convert to uppercase for storage
    uuidString = [uuidString uppercaseString];
    return [[NSUUID alloc]initWithUUIDString:uuidString];
}


//make sure the uuid is valid
- (BOOL)validateTextFieldInputs
{
    if (self.uuid1TextField.text.length < 8)
    {
        return FALSE;
    }
    else if (self.uuid2TextField.text.length < 4 ||
             self.uuid3TextField.text.length < 4 ||
             self.uuid4TextField.text.length < 4 )
    {
        return FALSE;
    }
    else if (self.uuid5TextField.text.length < 12)
    {
        return FALSE;
    }
    
    return TRUE;
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    [[self view] endEditing:YES];
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
