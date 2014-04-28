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
#import "ChatManager.h"

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
        
        //[self performSegueWithIdentifier:@"LoginSegue" sender:self];
        [self performSegueWithIdentifier:@"ShowContainerViewController" sender:self];
    }
}

- (IBAction)onLoginButtonPressed:(id)sender
{
    [ParseManager logIn:self.usernameTextField.text password:self.passwordTextField.text completionBlock:^{
        self.passwordTextField.text = @"";
        self.usernameTextField.text = @"";
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

@end
