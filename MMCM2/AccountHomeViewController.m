//
//  AccountHomeViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 8/11/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "AccountHomeViewController.h"

@interface AccountHomeViewController ()

@end

@implementation AccountHomeViewController
static UILabel *label;

- (void)viewDidLoad {
   [super viewDidLoad];

   label = [[UILabel alloc] init];
   label.text = @"PROFILE_TEST";
   label.textAlignment = NSTextAlignmentCenter;
   label.numberOfLines = 1;
   label.font = [UIFont systemFontOfSize: 18 weight:UIFontWeightLight];
   [label sizeToFit];
   label.textColor = [UIColor blackColor];
   [self.view addSubview:label];
   self.view.backgroundColor = [UIColor greenColor];
}

- (void)viewWillAppear:(BOOL)animated;
{
   [self updateViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateViews;
{
   label.center = self.view.center;
   label.text = @"changed";
}

@end
