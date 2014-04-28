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

@interface ChatRoomViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

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
    PFFile* file = [[PFUser currentUser]objectForKey:@"photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.myPicture = [UIImage imageWithData:data];
             });
         }
         else
         {
             //do something, like load a default image
         }
     }];
    
    self.firstTimeTyping = YES;
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
                    NSLog(@"%f", self.chatRoomTextView.frame.origin.y);
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
        return cell;
    }
    else
    {
        MessageTableViewPrototypeCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MyMessageCellID"];
        cell.myTextView.textAlignment = NSTextAlignmentLeft;
        cell.myTextView.text = [NSString stringWithFormat:@"%@",self.chatMessages[indexPath.row][@"messageText"]];
        cell.myPicture.image = self.myPicture;
        return cell;
    }
    NSLog(@"%f", self.chatRoomTextView.frame.origin.y);

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.chatMessages[indexPath.row][@"sender"] isEqualToString:[[PFUser currentUser]username]])
    {
        MessageTableViewPrototypeCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TheirMessageCellID"];
        cell.theirTextView.text = [NSString stringWithFormat:@"%@",self.chatMessages[indexPath.row][@"messageText"]];
        float height = cell.theirTextView.contentSize.height;
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
        NSLog(@"%f", self.chatRoomTextView.frame.origin.y);

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
    [[ChatManager sharedChatManager] disconnect:self.peerID];
}

@end
