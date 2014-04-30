//
//  ResetPasswordViewController.m
//  Symeetry
//
//  Created by user on 4/29/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "ParseManager.h"
#import "Parse/Parse.h"

@interface ResetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *changePassButton;

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.passwordTextField.secureTextEntry = YES;
    self.confirmPasswordTextField.secureTextEntry = YES;
    // Do any additional setup after loading the view.
}

- (IBAction)onChangePassButtonPressed:(id)sender
{
    self.changePassButton.enabled = NO;
    if ([self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        [ParseManager saveInfo:[ParseManager currentUser] objectToSet:self.passwordTextField.text forKey:@"password" completionBlock:^{
            UIAlertView* success = [[UIAlertView alloc] initWithTitle:@"Change Successfull" message:nil delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [success show];
            self.changePassButton.enabled = YES;
        }];
    }
    else{
        UIAlertView* fail = [[UIAlertView alloc] initWithTitle:@"Change Failled" message:@"The passwords did not match" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [fail show];
        self.changePassButton.enabled = YES;
    }
}

@end
