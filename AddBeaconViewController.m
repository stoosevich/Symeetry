//
//  AddBeaconViewController.m
//  Symeetry
//
//  Created by user on 4/27/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "AddBeaconViewController.h"
#import "Defaults.h"

@interface AddBeaconViewController () <UITextFieldDelegate, UIAlertViewDelegate>

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
    NSUUID* uuid = [self createUUIDFromTextFields];
    
    if(uuid == nil)
    {
        return;
    }
    
    [[[Defaults sharedDefaults]supportedProximityUUIDs] addObject:uuid];
    
    [[Defaults sharedDefaults]saveUUIDListToFile];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Save" message:@"Data saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
}


-(NSUUID*)createUUIDFromTextFields
{

    if (![self validateTextFieldInputs])
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Invalid Entry" message:@"UUID is not in valid format" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
        return nil;
    }
    
    NSString *uuidFormatString = NSLocalizedString(@"%@-%@-%@-%@-%@", @"Format string for uuid");
    NSString* uuidString = [NSString stringWithFormat:uuidFormatString,self.uuid1TextField.text, self.uuid2TextField.text, self.uuid3TextField.text, self.uuid4TextField.text,self.uuid5TextField.text];
    
    //convert to uppercase for storage
    uuidString = [uuidString uppercaseString];
    return [[NSUUID alloc]initWithUUIDString:uuidString];
}


//make sure the uuid is valid
- (BOOL)validateTextFieldInputs
{
    if (self.uuid1TextField.text.length != 8)
    {
        return FALSE;
    }
    else if (self.uuid2TextField.text.length != 4 ||
             self.uuid3TextField.text.length != 4 ||
             self.uuid4TextField.text.length != 4 )
    {
        return FALSE;
    }
    else if (self.uuid5TextField.text.length != 12)
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && [alertView.title isEqualToString:@"Invalid Entry"])
    {
        if (self.uuid1TextField.text.length != 8)
        {
            self.uuid1TextField.backgroundColor = [UIColor lightGrayColor];
        }
        
        if (self.uuid2TextField.text.length != 4)
        {
            self.uuid2TextField.backgroundColor = [UIColor lightGrayColor];
        }
        
        
        if(self.uuid3TextField.text.length != 4)
        {
            self.uuid3TextField.backgroundColor = [UIColor lightGrayColor];
        }
        
        
        if(self.uuid4TextField.text.length != 4 )
        {
            self.uuid4TextField.backgroundColor = [UIColor lightGrayColor];
        }
        if (self.uuid5TextField.text.length != 12)
        {
            self.uuid5TextField.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
}

@end
