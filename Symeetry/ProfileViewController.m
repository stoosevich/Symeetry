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



@property ProfileHeaderView *headerView;

@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UIView *biographyView;
@property ChatManager* chat;
@property ChatRoomViewController* cRVC;
@property NSMutableArray* userInterests;

@property (weak, nonatomic) IBOutlet UIImageView *theirGenderPicture;

@end

@implementation ProfileViewController

-(void)viewWillAppear:(BOOL)animated
{
    if ([[self.user objectForKey:@"gender"]boolValue]) {
        self.theirGenderPicture.image = [UIImage imageNamed:@"ic_gender_wmn_sm"];
    }
    else
    {
        self.theirGenderPicture.image = [UIImage imageNamed:@"ic_gender_men_sm"];

    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CALayer *chatButtonLayer = [self.chatButton layer];
    [chatButtonLayer setMasksToBounds:YES];
    [chatButtonLayer setCornerRadius:5.0f];
    
    self.userInterests = [NSMutableArray arrayWithCapacity:12];
    
    [self parseUserInterestIntoDataSource];
    
    if ([ParseManager isCurrentUser:self.user]) {

        self.chatButton.hidden = YES;
    }
    else{

        self.chatButton.hidden = NO;
    }
    
    self.nameTextField.text = [self.user username];
    self.ageTextField.text = [[self.user objectForKey:@"age"] description];    
    
    PFFile* file = [self.user objectForKey:@"photo"];
    
    //load the picture asynchronously
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
    {
        [self.imageView circlify];
        NSNumber* index = (NSNumber*) self.user[@"similarityIndex"];
        [self.imageView.layer setBorderColor:[Utilities colorBasedOnSimilarity:[index intValue]]];
         self.imageView.image = [UIImage imageWithData:data];
    }];
   


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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)[[[interest allValues] firstObject] integerValue]];
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

    }];
    
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    
    if(textField == self.headerView.ageTextField)
    {
        [ParseManager saveInfo:self.user objectToSet:@(textField.text.intValue) forKey:@"age" completionBlock:^{
            
        }];

    }
    return YES;
}


@end