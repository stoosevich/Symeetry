//
//  BlueToothManager.h
//  Symeetry
//
//  Created by Symeetry Team on 4/15/14.
//  Copyright (c) 2014 Symeetry Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlueToothManager : NSObject

+(instancetype)sharedBlueToothManager;
- (void)createCBCentralManager:(void(^)(void))onBlock;


@end
