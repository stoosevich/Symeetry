//
//  CreateNewUserViewController.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/26/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "CreateNewUserViewController.h"
#import "Parse/Parse.h"
#import "PageViewController.h"
#import "ParseManager.h"
#import "Utilities.h"


@interface CreateNewUserViewController () <UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *comfirmpasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end

@implementation CreateNewUserViewController

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


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

- (IBAction)onSignUpButtongPressed:(id)sender
{
    if ((![self.usernameTextField.text isEqualToString:@""])&&
        (![self.passwordTextField.text isEqualToString:@""])&&
        ([self.passwordTextField.text isEqualToString:self.comfirmpasswordTextField.text])&&
        (![self.emailTextField.text isEqualToString:@""]))
    {
        PFUser* newUser = [PFUser new];
        [newUser setPassword:self.passwordTextField.text];
        [newUser setUsername:self.usernameTextField.text];
        [newUser setEmail:self.emailTextField.text];
        [newUser setObject:[ParseManager convertUIImageToPFFile:[UIImage imageNamed:@"ic_welcome_profile.png"]] forKey:@"photo"];
        [newUser setObject:[ParseManager convertUIImageToPFFile:[Utilities resizeImage:[UIImage imageNamed:@"ic_welcome_profile.png"] withWidth:40 andHeight:40]] forKey:@"thumbnail"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError* error = [NSError new];
            [newUser signUp:&error];
            if (!error)
            {
                UIAlertView* taken = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"That username and/or email is taken, please try different one" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
                [taken show];
            }
            else
            {
                NSLog(@"sined up");
                self.signedUp = YES;
                UIAlertView* created = [[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Your account has been created succesfully" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
                [created show];
                self.signUpButton.hidden = YES;
                [[PageViewController sharedPageViewController] signUpWasSuccesful];
            }
        });


    }
}


@end
