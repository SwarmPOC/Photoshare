//
//  RelationshipStatusViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "RelationshipStatusViewController.h"
#import "LookingForViewController.h"
#import "CompleteViewController.h"

@interface RelationshipStatusViewController ()

@end

@implementation RelationshipStatusViewController

- (int)getRowCount;
{
   return 3;
}

- (NSString *)labelText;
{
   return @"My relationship status is:";
}

- (NSString *)getCellTextForIndexPath:(NSIndexPath *)indexPath;
{
   if (indexPath.row == 0) {
      return @"Single";
   }
   if (indexPath.row == 1) {
      return @"In a relationship";
   }
   if (indexPath.row == 2) {
      return @"It's complicated";
   }
   return @"";
}

- (void)next;
{
   NSString *status;
   if (self.checkedIndexPath.row == 0) {
      status = @"1"; 
   }
   if (self.checkedIndexPath.row == 1) {
      status = @"2"; 
   }
   if (self.checkedIndexPath.row == 2) {
      status = @"4"; 
   }
   [myUserData setValue:status forKey:@"relationshipStatus"];
   [server updateRelationshipStatus:status isInitialStatus:YES];
   UIViewController *viewController;
   if ([status isEqual:@"1"] || [status isEqual:@"4"]) {
      viewController = [[LookingForViewController alloc] init];
   }
   else if ([status isEqual:@"2"]) {
      viewController = [[CompleteViewController alloc] init];
   }
   [self.navigationController pushViewController:viewController animated:YES];
}
@end
