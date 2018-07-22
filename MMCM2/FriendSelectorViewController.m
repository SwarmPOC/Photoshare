//
//  FriendSelectorViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 2/7/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "FriendSelectorViewController.h"
#import "CameraViewController.h"

@interface FriendSelectorViewController ()

@end

@implementation FriendSelectorViewController

static UITableView *tableView;
static NSMutableDictionary *userDict;
static NSMutableArray *arrSelected;
static NSMutableArray *arrAllUserIDs;
static CameraViewController *reference;

- (id)init:(UIViewController *)viewController array:(NSArray *)array
{
   self = [super init];
   reference = (CameraViewController *)viewController;
   arrSelected = [[NSMutableArray alloc] init];
   if (array.count > 0) {
      [arrSelected addObjectsFromArray:array];
   }
   return self;
}

- (void)setupViews;
{
   [super setupViews];
   [ViewUtilities setY:CGRectGetMaxY(self.headerLabel.frame) + 20 forView:self.tableView];
   // [server retrieveFriendsForUser:^void (NSArray *friendArray) {
   //    [self processResult:friendArray];
   //    dispatch_async(dispatch_get_main_queue(), ^{
   //       self.headerLabel.text = @"select your friends";
   //       [self setTableHeight];
   //       [self.tableView reloadData];
   //    });
   // }];
}


- (NSString *)headerText;
{
   return @"select your friends";
   //return @"retrieving friends list...";
}


- (NSInteger)getRowCount{
   return [myFriendList.dicAllFirstDegree count];
   // if (arrAllUserIDs.count > 0) {
   //  return arrAllUserIDs.count;
   // }
   // else return 0;
}


- (void)customizeNewCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath 
{
   UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
   switchView.onTintColor = themeColor;
   switchView.tag = indexPath.row;
   [switchView addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventTouchUpInside];
   cell.accessoryView = switchView;
   cell.textLabel.font = [UIFont systemFontOfSize: 15 weight:UIFontWeightRegular];
}

- (void)customizeCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath 
{
   cell.textLabel.text = [self getCellTextForIndexPath:indexPath];
   UISwitch *switchView = (UISwitch *)cell.accessoryView;
   if ([arrSelected containsObject:[myFriendList.arrFirstDegreeByAlpha objectAtIndex:indexPath.row]]) {
      [switchView setOn:YES animated:YES];
   }
}


- (NSString *)getCellTextForIndexPath:(NSIndexPath *)indexPath;
{
   NSDictionary *dic = [myFriendList.dicAllFirstDegree objectForKey:
      [myFriendList.arrFirstDegreeByAlpha objectAtIndex:indexPath.row]];
   return [dic objectForKey:@"fullName"];
   // if (userDict) {
   //    return [userDict objectForKey:[arrAllUserIDs objectAtIndex:indexPath.row]];
   // }
   // return @"";
}

- (void)updateSwitchAtIndexPath:(UISwitch *)sender 
{
   NSDictionary *dic = [myFriendList.dicAllFirstDegree objectForKey:
      [myFriendList.arrFirstDegreeByAlpha objectAtIndex:sender.tag]];
   NSString *userID = [dic objectForKey:@"userID"];
   //NSString *userID = [arrAllUserIDs objectAtIndex:sender.tag];

   if (sender.on) {//The new state of the switch 
      [arrSelected addObject:userID];
   }
   else {
      [arrSelected removeObject:userID];
   }
}

- (NSString *)nextButtonText;
{
   return @"done";
}

- (void)next;
{
   [reference setSelected:arrSelected];
   //[reference setSelected:arrSelected userDict:userDict];
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)processResult:(NSArray *)array;
{
   userDict = [[NSMutableDictionary alloc] init];
   arrAllUserIDs = [[NSMutableArray alloc] init];
   for (NSDictionary *user in array) {
      NSString *userID = [[user allKeys] firstObject];
      NSString *name = [[user allValues] firstObject];
      [userDict setObject:name forKey:userID];
      [arrAllUserIDs addObject:userID];
   }
}
@end
