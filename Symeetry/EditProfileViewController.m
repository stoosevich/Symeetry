//
//  EditProfileViewController.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/30/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "EditProfileViewController.h"
#import "UIView+Circlify.h"
#import "ParseManager.h"
#import "Parse/Parse.h"

@interface EditProfileViewController ()<UITextFieldDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *maleButton;
@property (strong, nonatomic) IBOutlet UIButton *femaleButton;
@property (strong, nonatomic) IBOutlet UIButton *changePictureButton;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *ageTextField;
@property (strong, nonatomic) IBOutlet UITextView *bioTextView;
@property (strong, nonatomic) IBOutlet UIView *fullPageView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property BOOL gender;
@property BOOL editingEnabled;

@end

@implementation EditProfileViewController

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
    self.usernameTextField.text = [[PFUser currentUser] username];
    // Do any additional setup after loading the view.
}

- (IBAction)onEditButtonPressed:(id)sender
{
    self.editingEnabled =! self.editingEnabled;
    if (self.editingEnabled)
    {
        self.editButton.titleLabel.text = @"Edit";
        self.backButton.hidden = NO;
        self.femaleButton.enabled = NO;
        self.maleButton.enabled = NO;
        self.bioTextView.userInteractionEnabled = NO;
        self.ageTextField.userInteractionEnabled = NO;
        self.changePictureButton.enabled = NO;
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
            }
        }];
    }
    else
    {
        self.editButton.titleLabel.text = @"Done";
        self.backButton.hidden = YES;
        self.femaleButton.enabled = YES;
        self.maleButton.enabled = YES;
        self.bioTextView.userInteractionEnabled = YES;
        self.ageTextField.userInteractionEnabled = YES;
        self.changePictureButton.enabled = YES;
    }

}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.fullPageView.frame = CGRectMake(self.fullPageView.frame.origin.x, -266, self.fullPageView.frame.size.width, self.fullPageView.frame.size.height);
    }];

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSNumber* newAge = [NSNumber numberWithInt:textField.text.intValue];
    [[PFUser currentUser] setObject:newAge forKey:@"age"];}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.fullPageView.frame = CGRectMake(self.fullPageView.frame.origin.x, -266, self.fullPageView.frame.size.width, self.fullPageView.frame.size.height);
    }];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [[PFUser currentUser] setObject:textView.text forKey:@"biography"];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView endEditing:YES];
    return YES;
}


-(void)viewDidAppear:(BOOL)animated
{
    self.gender = [[ParseManager currentUser]objectForKey:@"gender"];
    if (self.gender) {
        self.maleButton.highlighted = NO;
        self.femaleButton.highlighted = YES;
    }
    else{
        self.maleButton.highlighted = YES;
        self.femaleButton.highlighted = NO;

    }
    self.userImage.image = [[ParseManager currentUser] objectForKey:@"photo"];
    [self.userImage circlify];
    self.bioTextView.text = [[PFUser currentUser]objectForKey:@"biography"];
    self.ageTextField.text = [[[PFUser currentUser] objectForKey:@"age"] description];
}

- (IBAction)onBackButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

- (IBAction)onFemaleButtonPressed:(id)sender
{
    self.gender = YES;
    self.maleButton.highlighted = NO;
    self.femaleButton.highlighted = YES;
    [[PFUser currentUser] setObject:@YES forKey:@"gender"];

}

- (IBAction)onMaleButtonPressed:(id)sender
{
    self.gender = NO;
    self.maleButton.highlighted = YES;
    self.femaleButton.highlighted = NO;
    [[PFUser currentUser] setObject:@NO forKey:@"gender"];
}



- (IBAction)onChangePictureButtonPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController* photoViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    photoViewController.editing = YES;
    [self presentViewController:photoViewController animated:YES completion:nil];
}


@end
