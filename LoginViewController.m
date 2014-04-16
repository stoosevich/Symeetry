//
//  LoginViewController.m
//  Symeetry
//
//  Created by Charles Northup on 4/16/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.passwordTextField.secureTextEntry = YES;
    //[PFUser logOut];
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([PFUser currentUser] != nil) {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }
}

- (IBAction)onLoginButtonPressed:(id)sender
{
    [PFUser logInWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
    if ([[[PFUser currentUser] username] isEqualToString:@"charles"]) {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

@end
