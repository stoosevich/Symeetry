//
//  ChatManager.m
//  Symeetry
//
//  Created by Charles Northup on 4/22/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ChatManager.h"



@interface ChatManager()

@property MCPeerID* userBasedPeerID;
//@property ChatManager* chatMang;
@property NSMutableArray* users;
@property BOOL invited;

@end

@implementation ChatManager

#pragma mark -- Helper Methods

-(void)setViewController:(id)viewContoller segue:(UIStoryboardSegue*)segue
{
    self.currentViewController = viewContoller;
    self.segueToChatRoom = segue;
}

-(void)setPeerID
{
    PFUser* user = [ParseManager currentUser];
    self.devicePeerID = [[MCPeerID alloc] initWithDisplayName:user.username];
    self.mySession = [[MCSession alloc] initWithPeer:self.devicePeerID];
    self.mySession.delegate = self;
    self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:@"symeetry-txtchat" discoveryInfo:nil session:self.mySession];
    self.advertiserAssistant.delegate = self;
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.devicePeerID serviceType:@"symeetry-txtchat"];
    self.browser.delegate = self;
    [self checkinChat];
}

-(instancetype)initWithConnectedblock:(void(^)(void))connected connectingBlock:(void(^)(void))connecting lostConnectionBlock:(void(^)(void))lostConnection gotMessage:(void(^)(NSData* data))gotMessage;
{
    self.connected = connected;
    self.connecting = connecting;
    self.lostConnection = lostConnection;
    self.gotMessage = gotMessage;
    return self;
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
    [self.advertiserAssistant stop];
    [self.browser stopBrowsingForPeers];
}

-(void)checkinChat
{
    [self.advertiserAssistant start];
    [self.browser startBrowsingForPeers];
}

-(void)sendMessage:(NSString*)message peer:(MCPeerID*)peer error:(NSError*)error sent:(void(^)(void))sent
{
    
    [self.mySession sendData:[message dataUsingEncoding:NSUTF8StringEncoding] toPeers:[NSArray arrayWithObject:peer] withMode:MCSessionSendDataReliable error:&error];
    if (error) {
        //do something Aler view or something that says it didn't send
        NSLog(@"didn't send");
    }
    else {
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
    MCPeerID* correctPeer;
    for (MCPeerID*peer in self.users) {
        if ([peer.displayName isEqualToString:user.username]) {
            correctPeer = peer;
            break;
        }
    }
    return correctPeer;
}

-(void)acceptedInvite
{
    [self.currentViewController performSegueWithIdentifier:self.segueToChatRoom.identifier sender:self.currentViewController];
}

#pragma mark -- Browser

-(void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"Did not start browsing");
}

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    [self.users addObject:peerID];
    NSLog(@"%@", peerID.displayName);
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    [self.users removeObject:peerID];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lostConnection();
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.gotMessage(data);
    });
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateConnected: {
            
            NSLog(@"Connected to %@", peerID.displayName);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.connected();
            });
            break;
            
        } case MCSessionStateConnecting: {
            
            NSLog(@"Connecting to %@", peerID.displayName);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.invited) {
                    [self acceptedInvite];
                    self.connecting();

                }
                else{
                    self.connecting();
                }
            });
            
            break;
        } case MCSessionStateNotConnected: {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Not Connected to %@", peerID.displayName);
                //[self disconnect:peerID];
            });
            
            break;
        }
    }
    
}

@end
