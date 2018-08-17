//
//  ProfileViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/14/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "ProfileViewController.h"
#import "Segment0.h"
#import "CameraViewController.h"
#import "GroupsViewController.h"
#import "FriendList.h"
#import "FriendsListViewController.h"

// Controls
#import "AddButton.h"

@interface ProfileViewController ()
@end

@implementation ProfileViewController {
   int shadowHeight;
   int tabFontSize;
   int margin;
   BOOL isMyProfile;
   NSInteger infoTableRows;
   NSArray *infoArray;
   BOOL friendListIsUpdated;
   BOOL groupListIsUpdated;
   FriendList *friendList;

   UIImageView *coverPhotoImageView;
   UITableView *tableView;
   UIView *segmentViewContainer;
   //UIButton *addButton;
   AddButton *addButton;

   Segment0 *segment0;
   UIView *segment1;
   UIView *selectedSegment;
   UIViewController *cameraViewController;

   BOOL forumsIsImplemented;
}


- (id)init:(User *)User; 
{
   self = [super init];
   _user = User;
   [self setupVars];
   [self selectSegmentWithIndex:0];
   return self;
}


#pragma setup
- (void)setupVars;
{
   forumsIsImplemented = NO;
   isMyProfile = [self isMyID:_user.userID];
   shadowHeight = 111;
   tabFontSize = 13;
   margin = 12;
   infoTableRows = 0;
   friendListIsUpdated = NO;
   groupListIsUpdated = NO;
   cameraViewController = [[CameraViewController alloc] init:self];
}


- (void)setupViews;
{
   [super setupViews];
   [self setupScrollView];
      [self setupFeatureView];
      [self testForTable];
      // [self setupSegmentedControl];
   [self setupAddButton];

   // [self registerForKeyboardNotifications];
   [self adjustViews];
}


- (void)setupScrollView;
{
   _scrollView = [[UIScrollView alloc] init];
   _scrollView.frame = screenRect;
   _scrollView.delegate = self;
   _scrollView.backgroundColor = [UIColor whiteColor];
   [self.view addSubview:_scrollView];
}


- (void)setupFeatureView;
{
   [self setupCoverPhoto];
   [self setupShadow];
   [self setupNameLabel];
   [self setupFeatureButton];
   [self setupEditProfileButton];
}

- (void)setupCoverPhoto;
{
   coverPhotoImageView = [[UIImageView alloc] init];
   coverPhotoImageView.contentMode = UIViewContentModeScaleAspectFill;
   CGRect rect = { {0,0}, [self imageSize] };
   coverPhotoImageView.frame = rect;
   coverPhotoImageView.image = [UIImage imageNamed:[self imageName]];
   [_scrollView addSubview:coverPhotoImageView];
}
- (CGSize)imageSize;
{
   return CGSizeMake(screenWidth,425);
}
- (NSString *)imageName;
{
   return @"tempImage";
}

- (void)setupShadow;
{
   UIView *view = [[UIView alloc] init];
   //view.backgroundColor = [UIColor blackColor];
   view.alpha = 1.0;
   view.frame = CGRectMake(0,CGRectGetMaxY(coverPhotoImageView.frame) - shadowHeight, screenWidth, shadowHeight);
   CAGradientLayer *gradient = [CAGradientLayer layer];
   gradient.frame = view.bounds;
   gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
   [view.layer insertSublayer:gradient atIndex:0];
   [_scrollView addSubview:view];
}

- (void)setupNameLabel;
{
   _nameLabel = [[UILabel alloc] init];
   _nameLabel.frame = CGRectMake(20,CGRectGetMaxY(coverPhotoImageView.frame) - 42 ,screenWidth,26);
   _nameLabel.textAlignment = NSTextAlignmentLeft;
   _nameLabel.text = [self labelText];
   _nameLabel.textColor = [UIColor whiteColor];
   _nameLabel.numberOfLines = 1;
   _nameLabel.font = [UIFont systemFontOfSize: 22 weight:UIFontWeightRegular];
   [_scrollView addSubview:_nameLabel];
}
- (NSString *)labelText;
{
   return _user.fullName;
}


