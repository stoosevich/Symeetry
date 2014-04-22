//
//  ChatManager.h
//  Symeetry
//
//  Created by Charles Northup on 4/22/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ChatManager : NSObject <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, MCAdvertiserAssistantDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceBrowserDelegate>

@property MCPeerID* devicePeerID;
@property MCSession* mySession;
@property MCAdvertiserAssistant* advertiserAssistant;
@property (nonatomic, copy) void (^connected)(void);
@property (nonatomic, copy) void (^connecting)(void);
@property (nonatomic, copy) void (^lostConnection)(void);



@end
