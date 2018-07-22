//
//  InviteViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 9/16/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "BasicImageAndTextViewController.h"

// Frameworks
   #import <FBSDKShareKit/FBSDKAppInviteDialog.h>

@interface InviteViewController : BasicImageAndTextViewController <FBSDKAppInviteDialogDelegate>
- (id)init:(NSNumber *)count;

@end
