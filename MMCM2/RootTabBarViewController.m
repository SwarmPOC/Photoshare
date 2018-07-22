//
//  RootTabBarViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 8/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "RootTabBarViewController.h"

// Common
   #import "Global.h"

// Connected View Controllers
   #import "AccountNavViewController.h"
   #import "ChatNavViewController.h"
   #import "HomeNavViewController.h"
   #import "ProfileNavViewController.h"
   #import "ProfileViewController.h"

@interface RootTabBarViewController ()

@end

@implementation RootTabBarViewController

static NSString *feedTitle = @"Activity";
static NSString *chatTitle = @"Messages";
static NSString *accountTitle = @"Account";

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)viewDidLoad {
   [super viewDidLoad];
   [Global sharedManager];
   tabBarHeight = self.tabBar.frame.size.height;
   [self setupViewControllers];
   [self setupTabBar];
   [self setupTabBarItems];
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}


- (void)setupTabBarItems;
{

   UITabBarItem *item1 = [self.tabBar.items objectAtIndex:0];
   //item1.title = feedTitle;
   item1.image = [UIImage imageNamed:@"FeedIconOff"];
   item1.selectedImage = [UIImage imageNamed:@"FeedIconOn"];

   UITabBarItem *item2 = [self.tabBar.items objectAtIndex:1];

   for (UITabBarItem *item in self.tabBar.items) {
       item.selectedImage = [item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
       item.image =         [item.image         imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
   }
}


- (void)setupTabBar;
{
   //self.tabBar.barTintColor = [UIColor blackColor];
   self.tabBar.translucent = YES;
}


- (void)setupViewControllers;
{
   NSMutableArray *viewControllers = [NSMutableArray array];

   HomeNavViewController *viewController1 = [[HomeNavViewController alloc] init];
   viewController1.navigationBar.hidden = YES;
   viewController1.title = feedTitle;
   [viewControllers addObject:viewController1];

   ChatNavViewController *viewController2 = [[ChatNavViewController alloc] init];
   viewController2.navigationBar.hidden = YES;
   viewController2.title = chatTitle;
   [viewControllers addObject:viewController2];

   UIViewController *viewController = [[ProfileViewController alloc] init:myUserData];
   ProfileNavViewController *viewController3 = [[ProfileNavViewController alloc] initWithRootViewController:viewController];
   viewController3.navigationBar.hidden = YES;
   viewController3.title = accountTitle;
   [viewControllers addObject:viewController3];

   self.viewControllers = viewControllers;
   // Center button, performs an action instead of leading to a controller
      // UIViewController *blankController = [UIViewController new]; 
      // [viewControllers addObject:blankController];
}


@end
