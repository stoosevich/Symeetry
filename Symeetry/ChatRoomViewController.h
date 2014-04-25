//
//  ChatRoomViewController.h
//  Symeetry
//
//  Created by Charles Northup on 4/22/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ChatRoomViewController : UIViewController

@property MCPeerID* peerID;
@property UIImage* myPicture;
@property UIImage* theirPicture;

@end
