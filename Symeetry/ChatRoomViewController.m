//
//  ChatRoomViewController.m
//  Symeetry
//
//  Created by Charles Northup on 4/22/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ChatRoomViewController.h"
#import "ChatManager.h"
#import "MessageTableViewPrototypeCellTableViewCell.h"
#import "Parse/Parse.h"
#import "UIView+Circlify.h"

@interface ChatRoomViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIAlertViewDelegate>

@property NSMutableArray* chatMessages;
@property (weak, nonatomic) IBOutlet UITableView *chatRoomTableView;
@property (weak, nonatomic) IBOutlet UITextView *chatRoomTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButtonPressed;
@property BOOL firstTimeTyping;

@end

@implementation ChatRoomViewController

- (void)viewDidLoad
{
    self.chatMessages = [NSMutableArray new];
    [super viewDidLoad];
    
    self.firstTimeTyping = YES;
    [[ChatManager sharedChatManager] setConnectedblock:^{
        
        
        
                }
                connectingBlock:^{
                    
                    
                    
                
                }
                lostConnectionBlock:^{
                    
                    
                    
                
                }
                gotMessage:^(NSData *data) {
                    UIImage* image = [UIImage imageWithData:data];
                    if (image == nil) {
                        NSString *messageString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSDictionary* message = @{@"sender": self.peerID.displayName, @"messageText": messageString};
                        [self.chatMessages addObject:message];
                        [self.chatRoomTableView reloadData];
                        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.chatMessages.count -1 inSection:0];
                        [self.chatRoomTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    }
                    else{
                        self.theirPicture = image;
                    }

                }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.chatMessages[indexPath.row][@"sender"] isEqualToString:[[PFUser currentUser]username]])
    {
        MessageTableViewPrototypeCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TheirMessageCellID"];
        cell.theirTextView.text = [NSString stringWithFormat:@"%@",self.chatMessages[indexPath.row][@"messageText"]];
        cell.theirPicture.image = self.theirPicture;
        [cell.theirPicture circlify];
        return cell;
    }
    else
    {
        MessageTableViewPrototypeCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MyMessageCellID"];
        cell.myTextView.textAlignment = NSTextAlignmentLeft;
        cell.myTextView.text = [NSString stringWithFormat:@"%@",self.chatMessages[indexPath.row][@"messageText"]];
        cell.myPicture.image = [[ChatManager sharedChatManager] myChatPhoto];
        [cell.myPicture circlify];
        return cell;
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.chatMessages[indexPath.row][@"sender"] isEqualToString:[[PFUser currentUser]username]])
    {
        MessageTableViewPrototypeCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TheirMessageCellID"];
        cell.theirTextView.text = [NSString stringWithFormat:@"%@",self.chatMessages[indexPath.row][@"messageText"]];
        float height = cell.theirTextView.contentSize.height;
        NSLog(@"%f", cell.theirTextView.contentSize.height);
               if (height > 55)
               {
                   return height + 12;
               }
               else
               {
                   return 67;
               }
    }
    else
    {
        MessageTableViewPrototypeCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MyMessageCellID"];
        cell.myTextView.textAlignment = NSTextAlignmentLeft;
        cell.myTextView.text = [NSString stringWithFormat:@"%@",self.chatMessages[indexPath.row][@"messageText"]];
        float height = cell.myTextView.contentSize.height;
        NSLog(@"%f", cell.myTextView.contentSize.height);
        if (height > 55)
        {
            return height + 12;
        }
        else
        {
            return 67;
        }
    }
}



- (IBAction)sendButtonPressed:(id)sender
{
    NSError* error;
    [[ChatManager sharedChatManager] sendMessage:self.chatRoomTextView.text peer:self.peerID error:error sent:^{
        NSDictionary* message = @{@"sender": [[PFUser currentUser]username], @"messageText": self.chatRoomTextView.text};
        [self.chatMessages addObject:message];
        self.chatRoomTextView.text = @"";
        [self.chatRoomTableView reloadData];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.chatMessages.count -1 inSection:0];
        [self.chatRoomTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
}

-(void)isfirstTimeTyping:(BOOL)first
{
    if (first)
    {
//        self.chatRoomTableView.frame = CGRectMake(0, 50, self.chatRoomTableView.frame.size.width, 250);
//        self.sendButtonPressed.frame = CGRectMake(self.sendButtonPressed.frame.origin.x, 308, self.sendButtonPressed.frame.size.width, self.sendButtonPressed.frame.size.height);
//        self.chatRoomTextView.frame = CGRectMake(0, 308, self.chatRoomTextView.frame.size.width, self.chatRoomTextView.frame.size.height);
//        self.firstTimeTyping = NO;
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self isfirstTimeTyping:self.firstTimeTyping];
    NSLog(@"%f", self.chatRoomTextView.frame.origin.y);

}


- (IBAction)onLeaveChatButtonPressed:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:@"Nothing in this chat will be saved when you leave" delegate:self cancelButtonTitle:@"Stay" otherButtonTitles:@"Leave", nil];
    [alert show];
    //[[ChatManager sharedChatManager] disconnect:self.peerID];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[ChatManager sharedChatManager] disconnect:self.peerID];
            break;
        case 1:
            
            break;
        default:
            break;
    }
}

@end
