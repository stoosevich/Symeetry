//
//  ChatRoomViewController.m
//  Symeetry
//
//  Created by Charles Northup on 4/22/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ChatRoomViewController.h"
#import "ChatManager.h"

@interface ChatRoomViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *chatRoomTextField;
@property NSMutableArray* chatMessages;
@property (weak, nonatomic) IBOutlet UITableView *chatRoomTableView;

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
                }];
    
    self.chatRoomTextField.delegate = self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ChatRoomCellID"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", self.chatMessages[indexPath.row][@"sender"], self.chatMessages[indexPath.row][@"messageText"]];
    return cell;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSError* error;
    [[ChatManager sharedChatManager] sendMessage:self.chatRoomTextField.text peer:self.peerID error:error sent:^{
        NSDictionary* message = @{@"sender": [[PFUser currentUser]username], @"messageText": self.chatRoomTextField.text};
        [self.chatMessages addObject:message];
        [self.chatRoomTableView reloadData];
        self.chatRoomTextField.text = @"";
        [self.chatRoomTextField endEditing:YES];
    }];
    return YES;
}

@end
