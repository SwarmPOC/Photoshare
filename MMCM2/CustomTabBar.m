//
//  CustomTabBar.m
//  MMCM2
//
//  Created by Richard Montricul on 6/4/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "CustomTabBar.h"
#import "Global.h"
#import "ViewUtilities.h"

@implementation CustomTabBar {
   NSMutableDictionary *tabDictionary;
   UIButton *selectedButton;
   BOOL isAnimated;
   NSInteger fontSize;
   NSInteger prevSelectedTabIndex;
}

- (id)init:(NSArray *)TabValues;
{
   self = [super init];
   prevSelectedTabIndex = -1;
   _selectedTabIndex = 0;
   _edgeMargin = 15;
   _tabMargin = 15;
   _height = 40;
   isAnimated = YES;
   fontSize = 13;
   _tabArray = [[NSMutableArray alloc] init];
   tabDictionary = [[NSMutableDictionary alloc] init];

   self.frame = CGRectMake(0,0,screenWidth, _height);
   self.backgroundColor = [UIColor greenColor];

   [self setTabValues:TabValues];
   [self selectTab:[_tabArray objectAtIndex:_selectedTabIndex]];

   return self;
}


- (void)setTabValues:(NSArray *)TabValues;
{
   _tabValues = TabValues;
   int i = 0;
   for (NSString *value in _tabValues) {
      UIButton *button = [self newTabButton:value];
      button.tag = i++;
   }
   [self arrangeTabs];
}


- (void)setFont:(NSInteger)size;
{
   fontSize = size;
   for (UIButton *button in _tabArray) {
      [self adjustTab:button];
   }
   [self arrangeTabs];
}

- (UIButton *)newTabButton:(NSString *)title;
{
   UIButton *button = [[UIButton alloc] init];
   [button setTitle:title forState:UIControlStateNormal];
   [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
   button.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold];
   [button sizeToFit];
   [ViewUtilities setHeight:_height forView:button];
   [button addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
   [_tabArray addObject:button];
   [tabDictionary setObject:button forKey:title];
   [self addSubview:button];
   return button;
}


- (void)setSelectedTabIndex:(NSInteger)index;
{
   [self selectTab:[_tabArray objectAtIndex:index]];
}


- (void)selectTab:(UIButton *)sender;
{
   if ((_selectedTabIndex != sender.tag) || (prevSelectedTabIndex == -1)) {
      if (selectedButton) {
         selectedButton.selected = NO;
         selectedButton.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
      }
      sender.selected = YES;
      sender.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightBold];
      selectedButton = sender;
      prevSelectedTabIndex = _selectedTabIndex;
      _selectedTabIndex = sender.tag;
      [self adjustTab:sender];
      [self arrangeTabs];
      [self sendActionsForControlEvents:UIControlEventValueChanged];
   }
}

- (void)adjustTab:(UIButton *)button;
{
   [button sizeToFit];
   [ViewUtilities setHeight:_height forView:button];
}

- (void)arrangeTabs;
{
   NSInteger mark = screenWidth - _edgeMargin;
   for (NSInteger index = [_tabArray count] - 1; index >= 0; index--) {
      UIButton *button = [_tabArray objectAtIndex:index];
      mark = mark - button.frame.size.width;
      [ViewUtilities setX:mark forView:button];
      mark = mark - _tabMargin;
   }
}
@end
