//
//  ChatManager.m
//  Symeetry
//
//  Created by Charles Northup on 4/22/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "ChatManager.h"
#import "ParseManager.h"


@interface ChatManager()

@property MCPeerID* userBasedPeerID;

@end

@implementation ChatManager

-(void)setPeerID
{
    PFUser* user = [ParseManager currentUser];
    self.devicePeerID = [[MCPeerID alloc] initWithDisplayName:user.username];
    self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:@"symeetry-txtchat" discoveryInfo:nil session:self.mySession];
    [self.advertiserAssistant start];
    self.advertiserAssistant.delegate = self;

    
}

-(void)inviteToChat:(MCPeerID*)peer completedBlock:(void(^)(void))completionBlock
{
    MCNearbyServiceBrowser* browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.userBasedPeerID serviceType:@"symeetry-txtchat"];
    MCBrowserViewController* browserVC = [[MCBrowserViewController alloc]initWithBrowser:browser session:self.mySession];
    browserVC.delegate = self;
    browser.delegate = self;
    [browser invitePeer:peer toSession:self.mySession withContext:nil timeout:20];
}

#pragma mark -- Browser

-(void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    
}
-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    
}
-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
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
    
}
-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    
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
            
            NSLog(@"Connecting to %@", peerID);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.connecting();
            });
            
            break;
        } case MCSessionStateNotConnected: {
            
            break;
        }
    }
    
}

@end
