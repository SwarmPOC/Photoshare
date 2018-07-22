//
//  CommonSegmentView.h
//  MMCM2
//
//  Created by Richard Montricul on 6/9/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "Global.h"
#import "CustomTabBar.h"
#import "User.h"

@interface CommonSegmentView : UIControl

@property (strong,nonatomic) CustomTabBar *tabBar;
@property (strong,nonatomic) UIViewController *delegate;
@property (strong, nonatomic) User *userData;

- (id)init:(User *)UserData delegate:(UIViewController *)Delegate; 
- (void)setupVars;
- (void)setupViews;
- (void)setSortIndex:(NSInteger)index;
@end
