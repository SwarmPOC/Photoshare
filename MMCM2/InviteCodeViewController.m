//
//  InviteCodeViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 11/23/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "InviteCodeViewController.h"
#import "NameViewController.h"

@interface InviteCodeViewController ()

@end

@implementation InviteCodeViewController

- (NSString *)headerText;
{
   return @"Match Me Catch Me";
}
- (NSString *)labelText;
{
   return @"please enter your invite code";
}
- (NSString *)detailText;
{
   return @"you need a code from an existing member to sign up";
}

- (void)verifyPassed;
{
   dispatch_async(dispatch_get_main_queue(), ^{
      [self.navigationController pushViewController:[[NameViewController alloc] init] animated:YES];
   });
}

@end
