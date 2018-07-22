//
//  GenderViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/8/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "GenderViewController.h"
#import "RelationshipStatusViewController.h"

@interface GenderViewController ()

@end

@implementation GenderViewController

- (int)getRowCount;
{
   return 2;
}

- (NSString *)labelText;
{
   return @"My gender is:";
}

- (NSString *)getCellTextForIndexPath:(NSIndexPath *)indexPath;
{
   if (indexPath.row == 0) {
      return @"Female";
   }
   if (indexPath.row == 1) {
      return @"Male";
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
   NSString *gender;
   if (self.checkedIndexPath.row == 0) {
      gender = @"2";  // female
   }
   if (self.checkedIndexPath.row == 1) {
      gender = @"1";  // male
   }
   myUserData.gender = gender;
   //[myUserData setValue:gender forKey:@"gender"];
   [server updateGender:gender];
   [self.navigationController pushViewController:[[RelationshipStatusViewController alloc] init] animated:YES];
}

@end
