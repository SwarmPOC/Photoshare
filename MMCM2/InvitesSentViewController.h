//
//  InvitesSentViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 11/3/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "BasicImageAndTextViewController.h"

// Frameworks
   #import <FBSDKShareKit/FBSDKAppInviteDialog.h>

@interface InvitesSentViewController : BasicImageAndTextViewController <FBSDKAppInviteDialogDelegate>

@end
