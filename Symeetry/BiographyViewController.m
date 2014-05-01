//
//  BiographyViewController.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/29/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "BiographyViewController.h"
#import "ParseManager.h"
#import "Parse/Parse.h"

@interface BiographyViewController () <UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *myBioTextView;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property BOOL gender;
@end
// test commit
@implementation BiographyViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onMaleButtonPressed:(id)sender
{
    self.maleButton.enabled = NO;
    self.femaleButton.enabled = NO;
    
    [self.maleButton setImage:[UIImage imageNamed:@"ic_gender_men_selected.png"] forState:UIControlStateNormal];
    [self.femaleButton setImage:[UIImage imageNamed:@"ic_gender_wmn"] forState:UIControlStateNormal];

    self.gender = NO;
    [[PFUser currentUser]setObject:@NO forKey:@"gender"];
    self.maleButton.enabled = YES;
    self.femaleButton.enabled = YES;

    
}
- (IBAction)onFemaleButtonPressed:(id)sender
{
    self.maleButton.enabled = NO;
    self.femaleButton.enabled = NO;
    
    [self.maleButton setImage:[UIImage imageNamed:@"ic_gender_men"] forState:UIControlStateNormal];
    [self.femaleButton setImage:[UIImage imageNamed:@"ic_gender_wmn_selected"] forState:UIControlStateNormal];

    self.gender = YES;
    [[PFUser currentUser]setObject:@YES forKey:@"gender"];
    
    self.maleButton.enabled = YES;
    self.femaleButton.enabled = YES;


}

-(void)viewWillDisappear:(BOOL)animated
{
    [[PFUser currentUser]saveInBackground];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
        [[PFUser currentUser]setObject:@(self.ageTextField.text.intValue) forKey:@"age"];
    return YES;
}



-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView endEditing:YES];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ((int)[[UIScreen mainScreen] bounds].size.height == 568)
    {
        
    }
    else {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.myBioTextView.frame = CGRectMake(self.myBioTextView.frame.origin.x, 140, self.myBioTextView.frame.size.width, self.myBioTextView.frame.size.height);
        }];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ((int)[[UIScreen mainScreen] bounds].size.height == 568)
    {
        
    }
    else {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.myBioTextView.frame = CGRectMake(self.myBioTextView.frame.origin.x, 250, self.myBioTextView.frame.size.width, self.myBioTextView.frame.size.height);
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
