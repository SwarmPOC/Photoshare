//
//  CommonSegmentView.m
//  MMCM2
//
//  Created by Richard Montricul on 6/9/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "CommonSegmentView.h"

@implementation CommonSegmentView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}

- (id)init:(User *)UserData delegate:(UIViewController *)Delegate; 
{
   self = [super init];
   self.frame = CGRectMake(0,0,screenWidth,0);
   self.backgroundColor = [UIColor orangeColor];
   _userData = UserData;
   _delegate = Delegate;
   [self setupVars];
   [self setupViews];
   return self;
}
- (void)setupVars;
{
}
- (void)setupViews;
{
}

- (void)setSortIndex:(NSInteger)index;
{
}

@end
