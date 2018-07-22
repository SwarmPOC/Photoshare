//
//  BaseViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 8/8/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
// int headerHeight = 80;
int buttonHeight = 49;

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (void)viewDidLoad {
   [super viewDidLoad];
}

- (void)setupViews;
{
   [super setupViews];
   if ([self showNextButton]) {
      [self setupNextButton];
   }
}

- (BOOL)showHeader;
{
   return true;
}
- (BOOL)showNextButton;
{
   return true;
}


- (NSString *)headerText;
{
   return @"Preferences";
}

- (void)setupNextButton;
{
   _button = [UIButton buttonWithType:UIButtonTypeCustom];
   _button.frame = CGRectMake(0,screenHeight-buttonHeight,screenWidth,buttonHeight);
   _button.backgroundColor = themeColorLight;
   _button.titleLabel.font = [UIFont systemFontOfSize: 15 weight:UIFontWeightMedium];
   _button.titleLabel.textAlignment = NSTextAlignmentCenter;
   _button.titleLabel.numberOfLines = 1;
   [_button setTitle:[self nextButtonText] forState:UIControlStateNormal];
   [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   [_button addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:_button];
}

- (NSString *)nextButtonText;
{
   return @"next";
}

- (void)next;
{
}


@end
