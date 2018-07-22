//
//  FriendsListViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 11/3/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "FriendsListViewController.h"

// Other Local imports
   #import "FriendCollectionViewCell.h"
   #import "SegmentedControlWithSearch.h"
   #import "ProfileViewController.h"

@interface FriendsListViewController ()
@end

@implementation FriendsListViewController {
}


//====================================
- (id)init:(FriendList *)FriendList; {
//====================================
   self = [super init];
   _friendList = FriendList;
   return self;
}

//=========================
- (BOOL)useSeperateViews; {
//=========================
   return NO;
}

//=========================
- (NSString *)headerText; {
//=========================
   return @"My Network";
}

//======================
- (BOOL)showSubHeader; {
//======================
   return YES;
}

//============================
- (NSString *)subHeaderText; {
//============================
//
   return [NSString stringWithFormat:
      @"%ld friends, %ld singles", 
      [_friendList.dicAllFirstDegree count],
      [_friendList.arrSinglesFirstDegree count]];
}

//===========================
- (NSArray *)segmentTitles; {
//===========================
   return @[@"Friends", @"Singles"];
}

//=================================================================================
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//=================================================================================
    if ([_friendList.dicAllSecondDegree count] > 0) {
       return 2;
    }
    else 
       return 1;
}

//=========================================================================================================
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section; {
//=========================================================================================================
   if (self.segmentedControl.selectedSegmentIndex == 0) { // All friends
      if (section == 0) { // First Degree
         return [_friendList.dicAllFirstDegree count];
      }
      else {
         return [_friendList.dicAllSecondDegree count];
      }
   }
   else { // Only Singles
      if (section == 0) { // First Degree
         return [_friendList.arrSinglesAndComplicatedFirstDegree count];
      }
      else //Second Degree
         return [_friendList.arrSinglesAndComplicatedSecondDegree count];
   }
}

//============================================================================================================================
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
//============================================================================================================================
   FriendCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
   User *user = [self userForIndexPath:indexPath];
   [cell setText:user.firstName];
   cell.imageView.image = user.image;
   return cell;
}



//===================================================
- (void)selectSegment:(UISegmentedControl *)sender; {
//===================================================
   [self.collectionView reloadData];
}


//===================
- (void)setupViews; {
//===================
   [super setupViews];
   [self setupCollectionView];
   [self.segmentedControl setSortValues:@[@"sort:recent ",@"sort: alphabetical"]];
   //[self setSelectedSegment:0];
}


//============================
- (void)setupCollectionView; {
//============================
   [self.contentPanel addSubview:self.collectionView];
}


// //============================================
// - (void)setSelectedSegment:(NSInteger)index; {
// //============================================
//    self.segmentedControl.segmentedControl.selectedSegmentIndex = index;
//    [super selectSegment:self.segmentedControl];
// }

//==========================================
- (void)segmentedControlSortButtonClicked; {
//==========================================
   [self.collectionView reloadData];
}


//===========================================================================================================
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//===========================================================================================================
   ProfileViewController *viewController = [[ProfileViewController alloc] init:[self userForIndexPath:indexPath]];
   [self.navigationController pushViewController:viewController animated:YES];
}

//====================================================
- (User *)userForIndexPath:(NSIndexPath *)indexPath; {
//====================================================
   NSDictionary *userDictionary;
   NSArray *arrSort;
   NSArray *arrFilter;
   if (indexPath.section == 0) {
      userDictionary = _friendList.dicAllFirstDegree;
      if (self.segmentedControl.sortIndex == 0)
         arrSort = _friendList.arrFirstDegreeByDate;
      else
         arrSort = _friendList.arrFirstDegreeByAlpha;
      if (self.segmentedControl.selectedSegmentIndex == 1)
         arrFilter = _friendList.arrSinglesAndComplicatedFirstDegree;
   }
   else {
      userDictionary = _friendList.dicAllSecondDegree;
      if (self.segmentedControl.sortIndex == 0)
         arrSort = _friendList.arrSecondDegreeByDate;
      else
         arrSort = _friendList.arrSecondDegreeByAlpha;
      if (self.segmentedControl.selectedSegmentIndex == 1)
         arrFilter = _friendList.arrSinglesAndComplicatedSecondDegree;
   }
   NSString *key;
   if (arrFilter && [arrFilter count] > 0)
      key = [[_friendList getSortedFilterWithFilter:arrFilter sort:arrSort] objectAtIndex:indexPath.row];
   else
      key = [arrSort objectAtIndex:indexPath.row];

   return [userDictionary objectForKey:key];
   
}

@end
