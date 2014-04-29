//
//  AboutViewController.m
//  Symeetry
//
//  Created by user on 4/29/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "AboutViewController.h"
#import <MessageUI/MessageUI.h>

@interface AboutViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
- (IBAction)onReportIssueButtonPressed:(UIButton *)sender
{
    
    // Email Subject
    NSString *emailTitle = @"Report Issue to Symeetry team";
    // Email Content
    NSString *messageBody = nil;    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"symeetry@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}


@end
