//
//  AddGroupViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 4/26/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "AddGroupViewController.h"

@interface AddGroupViewController ()

@end

@implementation AddGroupViewController

- (NSString *)headerText;
{
   return @"Add A Group";
}
- (BOOL)showBackButton;
{
   return YES;
}
- (NSString *)labelText;
{
   return @"please enter a group code";
}
- (NSString *)detailText;
{
   return @"you will be automatically added as a member of the group";
}

- (void)verifyPassed;
{
   dispatch_async(dispatch_get_main_queue(), ^{
      [self.navigationController popViewControllerAnimated:TRUE];
   });
}
@end
