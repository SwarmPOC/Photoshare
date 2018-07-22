//
//  LookingForViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "LookingForViewController.h"
#import "CompleteViewController.h"

@interface LookingForViewController ()

@end

@implementation LookingForViewController

- (int)getRowCount;
{
   return 3;
}

- (NSString *)labelText;
{
   return @"I want to find singles who are:";
}

- (NSString *)getCellTextForIndexPath:(NSIndexPath *)indexPath;
{
   if (indexPath.row == 0) {
      return @"Men";
   }
   if (indexPath.row == 1) {
      return @"Women";
   }
   if (indexPath.row == 2) {
      return @"Either";
   }
   return @"";
}

- (int)defaultOption;
{
   //if ([[myUserData objectForKey:@"gender"] isEqualToString:@"male"]) {
   if ([myUserData.gender isEqualToString:@"male"]) {
      return 1;
   }
   return 0;
}

- (void)next;
{
   NSString *lookingFor;
   if (self.checkedIndexPath.row == 0) {
      lookingFor = @"1"; // male
   }
   if (self.checkedIndexPath.row == 1) {
      lookingFor = @"2"; // female
   }
   if (self.checkedIndexPath.row == 2) {
      lookingFor = @"3"; // male or female
   }

   //[myUserData setValue:lookingFor forKey:@"lookingFor"];
   myUserData.lookingFor = lookingFor;
   [myUserData setValue:lookingFor forKey:@"lookingFor"];
   [server updateLookingFor:lookingFor];
   [self.navigationController pushViewController:[[CompleteViewController alloc] init] animated:YES];
}
@end
