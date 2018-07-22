//
//  CustomTabbedView.h
//  MMCM2
//
//  Created by Richard Montricul on 6/4/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabbedView : UIControl

@property (strong, nonatomic) NSMutableArray *tabArray;
@property NSInteger height;
@property NSInteger selectedTabIndex;
@property (strong, nonatomic) UIView *selectedView;

- (id)init:(NSArray *)TabValues;
- (UIView *)getViewForTabValue:(NSString *)tabValue;
- (void)setSelectedTab:(NSInteger)index;
- (void)setTabHeight:(NSInteger)Height forViewAtIndex:(NSInteger)index;

@end