- (void)setupFeatureButton;
{
   UIButton *button;
   if (isMyProfile) { // elipses button
      button = [self newMenuButon];
      button.center = _nameLabel.center;
      [ViewUtilities setX:screenWidth - 45 forView:button];
   }
   else { // chat button
      // button = [self newTextbutton:@"chat"];
      // [ViewUtilities setX:screenWidth - button.frame.size.width - 12 forView:button];
      // [_headerBackButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   }
   [_scrollView addSubview:button];
}


- (void)setupEditProfileButton;
{
   UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
   button.frame = CGRectMake(0,CGRectGetMaxY(coverPhotoImageView.frame) - 60, screenWidth, 60);
   [button setBackgroundColor: [UIColor clearColor]];
   [button addTarget:self action:@selector(editProfileClicked) forControlEvents:UIControlEventTouchUpInside];
   [_scrollView addSubview:button];
}


- (void)testForTable;
{
   if (isMyProfile){
      friendList = myFriendList;
      [friendList updateWithUserID:myUserData.userID withCompletionBlock:^void{
         friendListIsUpdated = YES;
         [self expandTable];
      }];
      [myGroupList updateWithCompletionBlock:^void{
         groupListIsUpdated = YES;
         [self expandTable];
      }];
      [self setupInfoTable:2];
   }
   else { // determine if I should show a table at all based on whether or not i am friends
          // with this person
      [server getUserRelationType:_user.userID
              withCompletionBlock:^void (NSString * result) {
         if ([result isEqual:@"1"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
               [self setupInfoTable:1];
            });
            friendList = [[FriendList alloc] initWithUserID:_user.userID];
            [friendList updateWithCompletionBlock:^void{
               friendListIsUpdated = YES;
               [self expandTable];
            }];
         }
      }];
   }
}


