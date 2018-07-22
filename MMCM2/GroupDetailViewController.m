//
//  GroupDetailViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 5/10/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "ProfileViewController.h"
#import "User.h"

@interface GroupDetailViewController ()
@end

@implementation GroupDetailViewController {
   NSString *groupDetailLastEvaluatedKey;
   BOOL groupDetailMaxUserReached;
}


//==========================
- (id)init:(Group *)Group; {
//==========================
   self = [super init];
   _group = Group;
   return self;
}

//=========================
- (NSString *)headerText; {
//=========================
   return _group.name;
}

//======================
- (BOOL)showSubHeader; {
//======================
   return YES;
}

//============================
- (NSString *)subHeaderText; {
//============================
   return [NSString stringWithFormat:
      @"%@ members, %@ singles", 
      _group.memberCount,
      _group.singlesCount];
}

//===========================
- (NSArray *)segmentTitles; {
//===========================
   return @[@"Members", @"Forum"];
}

//=================================================================================
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//=================================================================================
    return 1;
}

//=========================================================================================================
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section; {
//=========================================================================================================
   return [_group.userDictionary count];
}

//============================================================================================================================
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
//============================================================================================================================
   FriendCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
   User *user = [_group.userDictionary objectForKey:[[self getCurrentSort] objectAtIndex:indexPath.row]];
   [cell setText:user.firstName];
   cell.imageView.image = user.image;
   if ((indexPath.row == [_group.userDictionary count] - 1) && (!_group.allUsersPulled)) {
      [_group pullUsersWithCompletionBlock:^void{
         dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
         });
      }];
   }
   return cell;
}

//=====================================
- (void)headerAccessoryButtonClicked; {
//=====================================
}

//====================================================
- (void)selectSegment:(UISegmentedControl *)segment; {
//====================================================
   [super selectSegment:segment];
   //[self setSelectedSegment:segment.selectedSegmentIndex];
}


//===================
- (void)setupViews; {
//===================
   [super setupViews];
   [self setupCollectionView];
   [self setSelectedSegment:0];
   [_group pullUsersWithCompletionBlock:^void {
      dispatch_async(dispatch_get_main_queue(), ^{
         [self.collectionView reloadData];
      });
   }];
}

//============================
- (void)setupCollectionView; {
//============================
   [[self.segmentViews objectAtIndex:0] addSubview:self.collectionView];
}

//============================================
- (void)setSelectedSegment:(NSInteger)index; {
//============================================
   self.segmentedControl.segmentedControl.selectedSegmentIndex = index;
   [super selectSegment:self.segmentedControl];
}

//==========================================
- (void)segmentedControlSortButtonClicked; {
//==========================================
   [self.collectionView reloadData];
}


//===========================================================================================================
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//===========================================================================================================
   ProfileViewController *viewController = [[ProfileViewController alloc]
      init:[_group.userDictionary objectForKey:[[self getCurrentSort] objectAtIndex:indexPath.row]] ];
   [self.navigationController pushViewController:viewController animated:YES];
}

//============================
- (NSArray *)getCurrentSort; {
//============================
   switch (self.segmentedControl.sortButton.index == 0) {
      case 0:
         return _group.userArrayByDate;
         break;
      case 1:
         return _group.userArrayByName;
         break;
      default:
         return _group.userArrayByDate;
         break;
   }
}


@end
