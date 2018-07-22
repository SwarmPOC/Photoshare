//
//  GroupsViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 4/4/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "GroupsViewController.h"
#import "AddGroupViewController.h"
#import "SortButton.h"
#import "GroupDetailViewController.h"
#import "Group.h"

@interface GroupsViewController ()

@end

@implementation GroupsViewController {

   UIButton *groupHeaderButton;
   SortButton *groupSortButton;
   NSMutableArray *groupArray;
   NSArray *sortedArrGroupsByName;
   UITableView *groupsTableView;
   BOOL isFirstLoad;
}



- (BOOL)showHeader;
{
   return YES;
}
- (NSInteger)headerHeight;
{
   return 50;
}
- (NSString *)headerText;
{
   return @"My Groups";
}
- (BOOL)showBackButton;
{
   return YES;
}
- (BOOL)showHeaderAccessoryButton;
{
   return YES;
}
- (HEADER_ACCESSORY_BUTTON_TYPE)headerAccessoryButtonType;
{
   return ADD;
}

- (void)viewDidAppear:(BOOL)animated;
{
   if (!isFirstLoad) {
      [myGroupList updateWithCompletionBlock:^void {
         dispatch_async(dispatch_get_main_queue(), ^{
            [groupsTableView reloadData];
         });
      }];
   }
}

- (void)setupVars;
{
   [super setupVars];
   isFirstLoad = YES;
}


- (void)setupViews;
{
   [super setupViews];
   [self setupHeaderButton];
   [self setupSubHeader];
   [self setupTable];
}


- (void)setupHeaderButton;
{
   groupHeaderButton = [self newButtonHeaderRight:ADD];
   [groupHeaderButton addTarget:self action:@selector(addGroupButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:groupHeaderButton];
}


- (void)setupSubHeader;
{
   groupSortButton = [[SortButton alloc] init];
   [groupSortButton setSortValues:@[@"sort: alphabetical",@"sort: recent",@"sort: member count",@"sort: single count"]];
   [ViewUtilities setXY:CGPointMake(screenWidth - groupSortButton.frame.size.width - 20, 50) forView:groupSortButton];
   [groupSortButton addTarget:self action:@selector(sortButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:groupSortButton];
}


- (void)setupTable;
{
   CGRect frame = CGRectMake(0, 80, screenWidth, screenHeight - 80);
   groupsTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
   groupsTableView.dataSource = self;
   groupsTableView.delegate = self;
   [groupsTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
   //[groupsTableView setBackgroundColor:[UIColor whiteColor]];
   [self.view addSubview:groupsTableView];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
   static NSString *CellIdentifier = @"Cell";
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil){
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textLabel.font = [UIFont systemFontOfSize: 16 weight:UIFontWeightSemibold];
      cell.detailTextLabel.font = [UIFont systemFontOfSize: 13 weight:UIFontWeightRegular];
   }
   Group *group = [myGroupList.groupDictionary objectForKey:[[self getCurrentSort] objectAtIndex:indexPath.row]];
   cell.textLabel.text = group.name;;
   NSString *str = [NSString stringWithFormat:
      @"%@ members, %@ singles", 
      group.memberCount,
      group.singlesCount];
   cell.detailTextLabel.text = str;
   return cell;
}


-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath 
{
   return 75;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
   return [myGroupList.groupDictionary count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

   Group *group = [myGroupList.groupDictionary objectForKey:[[self getCurrentSort] objectAtIndex:indexPath.row]];
   dispatch_async(dispatch_get_main_queue(), ^{
      [self.navigationController pushViewController:[[GroupDetailViewController alloc] init:group] animated:YES];
   });
}

- (void)addGroupButtonClicked;
{
   isFirstLoad = NO;
   dispatch_async(dispatch_get_main_queue(), ^{
      [self.navigationController pushViewController:[[AddGroupViewController alloc] init] animated:YES];
   });
}


- (void)sortButtonClicked;
{
   [groupsTableView reloadData];
}

- (NSArray *)getCurrentSort;
{
   switch (groupSortButton.index) {
      case 0:
         return myGroupList.groupIDByAlpha;
         break;
      case 1:
         return myGroupList.groupIDByDate;
         break;
      case 2:
         return myGroupList.groupIDByMemberCount;
         break;
      case 4:
         return  myGroupList.groupIDBySinglesCount;
         break;
      default:
         return myGroupList.groupIDByAlpha;
         break;
   }
}

@end
