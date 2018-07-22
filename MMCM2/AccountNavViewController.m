//
//  AccountNavViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 8/10/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "AccountNavViewController.h"
#import "AccountActivityViewController.h"
#import "AccountFriendsViewController.h"

// Common
   #import "Global.h"
   #import "ViewUtilities.h"

// local imports
   #import "AccountHomeViewController.h"

@interface AccountNavViewController ()

@end

@implementation AccountNavViewController


static NSInteger navHeaderHeight = 80;
static UIView *header;
static UIView *body;

static NSMutableArray *viewControllers;
static UIViewController *currentViewController;
static UISegmentedControl *segmentedControl;


- (BOOL)prefersStatusBarHidden {
    return true;
}


- (void)viewDidLoad {
   [super viewDidLoad];
   [Global sharedManager];
   self.view.backgroundColor = [UIColor blueColor];

   [self setupViews];
   [self setupBodyViewControllers];
   segmentedControl.selectedSegmentIndex = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)setupViews;
{
   [self setupHeader];
   [self setupBody];
}


- (void)setupHeader;
{
   header = [[UIView alloc] init];
   header.frame = CGRectMake(0,0, screenWidth, navHeaderHeight);
   header.backgroundColor = gray;
   [self.view addSubview:header];

   [self setupHeaderTitle];
   [self setupHeaderNav];

}


- (void)setupHeaderTitle;
{
   UIView *headerTitle = [[UIView alloc] init];
   headerTitle.frame = CGRectMake(0,0, screenWidth, 40);
   headerTitle.backgroundColor = header.backgroundColor;
   [header addSubview:headerTitle];

   UILabel *label = [[UILabel alloc] init];
   label.text = @"PROFILE";
   label.textAlignment = NSTextAlignmentCenter;
   label.numberOfLines = 1;
   label.font = [UIFont systemFontOfSize: 18 weight:UIFontWeightLight];
   [label sizeToFit];
   label.center = headerTitle.center;
   label.textColor = [UIColor blackColor];
   [headerTitle addSubview:label];
}


- (void)setupHeaderNav;
{
   UIView *headerNav = [[UIView alloc] init];
   headerNav.frame = CGRectMake(0,40, screenWidth, 40);
   headerNav.backgroundColor = header.backgroundColor;
   [header addSubview:headerNav];

   NSArray *segmentTitles = @[@"Home", @"Activity", @"Friends"];
   segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
   [segmentedControl addTarget:self action:@selector(selectSegment:) forControlEvents:UIControlEventValueChanged];
   segmentedControl.tintColor = [UIColor lightGrayColor];

   [ViewUtilities setWidth:0.9*screenWidth forView:segmentedControl];
   segmentedControl.center = headerNav.center;
   [header addSubview:segmentedControl];
}


- (void)setupBody;
{
   body = [[UIView alloc] init];
   body.frame = CGRectMake(0,navHeaderHeight,screenWidth, screenHeight - (navHeaderHeight + tabBarHeight) );
   [self.view addSubview:body];
}


- (void)selectSegment:(UISegmentedControl *)segment;
{
   UIViewController *vc = [viewControllers objectAtIndex:segment.selectedSegmentIndex];
   [self addChildViewController:vc];
   [currentViewController.view removeFromSuperview];
   [vc viewWillAppear:NO];
   [body addSubview:vc.view];

   [vc willMoveToParentViewController:self];
   [vc didMoveToParentViewController:self];
   [currentViewController removeFromParentViewController];
   currentViewController = vc;
   // if (segment.selectedSegmentIndex == 2) {
   // }
}


- (void)setupBodyViewControllers;
{
   viewControllers = [NSMutableArray array];

   AccountHomeViewController *vc1 = [[AccountHomeViewController alloc] init];
   [viewControllers addObject:vc1];
   AccountActivityViewController *vc2 = [[AccountActivityViewController alloc] init];
   [viewControllers addObject:vc2];
   AccountFriendsViewController *vc3 = [[AccountFriendsViewController alloc] init];
   [viewControllers addObject:vc3];

   for (UIViewController *vc in viewControllers) {
      vc.view.frame = body.bounds;
   }
}


@end
