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
@property (weak, nonatomic) IBOutlet UIView* textFieldGroup;
@property int spacing;
@property BOOL didStartEditing;

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
    self.passwordTextField.secureTextEntry = YES;
    self.comfirmpasswordTextField.secureTextEntry = YES;
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    self.didStartEditing = NO;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.usernameTextField endEditing:YES];
    [self.emailTextField endEditing:YES];
    [self.comfirmpasswordTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];


}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        [textField endEditing:YES];
        [self.signUpButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [self.comfirmpasswordTextField becomeFirstResponder];
    }
    else if (textField == self.comfirmpasswordTextField) {
        [self.emailTextField becomeFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.didStartEditing == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            self.textFieldGroup.frame = CGRectMake(self.textFieldGroup.frame.origin.x, -85, self.textFieldGroup.frame.size.width, self.textFieldGroup.frame.size.height);
        }];
        self.didStartEditing = YES;
    }
}

- (IBAction)onSignUpButtongPressed:(id)sender
{
    self.signUpButton.enabled = NO;
    self.signUpButton.alpha = 0.4;
    if ((![self.usernameTextField.text isEqualToString:@""])&&
        (![self.passwordTextField.text isEqualToString:@""])&&
        ([self.passwordTextField.text isEqualToString:self.comfirmpasswordTextField.text])&&
        (![self.emailTextField.text isEqualToString:@""]))
    {
        PFUser* newUser = [PFUser new];
        [newUser setPassword:self.passwordTextField.text];
        [newUser setUsername:self.usernameTextField.text];
        [newUser setEmail:self.emailTextField.text];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [newUser setObject:@(0) forKey:@"similarityIndex"];
                   // [newUser setObject:[ParseManager convertUIImageToPFFile:[Utilities resizeImage:[UIImage imageNamed:@"ic_welcome_profile.png"] withWidth:40 andHeight:40]] forKey:@"thumbnail"];
                    [newUser setObject:@NO forKey:@"gender"];
                    [newUser setObject:@(0) forKey:@"age"];
                    [newUser setObject:@"" forKey:@"biography"];
                    [newUser setObject:@NO forKey:@"hidden"];
                    [newUser setObject:@"NOT_INITIALIZED" forKey:@"nearestBeacon"];
                    [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            PFObject* interest = [PFObject objectWithClassName:@"Interests"];
                            [interest setObject:newUser.objectId forKey:@"userid"];
                            [interest setObject:newUser forKey:@"user"];
                            [interest setObject:@(0) forKey:@"movies"];
                            [interest setObject:@(0) forKey:@"music"];
                            [interest setObject:@(0) forKey:@"food"];
                            [interest setObject:@(0) forKey:@"school"];
                            [interest setObject:@(0) forKey:@"dancing"];
                            [interest setObject:@(0) forKey:@"books"];
                            [interest setObject:@(0) forKey:@"tv"];
                            [interest setObject:@(0) forKey:@"art"];
                            [interest setObject:@(0) forKey:@"technology"];
                            [interest setObject:@(0) forKey:@"games"];
                            [interest setObject:@(0) forKey:@"fashion"];
                            [interest setObject:@(0) forKey:@"volunter"];
                            [interest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    [newUser setObject:interest forKey:@"interests"];
                                    [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                        if (succeeded) {
                                            [newUser setObject:[ParseManager convertUIImageToPFFile:[UIImage imageNamed:@"ic_welcome_profile.png"]] forKey:@"photo"];
                                            NSLog(@"sined up");
                                            self.signedUp = YES;
                                            UIAlertView* created = [[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Your account has been created succesfully" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
                                            [created show];
                                            self.signUpButton.hidden = YES;
                                            [[PageViewController sharedPageViewController] signUpWasSuccesful];
                                            [newUser saveInBackground];
                                            [newUser setObject:[ParseManager convertUIImageToPFFile:[Utilities resizeImage:[UIImage imageNamed:@"ic_welcome_profile.png"] withWidth:40 andHeight:40]] forKey:@"thumbnail"];
                                            [newUser saveInBackground];
                                        }
                                    }];
                                }
                            }];
                        }
                    }];
                }
            }];

        });
    }
    self.signUpButton.alpha = 1.0;
    self.signUpButton.enabled = YES;
}

-(void)raiseUserNameTakenAlert
{
    UIAlertView* taken = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"That username and/or email is taken, please try different one" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [taken show];
}

-(void)raiseParseErrorAlert:(NSError*)error
{
    NSString* errorString = [NSString stringWithFormat:@"An error has occured, please try again\n: %@",[error userInfo]];
    
    //raise alert with Parse error message
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}
@end
