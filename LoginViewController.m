//
//  LoginViewController.m
//  Symeetry
//
//  Created by Charles Northup on 4/16/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "ParseManager.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *comfirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.passwordTextField.secureTextEntry = YES;
    self.comfirmPasswordTextField.secureTextEntry = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([PFUser currentUser] != nil) {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }
}

- (IBAction)onLoginButtonPressed:(id)sender
{
    [ParseManager logInOrSignUp:self.usernameTextField.text
                       password:self.passwordTextField.text
                     comfirming:self.comfirmPasswordTextField.text
                          email:self.emailTextField.text
                completionBlock:^{
                    
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];

    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

@end
