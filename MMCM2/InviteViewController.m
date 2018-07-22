//
//  InviteViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 9/16/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "InviteViewController.h"

@interface InviteViewController ()

@end

@implementation InviteViewController
static NSNumber *friendCount;

- (id)init:(NSNumber *)count;
{
   self = [super init];
   friendCount = count;
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated 
{
}


- (void)setupViews;
{
   [self setImage:@"Invite"];
   [self setFooterText:@"You need at least 5 friends to get started.\r\n\r\nBut remember, whether they’re single, in a relationship, or something else, Match Me Catch Me is for everyone!"];
   [self setButtonText:[NSString stringWithFormat:@"invite %d more friends", (5-[friendCount intValue])]];
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
