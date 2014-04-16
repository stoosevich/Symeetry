//
//  ProfileViewController.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/14/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileHeaderView.h"
#import "ParseManager.h"



@interface ProfileViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *homeTownTextField;
@property (weak, nonatomic) IBOutlet UILabel *relationShipLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation ProfileViewController

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
    
    self.homeTownTextField.text = [self.user objectForKey:@"homeTown"];
    self.emailTextField.text = [self.user objectForKey:@"email"];
    
    self.relationShipLabel.text = [self relationShipStatus];
    
    ProfileHeaderView *headerView =  [ProfileHeaderView newViewFromNib:@"ProfileHeaderView"];
    //quick hack to make the view appear in the correct location
    CGRect frame = CGRectMake(0.0, 60.0f, headerView.frame.size.width, headerView.frame.size.height);
    headerView.frame = frame;
    headerView.nameTextField.text = [self.user username];
    headerView.ageTextField.text = [[self.user objectForKey:@"age"] description];
    headerView.genderTextField.text = [self.user objectForKey:@"gender"];
    PFFile* file = [self.user objectForKey:@"photo"];
    NSData* data = [file getData];
    headerView.imageView.image = [UIImage imageWithData:data];
    
    self.homeTownTextField.enabled = [ParseManager isCurrentUser:self.user];
    self.emailTextField.enabled = [ParseManager isCurrentUser:self.user];
    
    [self.view addSubview:headerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
}

-(NSString*)relationShipStatus{
    
    int x = [(NSNumber*)[self.user objectForKey:@"relationshipStatus"] intValue];
    
    switch (x) {
        case 0:
            return @"Single";
            break;
        case 1:
            return @"Dating";
            break;
            
        case 2:
            return @"Engaged";
            break;
            
        case 3:
            return @"Married";
            break;
            
        default:
            return nil;
            break;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    if (textField == self.emailTextField) {
        [ParseManager saveInfo:self.user objectToSet:textField.text forKey:@"email"];
    }
    else if(textField == self.homeTownTextField){
        [ParseManager saveInfo:self.user objectToSet:textField.text forKey:@"homeTown"];
    }
    return YES;
}


@end