- (void)setupInfoTable:(NSInteger)rows;
{
   infoTableRows = rows;

   CGRect frame = CGRectMake(
         0,
         CGRectGetMaxY(coverPhotoImageView.frame),
         screenWidth,
         0);
   tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
   tableView.dataSource = self;
   tableView.delegate = self;
   tableView.scrollEnabled = NO;
   [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
   [tableView setBackgroundColor:[UIColor clearColor]];
   [_scrollView addSubview:tableView];
}


- (void)setupSegmentedControl;
{
   _segmentedControl = [[SegmentedControlWithSearch alloc] init:self];
   [_segmentedControl setSegmentTitles:@[@"#pics", @"#posts"]];
   NSInteger y = (infoTableRows > 0) ? CGRectGetMaxY(tableView.frame) : CGRectGetMaxY(coverPhotoImageView.frame);
   y = y + 20;
   [ViewUtilities setY:CGRectGetMaxY(coverPhotoImageView.frame) + 20 forView:_segmentedControl];
   [_scrollView addSubview:_segmentedControl];

   [_segmentedControl.segmentedControl
      addTarget:self
      action:@selector(selectSegment:)
      forControlEvents:UIControlEventValueChanged];

   [_segmentedControl.sortButton
      addTarget:self
      action:@selector(sortButtonClicked:)
      forControlEvents:UIControlEventTouchUpInside];

   [_segmentedControl.searchButton
      addTarget:self
      action:@selector(searchClicked)
      forControlEvents:UIControlEventTouchUpInside];

   [self setupSegmentViewContainer];
}


- (void)setupSegmentViewContainer;
{
   segmentViewContainer = [[UIView alloc] init];
   segmentViewContainer.frame = CGRectMake(0, CGRectGetMaxY(_segmentedControl.frame) + margin, screenWidth, 0);
   [_scrollView addSubview:segmentViewContainer];

   [self setupSegmentViews];
}


- (void)setupSegmentViews;
{
   // Segment 0
   segment0 = [[Segment0 alloc] init:_user delegate:self];
   [segment0 addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
   [segment0 addTarget:self action:@selector(segmentUpdated:)
      forControlEvents:(UIControlEvents)customControlEventContentsUpdated];
   [segmentViewContainer addSubview:segment0];

   // Segment 1
   UIView *view = [[UIView alloc] init];
   view.alpha = 0.0f;
   [segmentViewContainer addSubview:view];

   //General
   selectedSegment = segment0;
}


- (void)adjustViews;
{
   dispatch_async(dispatch_get_main_queue(), ^{
      [UIView animateWithDuration:0.2
         delay:0.0
         options: UIViewAnimationOptionCurveEaseIn
         animations:^{ 
            if (infoTableRows > 0)
               [ViewUtilities setY:CGRectGetMaxY(tableView.frame) + 20 forView:_segmentedControl];
            else
               [ViewUtilities setY:CGRectGetMaxY(coverPhotoImageView.frame) + 20 forView:_segmentedControl];
            [ViewUtilities setY:CGRectGetMaxY(_segmentedControl.frame) + margin forView:segmentViewContainer];
         } 
         completion:^(BOOL finished){
         }
      ];
      [ViewUtilities setHeight:selectedSegment.frame.size.height forView:segmentViewContainer];
      _scrollView.contentSize = CGSizeMake(
         screenWidth,
         CGRectGetMaxY(segmentViewContainer.frame) + addButton.frame.size.height);// + tabBarHeight);
   });
}


- (void)selectSegment:(UISegmentedControl *)sender;
{
   [self selectSegmentWithIndex:sender.selectedSegmentIndex];
}

- (void)selectSegmentWithIndex:(NSInteger)index;
{
   if (index == 0)
      selectedSegment = segment0;
   else {
      // selectedSegment = segment1;
   }
   [UIView animateWithDuration:0.1
      delay:0.0
      options: UIViewAnimationOptionCurveEaseIn
      animations:^{ 
         segment0.alpha = (index == 0) ? 1.0f : 0.0f;
         //segment1.alpha = 1 - segment0.alpha;
      } 
      completion:^(BOOL finished){
         [self adjustViews];
      }
   ];
   if (_segmentedControl.isExpanded == false) {
      [self.view endEditing:YES];
   }
}


- (void)editProfileClicked;
{


}

- (void)searchClicked;
{
   [UIView animateWithDuration:0.1
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         [ViewUtilities setY:CGRectGetMaxY(_segmentedControl.frame) + margin forView:segmentViewContainer];
      } 
      completion:^(BOOL finished){
         [self adjustViews];
      }
   ];
   if (_segmentedControl.isExpanded == false) {
      [self.view endEditing:YES];
   }
}


- (void)sortButtonClicked:(SortButton *)sender;
{
   [(Segment0 *)selectedSegment setSortIndex:sender.index];
}

- (void)segmentUpdated:(UIControl *)sender;
{
   // view content has been changed
   // does NOT involve interface changes
}

- (void)segmentChanged:(UIControl *)sender;
{
   // view content has been changed
   // DOES involve interface changes

   //[ViewUtilities setHeight:sender.height forView:segmentViewContainer];
   [self adjustViews];
}



- (void)newPhotoAdded;
{
   // TODO
}

// - (void)setupAddButton;
// {
//    int buttonDiameter = 60;
//    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.frame = CGRectMake(
//       screenWidth  - (buttonDiameter + margin),
//       screenHeight - (buttonDiameter + margin + tabBarHeight),
//       buttonDiameter,
//       buttonDiameter);
//    addButton.backgroundColor = themeColorLight;
//    [addButton setTintColor:[UIColor whiteColor]];
//    [addButton addTarget:self action:@selector(addButtonClicked) forControlEvents:UIControlEventTouchUpInside];
// 
//    // button icon
//       UIImage *image = [[UIImage imageNamed:@"addIconAlt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//       UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//       imageView.frame = CGRectMake(15, 15, buttonDiameter/2, buttonDiameter/2);
//       imageView.contentMode = UIViewContentModeScaleAspectFill;
//       [addButton addSubview:imageView];
//    // button border
//       addButton.layer.borderWidth = 4;
//       addButton.layer.borderColor = [UIColor whiteColor].CGColor;
//       addButton.layer.cornerRadius = buttonDiameter/2;
//       addButton.layer.masksToBounds = YES;
//    //shadow
//       UIView *shadow = [[UIView alloc] init];
//       shadow.frame = addButton.frame;
//       shadow.layer.cornerRadius = buttonDiameter/2;
//       shadow.backgroundColor = [UIColor whiteColor];
//       shadow.layer.shadowColor = [UIColor blackColor].CGColor;
//       shadow.layer.shadowOpacity = 0.5;
//       shadow.layer.shadowRadius = 1;
//       shadow.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//       [self.view addSubview:shadow];
// 
//    [self.view addSubview:addButton];
// }

- (void)setupAddButton;
{
   addButton = [[AddButton alloc] init];
   [ViewUtilities setXY:CGPointMake(
         screenWidth  - (addButton.diameter + margin),
         screenHeight - (addButton.diameter + margin + tabBarHeight))
      forView: addButton];
   [addButton addTarget:self action:@selector(addButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:addButton];
}

- (void)addButtonClicked;
{
   dispatch_async(dispatch_get_main_queue(), ^{
      [self presentViewController:cameraViewController animated:YES completion:^{
      }];
   });
}


#pragma Keybaord functions
- (void)keyboardWillShow:(NSNotification *)aNotification 
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height + 10, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _segmentedControl.searchTextField.frame.origin) ) {
        [_scrollView scrollRectToVisible:_segmentedControl.searchTextField.frame animated:YES];
    }
}

