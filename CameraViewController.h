//
//  CameraViewController.h
//  Symeetry
//
//  Created by Steve Toosevich on 4/26/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;

+(instancetype)sharedCameraViewController;

@end
