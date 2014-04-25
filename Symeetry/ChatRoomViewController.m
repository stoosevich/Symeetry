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

@interface ChatRoomViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *chatRoomTextField;
@property NSMutableArray* chatMessages;
@property (weak, nonatomic) IBOutlet UITableView *chatRoomTableView;
@property (weak, nonatomic) IBOutlet UITextView *chatRoomTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButtonPressed;

@end

@implementation ChatRoomViewController

- (void)viewDidLoad
{
    self.chatMessages = [NSMutableArray new];
    
    [super viewDidLoad];
    [[ChatManager sharedChatManager] setConnectedblock:^{
        
        
        
                }
                connectingBlock:^{
                    
                    
                    
                
                }
                lostConnectionBlock:^{
                    
                    
                    
                
                }
                gotMessage:^(NSData *data) {
                    NSString *messageString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSDictionary* message = @{@"sender": self.peerID.displayName, @"messageText": messageString};
                    [self.chatMessages addObject:message];
                    [self.chatRoomTableView reloadData];
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.chatMessages.count -1 inSection:0];
                    [self.chatRoomTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }];
    
    self.chatRoomTextField.delegate = self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.chatMessages[indexPath.row][@"sender"] isEqualToString:[[PFUser currentUser]username]]) {
        MessageTableViewPrototypeCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MyMessageCellID"];
        cell.myTextView.text = [NSString stringWithFormat:@"%@:%@", self.chatMessages[indexPath.row][@"sender"], self.chatMessages[indexPath.row][@"messageText"]];
//        cell.textLabel.numberOfLines = 0;
//        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.myPicture.image = self.myPicture;
        return cell;
    }
    else
    {
        MessageTableViewPrototypeCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TheirMessageCellID"];
        cell.theirTextView.text = [NSString stringWithFormat:@"%@:%@", self.chatMessages[indexPath.row][@"sender"], self.chatMessages[indexPath.row][@"messageText"]];
//        cell.textLabel.textColor = [UIColor orangeColor];
//        cell.textLabel.numberOfLines = 0;
//        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.theirPicture.image = self.theirPicture;
        return cell;
    }
}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    NSError* error;
//    [[ChatManager sharedChatManager] sendMessage:self.chatRoomTextField.text peer:self.peerID error:error sent:^{
//        NSDictionary* message = @{@"sender": [[PFUser currentUser]username], @"messageText": self.chatRoomTextView.text};
//        [self.chatMessages addObject:message];
//        [self.chatRoomTableView reloadData];
//        self.chatRoomTextView.text = @"";
//        self.chatRoomTableView.frame = CGRectMake(0, 50, self.chatRoomTableView.frame.size.width, self.chatRoomTableView.frame.size.height + 216);
//        self.chatRoomTextView.frame = CGRectMake(0, self.chatRoomTextView.frame.origin.y + 216, self.chatRoomTextView.frame.size.width, self.chatRoomTextView.frame.size.height);
//        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.chatMessages.count -1 inSection:0];
//        [self.chatRoomTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }];
//    return NO;
//}
- (IBAction)sendButtonPressed:(id)sender
{
    NSError* error;
    [[ChatManager sharedChatManager] sendMessage:self.chatRoomTextView.text peer:self.peerID error:error sent:^{
        NSDictionary* message = @{@"sender": [[PFUser currentUser]username], @"messageText": self.chatRoomTextView.text};
        [self.chatMessages addObject:message];
        [self.chatRoomTableView reloadData];
        self.chatRoomTextView.text = @"";
        self.chatRoomTableView.frame = CGRectMake(0, 50, self.chatRoomTableView.frame.size.width, self.chatRoomTableView.frame.size.height + 216);
        self.chatRoomTextView.frame = CGRectMake(0, self.chatRoomTextView.frame.origin.y + 216, self.chatRoomTextView.frame.size.width, self.chatRoomTextView.frame.size.height);
        self.sendButtonPressed.frame = CGRectMake(self.sendButtonPressed.frame.origin.x, self.sendButtonPressed.frame.origin.y - 216, self.sendButtonPressed.frame.size.width, self.sendButtonPressed.frame.size.height);
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.chatMessages.count -1 inSection:0];
        [self.chatRoomTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.chatRoomTableView.frame = CGRectMake(0, 50, self.chatRoomTableView.frame.size.width, self.chatRoomTableView.frame.size.height - 216);
    self.sendButtonPressed.frame = CGRectMake(self.sendButtonPressed.frame.origin.x, self.sendButtonPressed.frame.origin.y - 216, self.sendButtonPressed.frame.size.width, self.sendButtonPressed.frame.size.height);
    self.chatRoomTextView.frame = CGRectMake(0, self.chatRoomTextView.frame.origin.y - 216, self.chatRoomTextView.frame.size.width, self.chatRoomTextView.frame.size.height);
    
}

//-(void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    self.chatRoomTableView.frame = CGRectMake(0, 50, self.chatRoomTableView.frame.size.width, self.chatRoomTableView.frame.size.height - 216);
//    self.chatRoomTextView.frame = CGRectMake(0, self.chatRoomTextView.frame.origin.y - 216, self.chatRoomTextView.frame.size.width, self.chatRoomTextView.frame.size.height);
//    
//}

- (IBAction)onLeaveChatButtonPressed:(id)sender
{
    [[ChatManager sharedChatManager] disconnect:self.peerID];
}

@end
