//
//  CustomTabBar.h
//  MMCM2
//
//  Created by Richard Montricul on 6/4/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabBar : UIControl

@property (nonatomic) NSInteger selectedTabIndex;
@property NSInteger edgeMargin;
@property NSInteger tabMargin;
@property NSInteger height;
@property (strong, nonatomic) NSArray *tabValues;
@property (strong, nonatomic) NSMutableArray *tabArray;
@property (strong, nonatomic) UIButton *test;

- (id)init:(NSArray *)TabValues;
- (void)setTabValues:(NSArray *)TabValues;
- (void)setFont:(NSInteger)size;
- (void)setSelectedTabIndex:(NSInteger)index;
@end