- (void)keyboardWasShown:(NSNotification *)aNotification 
{
}
- (void)keyboardWillHide:(NSNotification *)notification 
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}


#pragma UITableView methods
//=======================================================================================================
- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
//=======================================================================================================
   static NSString *CellIdentifier = @"Cell";
   UITableViewCell *cell = [TableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil){
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textLabel.font = [UIFont systemFontOfSize: 16 weight:UIFontWeightSemibold];
      cell.detailTextLabel.font = [UIFont systemFontOfSize: 13 weight:UIFontWeightRegular];
   }
   if (infoTableRows == 2) { // friendList + groupList
      if (friendListIsUpdated && groupListIsUpdated) {
         if (indexPath.row == 0)
            return [self cellForFriendList:cell];
         else
            return [self cellForGroupList:cell];
      }
      else if (friendListIsUpdated)
         return [self cellForFriendList:cell];
      else 
         return [self cellForGroupList:cell];
   }
   if (infoTableRows == 1) { // friendlist
      if (friendListIsUpdated)
         return [self cellForFriendList:cell];
   }
   return cell;
}
//==============================================================
- (UITableViewCell *)cellForFriendList:(UITableViewCell *)cell {
//==============================================================
   if (isMyProfile)
      cell.textLabel.text = @"My Network";
   else
      cell.textLabel.text = @"Network";
   NSString *str = [NSString stringWithFormat:
      @"%ld friends, %ld singles", 
      [friendList.dicAllFirstDegree count],
      [friendList.arrSinglesFirstDegree count]];
   cell.detailTextLabel.text = str;
   cell.tag = 0;
   return cell;
}
//=============================================================
- (UITableViewCell *)cellForGroupList:(UITableViewCell *)cell {
//=============================================================
   cell.textLabel.text = @"My Groups";
   NSString *str = [NSString stringWithFormat:
      @"%ld groups, %ld singles", 
      [myGroupList.groupDictionary count],
      [myGroupList getSinglesCount]];
   cell.detailTextLabel.text = str;
   cell.tag = 1;
   return cell;
}
//=============================================================================================
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath; { return 75;}
//=============================================================================================
//==================================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; { return 1; }
//==================================================================
//=========================================================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section; {
//=========================================================================================
   int rows = 0;
   if (groupListIsUpdated)
      rows++;
   if (friendListIsUpdated)
      rows++;
   return rows;
}
//============================================================================================
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath; {
//============================================================================================
   UIViewController *viewController;
   if (infoTableRows == 2) {
      UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
      if (cell.tag == 0)  // My Network
         viewController = [[FriendsListViewController alloc] init:friendList];
      else                // My Groups
         viewController = [[GroupsViewController alloc] init];
   }
   else { 
      viewController = [[FriendsListViewController alloc] init:friendList];
   }
   if (viewController)
      [self.navigationController pushViewController:viewController animated:YES];

}

- (void)expandTable;
{
   dispatch_async(dispatch_get_main_queue(), ^{
      [UIView animateWithDuration:0.2
         delay:0.0
         options: UIViewAnimationOptionCurveEaseIn
         animations:^{ 
            [tableView reloadData];
            [ViewUtilities setHeight:tableView.frame.size.height + 75 forView:tableView];
            [self adjustViews];
         } 
         completion:^(BOOL finished){
         }
      ];
   });
}

#pragma UNSED/OLD Code
/*
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height + 10, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, control.searchTextField.frame.origin) ) {
        [_scrollView scrollRectToVisible:control.searchTextField.frame animated:YES];
    }
    // if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
    //     [_scrollView scrollRectToVisible:activeField.frame animated:YES];
    // }
}
*/

@end
