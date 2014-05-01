//
//  ForgotPassViewController.m
//  Symeetry
//
//  Created by Charles Northup on 4/30/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ForgotPassViewController.h"
#import "ParseManager.h"

@interface ForgotPassViewController ()<UIAlertViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendPasswordButton;
@property UIAlertView* sent;

@end

@implementation ForgotPassViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CALayer *ssendPasswordButtonLayer = [self.sendPasswordButton layer];
    [ssendPasswordButtonLayer setMasksToBounds:YES];
    [ssendPasswordButtonLayer setCornerRadius:5.0f];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_blur_map"]];
    self.sent = [[UIAlertView alloc]initWithTitle:@"Succes" message:@"Email has been sent, please open it and follow the instructions" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

- (IBAction)onSendPasswordPressed:(id)sender
{
    self.sendPasswordButton.enabled = NO;
    if (![self.emailTextField.text isEqualToString:@""])
    {
        [ParseManager resetUserPasswordByEmail:self.emailTextField.text];
        [self.sent show];
    }
    else{
        UIAlertView* noEmail = [[UIAlertView alloc]initWithTitle:@"Invalid" message:@"email does exist in user database" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noEmail show];
    }
    self.sendPasswordButton.enabled = YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == self.sent) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
