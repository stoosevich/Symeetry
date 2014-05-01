//
//  ChatManager.m
//  Symeetry
//
//  Created by Charles Northup on 4/22/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ChatManager.h"
#import "ChatRoomViewController.h"
#import "ParseManager.h"
#import "MMDrawerController.h"



@interface ChatManager() <UIAlertViewDelegate>

@property MCPeerID* userBasedPeerID;
//@property ChatManager* chatMang;
@property NSMutableSet* users;
@property BOOL invited;

@end

@implementation ChatManager

+(instancetype)sharedChatManager {
    static ChatManager *manager = nil;
    if (!manager)
    {
        manager = [ChatManager new];
    }
    return manager;
}

#pragma mark -- Helper Methods

//-(void)setViewController:(id)viewContoller segue:(UIStoryboardSegue*)segue
//{
//    self.currentViewController = viewContoller;
//    self.segueToChatRoom = segue;
//}

-(void)setPeerID
{
    PFUser* user = [ParseManager currentUser];
    self.users = [NSMutableSet new];
    self.devicePeerID = [[MCPeerID alloc] initWithDisplayName:user.username];
    self.mySession = [[MCSession alloc] initWithPeer:self.devicePeerID];
    self.mySession.delegate = self;
    self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:@"chat-txtchat" discoveryInfo:nil session:self.mySession];
    self.advertiserAssistant.delegate = self;
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.devicePeerID serviceType:@"chat-txtchat"];
    self.browser.delegate = self;
    PFFile* file = [[PFUser currentUser]objectForKey:@"thumbnail"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             self.myChatPhoto = [UIImage imageWithData:data];
         }
         else
         {
             //do something, like load a default image
         }
     }];
}

-(void)setConnectedblock:(void(^)(void))connected connectingBlock:(void(^)(void))connecting lostConnectionBlock:(void(^)(void))lostConnection gotMessage:(void(^)(NSData* data))gotMessage;
{
    self.connected = connected;
    self.connecting = connecting;
    self.lostConnection = lostConnection;
    self.gotMessage = gotMessage;
}

-(void)inviteToChat:(MCPeerID*)peer completedBlock:(void(^)(void))completionBlock
{
//    MCNearbyServiceBrowser* browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.userBasedPeerID serviceType:@"symeetry-txtchat"];
//    MCBrowserViewController* browserVC = [[MCBrowserViewController alloc]initWithBrowser:browser session:self.mySession];
//    browserVC.delegate = self;
    [self.browser invitePeer:peer toSession:self.mySession withContext:nil timeout:20];
    self.invited = NO;
    completionBlock();
}

-(void)checkoutChat
{
    NSLog(@"OFF");
    [self.advertiserAssistant stop];
    [self.browser stopBrowsingForPeers];
    [self.users removeAllObjects];

}

-(void)checkinChat
{
    NSLog(@"ON");
    [self.users removeAllObjects];
    [self.advertiserAssistant start];
    [self.browser startBrowsingForPeers];

}

-(void)sendMessage:(NSString*)message peer:(MCPeerID*)peer error:(NSError*)error sent:(void(^)(void))sent
{
    
    [self.mySession sendData:[message dataUsingEncoding:NSUTF8StringEncoding] toPeers:[NSArray arrayWithObject:peer] withMode:MCSessionSendDataReliable error:&error];
    if (error) {
        //do something Aler view or something that says it didn't send
        UIAlertView* didNotSend = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Message was not able to send" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [didNotSend show];
    }
    else {
        sent();
    }
}

-(void)sendPhoto:(NSData*)data peer:(MCPeerID*)peer error:(NSError*)error sent:(void(^)(void))sent
{
    [self.mySession sendData:data toPeers:@[peer] withMode:MCSessionSendDataReliable error:&error];
    if (error) {
        
    }
    else{
        sent();
    }
}

-(void)disconnect:(MCPeerID*)peer
{
    NSError* error = [NSError new];
    [self.mySession sendData:[@"This user has left" dataUsingEncoding:NSUTF8StringEncoding] toPeers:[NSArray arrayWithObject:peer] withMode:MCSessionSendDataReliable error:&error];
    [self.mySession disconnect];
}

-(MCPeerID*)findCorrectPeer:(PFUser*)user
{
    //MCPeerID* correctPeer;
    for (MCPeerID*peer in self.users) {
        if ([peer.displayName isEqualToString:user.username]) {
            self.friendPeerID = peer;
            break;
        }
    }
    return self.friendPeerID;
}


#pragma mark -- Browser

-(void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"Did not start browsing");
}

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    dispatch_async(dispatch_get_main_queue(), ^{

    MCPeerID* foundPeer = peerID;
    NSLog(@"%@", self.users);
    NSMutableSet* temp = self.users;
    for (MCPeerID*peer in self.users) {
        if ([peer.displayName isEqualToString:foundPeer.displayName]) {
            [temp removeObject:peer];
            break;
        }
    }
    [temp addObject:foundPeer];
    self.users = temp;
    NSLog(@"%@", peerID);
    NSLog(@"%@", self.users);
    NSLog(@"%lu", (unsigned long)self.users.count);
    });
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.users removeObject:peerID];
        NSLog(@"%@", peerID.displayName);
        NSLog(@"%lu", (unsigned long)self.users.count);
    });
}

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    
}

#pragma -- Advertiser

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    self.invited = YES;
    self.friendPeerID = peerID;
    invitationHandler(YES, self.mySession);
    
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"can't send signal");
}

#pragma mark -- Session

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    self.gotMessage(data);
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateConnected: {
            assert(![NSThread isMainThread]);
            NSLog(@"Connected to %@", peerID.displayName);
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            ChatRoomViewController* cRVC = [sb instantiateViewControllerWithIdentifier:@"ChatRoomStoryBoardID"];
            cRVC.peerID = peerID;
            cRVC.chatRoomLabel.text = [NSString stringWithFormat:@"Chat with %@",peerID.displayName];
            id drawVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                while ([drawVC presentedViewController] != nil) {
                    [drawVC dismissViewControllerAnimated:NO completion:^{
                    }];
                }
                [drawVC presentViewController:cRVC animated:YES completion:^{
                    NSLog(@"worked");
                    NSLog(@"%@", cRVC.peerID.displayName);
                }];
            });
            break;
            
        } case MCSessionStateConnecting: {
            
            NSLog(@"Connecting to %@", peerID.displayName);
            dispatch_async(dispatch_get_main_queue(), ^{

            });
            
            break;
        } case MCSessionStateNotConnected: {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Not Connected to %@", peerID.displayName);
                [[ChatManager sharedChatManager] disconnect:peerID];
                UIStoryboard *sb = [UIApplication sharedApplication].keyWindow.rootViewController.storyboard;
                ChatRoomViewController* cRVC = [sb instantiateViewControllerWithIdentifier:@"ChatRoomStoryBoardID"];
                cRVC.peerID = peerID;
                cRVC.chatRoomLabel.text = peerID.displayName;
                
                id vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                vc = [vc presentedViewController];
                [vc dismissModalViewControllerAnimated:YES];
            });
            
            break;
        }
    }
    
}

@end
