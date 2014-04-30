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

@interface BiographyViewController () <UITextFieldDelegate>
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

    self.gender = NO;
    [[PFUser currentUser]setObject:@NO forKey:@"gender"];
    self.maleButton.enabled = YES;
    self.femaleButton.enabled = YES;

    
}
- (IBAction)onFemaleButtonPressed:(id)sender
{
    self.maleButton.enabled = NO;
    self.femaleButton.enabled = NO;

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
    if (textField == self.ageTextField) {
        [[PFUser currentUser]setObject:@(self.ageTextField.text.intValue) forKey:@"age"];
    }
    else
    {
        [[PFUser currentUser]setObject:self.myBioTextView.text forKey:@"biography"];

    }
    return YES;
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
