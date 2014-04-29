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

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.passwordTextField.secureTextEntry = YES;
 //   self.comfirmPasswordTextField.secureTextEntry = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([PFUser currentUser] != nil) {
        
        //[self performSegueWithIdentifier:@"LoginSegue" sender:self];
        [self dismissViewControllerAnimated:YES completion:nil];
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
- (IBAction)onSignUpButtonPressed:(id)sender
{
    NSMutableArray *viewControllers = NSMutableArray.new;
    //    for (int i = 1; i <= 10; i++) {
    //       [viewControllers addObject:[NumberedViewController.alloc initWithNumber:@(i)]];
    //    }
    
    //get a reference to the storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    OpeningViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"OpeningViewController"];
    [viewControllers addObject:vc];
    
    UIViewController* storyViewController = [storyboard instantiateViewControllerWithIdentifier:@"StoryViewController"];
    [viewControllers addObject:storyViewController];
    
//    UIViewController* createViewController = [storyboard instantiateViewControllerWithIdentifier:@"CreateNewUserViewController"];
//    [viewControllers addObject:createViewController];
    
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
