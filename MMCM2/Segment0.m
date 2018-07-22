//
//  Segment0.m
//  MMCM2
//
//  Created by Richard Montricul on 6/6/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "Segment0.h"
#import "ViewUtilities.h"


@implementation Segment0 {
   CommonSegmentView *selectedView;
}


- (id)init:(User *)UserData delegate:(id)Delegate; 
{
   self = [super init:UserData delegate:Delegate];
   [self selectTab:0];
   return self;
}


- (void)setupVars;
{
   [super setupVars];
}

- (void)setupViews;
{
   [super setupViews];
   [self setupTabBar];
   [self setupTopTagsView];
   [self setupPeopleView];
   [self setupFavoritesView];
   [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setupTabBar;
{
   self.tabBar = [[CustomTabBar alloc] init:@[@"top tags",@"people", @"favorites"]];
   [self.tabBar addTarget:self action:@selector(tabWasSelected:) forControlEvents:UIControlEventValueChanged];
   [self addSubview:self.tabBar];
}

- (void)setupTopTagsView;
{
   _tagView = [[TopTagsView alloc] init:self.userData delegate:self.delegate];
   [self registerView:_tagView withKey:@"topTags"];
}

- (void)setupPeopleView;
{
   UIControl *view = [[UIControl alloc] init];
   [self registerView:view withKey:@"people"];
}

- (void)setupFavoritesView;
{
   UIControl *view = [[UIControl alloc] init];
   [self registerView:view withKey:@"favorites"];
}

- (void)registerView:(id)view withKey:(NSString *)key;
{
   [ViewUtilities setY:self.tabBar.frame.size.height forView:view];
   [(UIControl *)view addTarget:self action:@selector(viewUpdated:)
       forControlEvents:(UIControlEvents)customControlEventContentsUpdated];
   [(UIControl *)view addTarget:self action:@selector(viewHasNewContent:) forControlEvents:UIControlEventValueChanged];
   [self addSubview:view];
}


- (void)tabWasSelected:(CustomTabBar *)sender;
{
   [self selectTab:sender.selectedTabIndex];
   // set sortValues to property
   [self sendActionsForControlEvents:UIControlEventValueChanged];
   // change sort buttons for segmented Control (parent)
}

- (void)selectTab:(NSInteger)index;
{
   CGFloat animationDuration = 0.1f;
   if (selectedView) {
      [ViewUtilities fadeView:selectedView toAlpha:0.0f duration:animationDuration];
   }
   selectedView = [self getSelectedView];
   [ViewUtilities fadeView:selectedView toAlpha:1.0f duration:animationDuration];
}

- (void)setSortIndex:(NSInteger)index;
{
   [super setSortIndex:index];
   [selectedView setSortIndex:index];
}


- (void)viewUpdated:(UIControl *)sender;
{
   // view content has been updated
   // does NOT involve interface changes
}

- (void)viewHasNewContent:(UIControl *)sender;
{
   // view content has been changed
   // DOES involve interface changes
   [ViewUtilities setHeight:selectedView.frame.size.height + self.tabBar.height forView:self];
   [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (CommonSegmentView *)getSelectedView;
{
   if (self.tabBar.selectedTabIndex == 0)
      return _tagView;
   // if (self.tabBar.selectedTabIndex == 0)
   //    return TopTagsView;
   // if (self.tabBar.selectedTabIndex == 0)
   //    return TopTagsView;
   return nil;
}

@end
