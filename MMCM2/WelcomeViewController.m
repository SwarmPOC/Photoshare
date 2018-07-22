//
//  WelcomeViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 9/16/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "WelcomeViewController.h"
#import "InviteCodeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (NSString *)footerText;
{
   return @"We think friends make the best matchmakers.  Match Me Catch Me helps you get matched, make a match, or both!";
}

- (void)next;
{
   [self.navigationController pushViewController:[[InviteCodeViewController alloc] init] animated:YES];
}


@end
