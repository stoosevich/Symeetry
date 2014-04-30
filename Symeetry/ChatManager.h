//
//  ChatManager.h
//  Symeetry
//
//  Created by Charles Northup on 4/22/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseManager.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ChatManager : NSObject <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, MCAdvertiserAssistantDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceBrowserDelegate>

+(instancetype)sharedChatManager;

@property MCPeerID* devicePeerID;
@property MCSession* mySession;
@property MCPeerID* friendPeerID;
@property MCAdvertiserAssistant* advertiserAssistant;
@property MCNearbyServiceBrowser* browser;
@property (nonatomic, copy) void (^connected)(void);
@property (nonatomic, copy) void (^connecting)(void);
@property (nonatomic, copy) void (^lostConnection)(void);
@property (nonatomic, copy) void (^gotMessage)(NSData* data);
@property UIImage* myChatPhoto;
@property BOOL on;

-(void)setPeerID;

-(void)setConnectedblock:(void(^)(void))connected connectingBlock:(void(^)(void))connecting lostConnectionBlock:(void(^)(void))lostConnection gotMessage:(void(^)(NSData* data))gotMessage;

-(void)inviteToChat:(MCPeerID*)peer completedBlock:(void(^)(void))completionBlock;
-(void)checkoutChat;
-(void)checkinChat;
-(void)sendMessage:(NSString*)message peer:(MCPeerID*)peer error:(NSError*)error sent:(void(^)(void))sent;
-(void)sendPhoto:(NSData*)data peer:(MCPeerID*)peer error:(NSError*)error sent:(void(^)(void))sent;
-(void)disconnect:(MCPeerID*)peer;
-(MCPeerID*)findCorrectPeer:(PFUser*)user;
//-(void)acceptedInvite;



@end
