//
//  NetworkDetailViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 5/10/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "CommonViewController.h"
#import "SegmentedControlWithSearch.h"
#import "FriendCollectionViewCell.h"

@interface NetworkDetailViewController : CommonViewController
   <UICollectionViewDelegate,
   UICollectionViewDataSource>
@property (strong, nonatomic) UIButton *headerMenuButton;
@property (strong, nonatomic) UIView *contentPanel;
// @property (strong, nonatomic) UIView *segment0ContentView;
// @property (strong, nonatomic) UIView *segment1ContentView;
@property (strong, nonatomic) NSArray *segmentViews;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) SegmentedControlWithSearch *segmentedControl;

- (void)selectSegment:(UISegmentedControl *)sender;
@end
