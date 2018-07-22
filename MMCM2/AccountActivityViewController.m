//
//  AccountActivityViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 8/11/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "AccountActivityViewController.h"

@interface AccountActivityViewController ()

@end

@implementation AccountActivityViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   [self setupDefaults];
   [self setupVar];
   [self setupViews];
   [self updateViews];
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}

- (void)setupDefaults;
{
   self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setupVar;
{
}


- (void)setupViews;
{
   UIView *baseView = [[UIView alloc] init];
   baseView.frame = screenRect;

   
   // HeaderView
      // FriendsView

   // BodyView
      // FunctionsView

   // FooterView
}


- (void)updateViews;
{
}


@end
