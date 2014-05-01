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
    if (!self.editingEnabled)
    {
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
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
        [self.editButton setTitle:@"Done" forState:UIControlStateNormal];
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
    [[PFUser currentUser] setObject:newAge forKey:@"age"];
    [UIView animateWithDuration:0.3 animations:^{
        self.fullPageView.frame = CGRectMake(self.fullPageView.frame.origin.x, 0, self.fullPageView.frame.size.width, self.fullPageView.frame.size.height);
    }];

}


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
    [UIView animateWithDuration:0.3 animations:^{
        self.fullPageView.frame = CGRectMake(self.fullPageView.frame.origin.x, 0, self.fullPageView.frame.size.width, self.fullPageView.frame.size.height);
    }];
}

-(void)textViewDidChange:(UITextView *)textView
{
    [[PFUser currentUser]setObject:textView.text forKey:@"biography"];
    [[PFUser currentUser]saveInBackground];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.usernameTextField.enabled = NO;
    self.backButton.hidden = NO;
    self.femaleButton.enabled = NO;
    self.maleButton.enabled = NO;
    self.bioTextView.userInteractionEnabled = NO;
    self.ageTextField.userInteractionEnabled = NO;
    self.changePictureButton.enabled = NO;
    self.gender = [[[ParseManager currentUser]objectForKey:@"gender"] boolValue];
    if (self.gender) {
        [self.maleButton setImage:[UIImage imageNamed:@"ic_gender_men_sm"] forState:UIControlStateNormal];
        [self.femaleButton setImage:[UIImage imageNamed:@"ic_gender_wmn_selected_sm"] forState:UIControlStateNormal];
    }
    else{
        [self.maleButton setImage:[UIImage imageNamed:@"ic_gender_men_selected_sm"] forState:UIControlStateNormal];
        [self.femaleButton setImage:[UIImage imageNamed:@"ic_gender_wmn_sm"] forState:UIControlStateNormal];

    }
    PFFile* file = [[PFUser currentUser]objectForKey:@"photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             self.userImage.image = [UIImage imageWithData:data];
             [self.userImage circlify];

         });
         
     }];
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
    [self.maleButton setImage:[UIImage imageNamed:@"ic_gender_men_sm"] forState:UIControlStateNormal];
    [self.femaleButton setImage:[UIImage imageNamed:@"ic_gender_wmn_selected_sm"] forState:UIControlStateNormal];
    [[PFUser currentUser] setObject:@YES forKey:@"gender"];

}

- (IBAction)onMaleButtonPressed:(id)sender
{
    self.gender = NO;
    [self.maleButton setImage:[UIImage imageNamed:@"ic_gender_men_selected_sm"] forState:UIControlStateNormal];
    [self.femaleButton setImage:[UIImage imageNamed:@"ic_gender_wmn_sm"] forState:UIControlStateNormal];
    
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
