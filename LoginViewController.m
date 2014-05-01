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
#import "PageViewController.h"
#import "OpeningViewController.h"
#import "CameraViewController.h"
#import "CreateNewUserViewController.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
//@property (weak, nonatomic) IBOutlet UITextField *comfirmPasswordTextField;
//@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;

@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CALayer *signUPButtonLayer = [self.signUpButton layer];
    [signUPButtonLayer setMasksToBounds:YES];
    [signUPButtonLayer setCornerRadius:5.0f];
    
    CALayer *loginButtonLayer = [self.loginButton layer];
    [loginButtonLayer setMasksToBounds:YES];
    [loginButtonLayer setCornerRadius:5.0f];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_blur_map"]];
    self.passwordTextField.secureTextEntry = YES;
 //   self.comfirmPasswordTextField.secureTextEntry = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([PFUser currentUser] != nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)onLoginButtonPressed:(id)sender
{
    self.loginButton.enabled = NO;
    [ParseManager logIn:self.usernameTextField.text password:self.passwordTextField.text completionBlock:^{
        self.passwordTextField.text = @"";
        self.usernameTextField.text = @"";
        self.loginButton.enabled = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    } failedBlock:^{
        self.loginButton.enabled = YES;
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}
- (IBAction)onSignUpButtonPressed:(id)sender
{
    NSMutableArray *viewControllers = NSMutableArray.new;
    
    //get a reference to the storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    OpeningViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"OpeningViewController"];
    [viewControllers addObject:vc];
    
    UIViewController* storyViewController = [storyboard instantiateViewControllerWithIdentifier:@"StoryViewController"];
    [viewControllers addObject:storyViewController];
    
    CreateNewUserViewController* createViewController = [storyboard instantiateViewControllerWithIdentifier:@"CreateNewUserViewController"];
    createViewController.signedUp = NO;
    [viewControllers addObject:createViewController];
    
    UIViewController* biographyViewController = [storyboard instantiateViewControllerWithIdentifier:@"BiographyViewController"];
    [viewControllers addObject:biographyViewController];
    
    UIViewController* cameraViewController = [CameraViewController sharedCameraViewController];
    [viewControllers addObject:cameraViewController];
    
    UIViewController* interestDemoViewController = [storyboard instantiateViewControllerWithIdentifier:@"InterestDemoViewController"];
    [viewControllers addObject:interestDemoViewController];
    
    PageViewController* pvc = [PageViewController sharedPageViewController];
    pvc.controllers = viewControllers;
    [pvc setViewControllers:@[viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self presentViewController:pvc animated:YES completion:nil];
}

@end
