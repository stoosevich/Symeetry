//
//  ChatRoomViewController.m
//  Symeetry
//
//  Created by Charles Northup on 4/22/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ChatRoomViewController.h"
#import "ChatManager.h"

@interface ChatRoomViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *chatRoomTextField;
@property ChatManager* chat;

@end

@implementation ChatRoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chat = [[ChatManager alloc]
                 initWithConnectedblock:^{
                 
                 }
                 connectingBlock:^{
                 
                 }
                 lostConnectionBlock:^{
                 
                 }
                 gotMessage:^{
                 
                 }];
    
    self.chatRoomTextField.delegate = self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSError* error;
    [self.chat sendMessage:self.chatRoomTextField.text peer:self.peerID error:error sent:^{
        
    }];
    return YES;
}

@end
