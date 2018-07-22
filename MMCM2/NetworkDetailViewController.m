//
//  NetworkDetailViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 5/10/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "NetworkDetailViewController.h"

@interface NetworkDetailViewController ()

@end

@implementation NetworkDetailViewController

#pragma functions that should be included with subclass
- (NSString *)headerText;
{
   return @"";
}
- (BOOL)showSubHeader;
{
   return NO;
}
- (NSString *)subHeaderText;
{
   return @"";
}
- (void)headerAccessoryButtonClicked;
{
}
- (NSArray *)segmentTitles;
{
   return @[@"", @""];
}
- (void)selectSegment:(UISegmentedControl *)sender;
{
   ((UIView *)([_segmentViews objectAtIndex:sender.selectedSegmentIndex])).alpha = 1.0f;
   ((UIView *)([_segmentViews objectAtIndex:1-sender.selectedSegmentIndex])).alpha = 0.0f;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView 
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
   return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
   NSString *identifier = @"cell";
   FriendCollectionViewCell *cell = (FriendCollectionViewCell*) [collectionView
      dequeueReusableCellWithReuseIdentifier:identifier
      forIndexPath:indexPath];
   if (cell == nil)
      cell = [[FriendCollectionViewCell alloc] initWithFrame:CGRectMake(0,0,70,100)];
   return cell;
}



#pragma prefilled defaults that probably do not need to be modified
- (BOOL)showHeader;
{
   return YES;
}
- (NSInteger)headerHeight;
{
   return 50;
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
   return MENU;
}

#pragma common code
- (void)setupViews;
{
   [super setupViews];
   [self setupNDSegmentedControl];
   [self setupContentPanel];
   [self _setupCollectionView];
}


- (void)setupNDSegmentedControl;
{
   _segmentedControl = [[SegmentedControlWithSearch alloc] init:self];
   [_segmentedControl setSegmentTitles:[self segmentTitles]];
   // [panel addSubview:segmentedControl];
   [ViewUtilities setY:CGRectGetMaxY(self.subHeaderLabel.frame) + 16 forView:_segmentedControl];
   [_segmentedControl.segmentedControl 
      addTarget:self 
      action:@selector(selectSegment:)
      forControlEvents:UIControlEventValueChanged];
   [_segmentedControl.sortButton
      addTarget:self
      action:@selector(segmentedControlSortButtonClicked)
      forControlEvents:UIControlEventTouchUpInside];
   [_segmentedControl.searchButton
      addTarget:self
      action:@selector(segmentedControlSearchButtonClicked)
      forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:_segmentedControl];
}


- (void)setupContentPanel;
{
   _contentPanel = [[UIView alloc] init];
   NSInteger y = CGRectGetMaxY(_segmentedControl.frame) + 12;
   _contentPanel.frame = CGRectMake(0, y, screenWidth, screenHeight - y - tabBarHeight);
   [self.view addSubview:_contentPanel];

   if ([self useSeperateViews]) {
      _segmentViews = [[NSArray alloc] init];
      _segmentViews = @[[self newSegmentContentView], [self newSegmentContentView]];
   }
}

- (BOOL)useSeperateViews;
{
   return YES;
}

- (void)_setupCollectionView;
{
   _collectionView = [self newNetworkCollectionView];
}

- (UICollectionView *)newNetworkCollectionView;
{
   UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
   [layout setItemSize:CGSizeMake(70, 100)];
   [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
   layout.minimumLineSpacing = 20;
   layout.minimumInteritemSpacing = 0;

   UICollectionView *collectionView = [[UICollectionView alloc]
      //initWithFrame:CGRectMake(0,10,.8*screenWidth, screenHeight - y - 10)
      initWithFrame:CGRectMake(0.1*screenWidth,0,.8*screenWidth, _contentPanel.frame.size.height)
      collectionViewLayout:layout];
   collectionView.backgroundColor = [UIColor whiteColor];
   collectionView.delegate = self;
   collectionView.dataSource = self;
   collectionView.showsVerticalScrollIndicator = NO;
   [collectionView registerClass:[FriendCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
   return collectionView;
}


- (UIView *)newSegmentContentView;
{
   UIView *view  = [[UIView alloc] init];
   view.frame = CGRectMake(0,0,screenWidth,_contentPanel.frame.size.height);
   view.backgroundColor = [UIColor whiteColor];
   [_contentPanel addSubview:view];
   return view;
}


- (void)segmentedControlSortButtonClicked;
{
}


- (void)segmentedControlSearchButtonClicked;
{
   [UIView animateWithDuration:0.1
     delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         NSInteger y = CGRectGetMaxY(_segmentedControl.frame) + 12;
         NSInteger h = screenHeight - y - tabBarHeight;
            _contentPanel.frame = CGRectMake(0, y, screenWidth, h);
            [ViewUtilities setHeight:h forView:_collectionView];
            if ([self useSeperateViews]) {
               [ViewUtilities setHeight:h forView:_segmentViews[0]];
               [ViewUtilities setHeight:h forView:_segmentViews[1]];
            }
      } 
      completion:^(BOOL finished){
      }
   ];
   if (_segmentedControl.isExpanded == false) {
      [self.view endEditing:YES];
   }
}

@end
