//
//  CommonTabView.h
//  MMCM2
//
//  Created by Richard Montricul on 6/9/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "Global.h"
#import "ViewUtilities.h"
#import "User.h"

@interface CommonTabView : UIControl

@property (strong,nonatomic) UIViewController *delegate;
@property (strong, nonatomic) User *userData;
@property NSInteger sortIndex;

- (id)init:(User *)UserData delegate:(id)Delegate; 
- (void)setupVars;
- (void)setupViews;

@end
