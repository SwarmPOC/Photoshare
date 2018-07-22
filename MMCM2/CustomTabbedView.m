//
//  CustomTabbedView.m
//  MMCM2
//
//  Created by Richard Montricul on 6/4/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "CustomTabbedView.h"
#import "CustomTabBar.h"
#import "Global.h"
#import "ViewUtilities.h"

@implementation CustomTabbedView {
   CGFloat animationDuration;
   NSArray *tabValues;
   NSMutableDictionary *tabDictionary;

   CustomTabBar *tabBar;
}


- (id)init:(NSArray *)TabValues;
{
   self = [super init];
   tabValues = TabValues;
   [self setupVars];
   [self setupViews];
   return self;
}

- (void)setupVars;
{
   animationDuration = 0.1f;
   _tabArray = [[NSMutableArray alloc] init];
   tabDictionary = [[NSMutableDictionary alloc] init];
   tabBar = [[CustomTabBar alloc] init:tabValues];
}

- (void)setupViews;
{
   [self setupTabBar];
   self.frame = CGRectMake(0,0,screenWidth, _height);
   self.backgroundColor = [UIColor redColor];
   [self setupTabs];
}

- (void)setupTabBar;
{
   [tabBar addTarget:self action:@selector(tabWasSelected:) forControlEvents:UIControlEventValueChanged];
   [self addSubview:tabBar];
   _height = tabBar.height;
}

- (void)setupTabs;
{
   for (NSString *str in tabValues) {
      UIView *view = [[UIView alloc] init];
      [_tabArray addObject:view];
      [tabDictionary setObject:view forKey:str];

      // XXX
      view.backgroundColor = [UIColor greenColor];
      // XXX

      [self addSubview:view];
   }
}

- (void)setSelectedTab:(NSInteger)index;
{
   [tabBar setSelectedTabIndex:index];
}


- (void)tabWasSelected:(CustomTabBar *)sender;
{
   if (_selectedView) {
      [ViewUtilities fadeView:_selectedView toAlpha:0.0f duration:animationDuration];
   }
   _selectedView = [_tabArray objectAtIndex:sender.selectedTabIndex];
   _height = [self getHeight];
   [ViewUtilities fadeView:_selectedView toAlpha:1.0f duration:animationDuration];
   [self sendActionsForControlEvents:UIControlEventValueChanged];
   _selectedTabIndex = sender.selectedTabIndex;
}


- (NSInteger)getHeight;
{
   return _selectedView.frame.size.height + tabBar.height;
}

- (void)setTabHeight:(NSInteger)Height forViewAtIndex:(NSInteger)index;
{
   [ViewUtilities setHeight:Height forView:[_tabArray objectAtIndex:index]];
   _height = tabBar.height + _selectedView.frame.size.height;
}


- (UIView *)getViewForTabValue:(NSString *)tabValue;
{
   return [tabDictionary objectForKey:tabValue];
}
- (UIView *)getViewforTabAtIndex:(NSInteger)index;
{
   return [_tabArray objectAtIndex:index];
}

@end
