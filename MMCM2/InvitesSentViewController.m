//
//  InvitesSentViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 11/3/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "InvitesSentViewController.h"

@interface InvitesSentViewController ()

@end

@implementation InvitesSentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupViews;
{
   [self setImage:@"InvitesSent"];
   [self setFooterText:@"Invites have been sent!\r\n\r\nWe'll notify you when your friends have joined"];
   [self setButtonText:@"invite more friends"];
   [self.button addTarget:self action:@selector(inviteClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)inviteClicked;
{
   FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
   content.appLinkURL = [NSURL URLWithString:@"https://www.mydomain.com/myapplink"];
   //optionally set previewImageURL
   content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://www.mydomain.com/my_invite_image.jpg"];

   // Present the dialog. Assumes self is a view controller
   // which implements the protocol `FBSDKAppInviteDialogDelegate`.
   [FBSDKAppInviteDialog showFromViewController:self
                                    withContent:content
                                       delegate:self];
}

/*!
 @abstract Sent to the delegate when the app invite completes without error.
 @param appInviteDialog The FBSDKAppInviteDialog that completed.
 @param results The results from the dialog.  This may be nil or empty.
 */
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results;
{
}

/*!
 @abstract Sent to the delegate when the app invite encounters an error.
 @param appInviteDialog The FBSDKAppInviteDialog that completed.
 @param error The error.
 */
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error;
{
}

@end
