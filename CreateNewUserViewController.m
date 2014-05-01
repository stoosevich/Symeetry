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


@interface CreateNewUserViewController () <UITextFieldDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *comfirmpasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIView* textFieldGroup;
@property int spacing;
@property BOOL didStartEditing;
@property PFObject* myNewlyCreatedUsersInterests;

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
    self.signUpButton.enabled = NO;
    self.signUpButton.alpha = 0.4;
    
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
    if ((![self.usernameTextField.text isEqualToString:@""])&&
        (![self.passwordTextField.text isEqualToString:@""])&&
        ([self.passwordTextField.text isEqualToString:self.comfirmpasswordTextField.text])&&
        (![self.emailTextField.text isEqualToString:@""]))
    {
        PFUser* newUser = [PFUser new];
        [newUser setPassword:self.passwordTextField.text];
        [newUser setUsername:self.usernameTextField.text];
        [newUser setEmail:self.emailTextField.text];
        
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    dispatch_async(dispatch_get_main_queue(), ^{

                    [newUser setObject:@(0) forKey:@"similarityIndex"];
                   // [newUser setObject:[ParseManager convertUIImageToPFFile:[Utilities resizeImage:[UIImage imageNamed:@"ic_welcome_profile.png"] withWidth:40 andHeight:40]] forKey:@"thumbnail"];
                    PFGeoPoint* point = [PFGeoPoint geoPointWithLatitude:51.5072 longitude:-0.1275];
                    PFObject* newInterest = [PFObject objectWithClassName:@"Interests"];
                    [[PFUser currentUser] setObject:@NO forKey:@"gender"];
                    [[PFUser currentUser] setObject:@(0) forKey:@"age"];
                    [[PFUser currentUser] setObject:@"" forKey:@"biography"];
                    [[PFUser currentUser] setObject:@NO forKey:@"hidden"];
                    [[PFUser currentUser] setObject:@"NOT_INITIALIZED" forKey:@"nearestBeacon"];
                    [[PFUser currentUser] setObject:point forKey:@"location"];
                    [[PFUser currentUser] setObject:newInterest forKey:@"interests"];
                    
                    [[PFUser currentUser] save];
                        
                        [self getSignedUpInterest:^{
                            NSLog(@"sined up");
                            self.signedUp = YES;
                            UIAlertView* created = [[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Your account has been created succesfully" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
                            [created show];
                            self.signUpButton.hidden = YES;
                            [[PageViewController sharedPageViewController] signUpWasSuccesful];
                            
                        }];

                    });

                }
                UIAlertView* invalidSignUp = [[UIAlertView alloc] initWithTitle:@"Invalid SignUp" message:@"The username and/or email has been taken or the email is invalid. Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [invalidSignUp show];
            }];
    }
    else
    {
        UIAlertView* invalidEntry = [[UIAlertView alloc] initWithTitle:@"Invalid SignUp" message:@"The information you entered was not valid. Please check that your passwords match and that now feild was left blank" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [invalidEntry show];
    }

    self.signUpButton.alpha = 1.0;
    self.signUpButton.enabled = YES;
}

-(void)getNewlyUsersInterests:(void(^)(PFObject* object, NSError* error)) completion
{
    NSLog(@"Getting Interests");
    [ParseManager getUserInterest:[PFUser currentUser]
                   WithCompletion:^(PFObject *object, NSError *error) {
                       completion(object, error);
                   }];
}

-(void)getSignedUpInterest:(void(^)(void))block
{
    [self getNewlyUsersInterests:^(PFObject *object, NSError *error) {
        self.myNewlyCreatedUsersInterests = object;
        [self.myNewlyCreatedUsersInterests setObject:[PFUser currentUser] forKey:@"user"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"movies"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"music"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"food"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"school"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"dancing"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"books"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"tv"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"art"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"technology"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"games"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"fashion"];
        [self.myNewlyCreatedUsersInterests setObject:@(0) forKey:@"volunteer"];
        [self.myNewlyCreatedUsersInterests saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    block();
        }];
    }];
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
