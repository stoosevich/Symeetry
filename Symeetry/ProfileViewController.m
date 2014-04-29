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
#import "ChatManager.h"
#import "ChatRoomViewController.h"
#import "UIView+Circlify.h"
#import "Utilities.h"
#import "ProfileTableViewCell.h"

@interface ProfileViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *homeTownTextField;
@property (weak, nonatomic) IBOutlet UILabel *relationShipLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property ProfileHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *changeRelationShipButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property NSMutableArray* userInterests;

@property ChatManager* chat;
@property ChatRoomViewController* cRVC;


@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userInterests = [NSMutableArray arrayWithCapacity:12];
    
    [self parseUserInterestIntoDataSource];
    
    if ([ParseManager isCurrentUser:self.user]) {
        self.changeRelationShipButton.hidden = NO;
        self.chatButton.hidden = YES;
    }
    else{
        self.changeRelationShipButton.hidden = YES;
        self.chatButton.hidden = NO;
    }
    self.homeTownTextField.text = [self.user objectForKey:@"homeTown"];
    self.emailTextField.text = [self.user objectForKey:@"email"];
    self.relationShipLabel.text = [self relationShipStatus];
    
//    self.headerView.nameTextField.text = [self.user username];
//    self.headerView.ageTextField.text = [[self.user objectForKey:@"age"] description];
    [self.headerView setDelegates:self];
    
    
//    self.headerView.genderTextField.text = [self.user objectForKey:@"gender"];
    PFFile* file = [self.user objectForKey:@"photo"];
    
    //load the picture asynchronously
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
    {
        [self.imageView circlify];
        NSNumber* index = (NSNumber*) self.user[@"similarityIndex"];
        [self.imageView.layer setBorderColor:[Utilities colorBasedOnSimilarity:[index intValue]]];
         self.imageView.image = [UIImage imageWithData:data];
    }];
   
    
//    self.headerView.ageTextField.enabled = [ParseManager isCurrentUser:self.user];
//    self.headerView.genderTextField.enabled = [ParseManager isCurrentUser:self.user];
    self.homeTownTextField.enabled = [ParseManager isCurrentUser:self.user];
    self.emailTextField.enabled = [ParseManager isCurrentUser:self.user];

}

#pragma mark -  UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userInterests.count;
}


- (ProfileTableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"InterestCellId"];
    NSDictionary* interest = self.userInterests[indexPath.row];
    cell.textLabel.text = [[interest allKeys].firstObject capitalizedString];
    //NSInteger value = [[interest allValues].firstObject intValue] * 12;
    cell.detailTextLabel.text = [[[interest allValues] firstObject] description];
    [cell.imageView circlify];
    
    return cell;
}

//convert the user dictionary  into an array of dictionary items, one for each interest with
//associated value
- (void)parseUserInterestIntoDataSource
{
    //convert the PFObject into a dictionary
    NSDictionary* dictionary = [ParseManager convertPFObjectToNSDictionary:self.user[@"interests"]];
    
    //extract all the keys from the PFObject
    NSArray* objectToConvertKeys = [dictionary allKeys];
    
    //enumerate over the keys and get the object
    NSEnumerator *enumerator = [objectToConvertKeys objectEnumerator];
    
    id object;
    
    while ((object = [enumerator nextObject]) )
    {
        
        if(![object isEqualToString:@"userid"] && ![object isEqualToString:@"user"])
        {
            //create a dicttionary for each interest and rating
            NSMutableDictionary* interest = [[NSMutableDictionary alloc]init];
            [interest setValue:[dictionary objectForKey:object] forKey:object];
            [self.userInterests addObject:interest];
        }
    }
    
    
}

#pragma makk - IBAction Methods

- (IBAction)onBackButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}



- (IBAction)onChatButtonPressed:(id)sender
{
    [[ChatManager sharedChatManager] inviteToChat:[[ChatManager sharedChatManager] findCorrectPeer:self.user] completedBlock:^{
//        [self performSegueWithIdentifier:@"ChatRoomSegue" sender:self];
//        NSLog(@"Invited %@", self.user.username);
    }];
    
}


- (IBAction)onChangeRelationShipButtonPressed:(id)sender
{
    int x = [[self.user objectForKey:@"relationshipStatus"] intValue];
    if (x != 3)
    {
        x++;
        [ParseManager saveInfo:self.user objectToSet:@(x) forKey:@"relationshipStatus" completionBlock:^{
            self.relationShipLabel.text = [self relationShipStatus];
        }];
    }
    else
    {
        x = 0;
        [ParseManager saveInfo:self.user objectToSet:@(x) forKey:@"relationshipStatus" completionBlock:^{
            self.relationShipLabel.text = [self relationShipStatus];

        }];
    }
}


-(NSString*)relationShipStatus
{
    
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
    if (textField == self.emailTextField)
    {
        [ParseManager saveInfo:self.user objectToSet:textField.text forKey:@"email" completionBlock:^{
            
        }];
    }
    else if(textField == self.homeTownTextField)
    {
        [ParseManager saveInfo:self.user objectToSet:textField.text forKey:@"homeTown" completionBlock:^{
            
        }];
    }
    else if(textField == self.headerView.ageTextField)
    {
        [ParseManager saveInfo:self.user objectToSet:@(textField.text.intValue) forKey:@"age" completionBlock:^{
            
        }];
//    }
//    else if (textField == self.headerView.genderTextField)
//    {
//        if ([self.headerView.genderTextField.text isEqualToString:@"Male"] ||
//            [self.headerView.genderTextField.text isEqualToString:@"male"] ||
//            [self.headerView.genderTextField.text isEqualToString:@"Female"] ||
//            [self.headerView.genderTextField.text isEqualToString:@"female"] ||
//            [self.headerView.genderTextField.text isEqualToString:@"M" ] ||
//            [self.headerView.genderTextField.text isEqualToString:@"F"])
//        {
//            [ParseManager saveInfo:self.user objectToSet:textField.text forKey:@"gender" completionBlock:^{
//                
//            }];
//        }
//        else
//        {
//            self.headerView.genderTextField.text = [self.user objectForKey:@"gender"];
//        }
    }
    return YES;
}


@end