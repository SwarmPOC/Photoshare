//
//  CommonTabView.m
//  MMCM2
//
//  Created by Richard Montricul on 6/9/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "CommonTabView.h"

@implementation CommonTabView


- (id)init:(User *)UserData delegate:(id)Delegate; 
{
   self = [super init];
   self.frame = CGRectMake(0,0,screenWidth, 0);
   _userData = UserData;
   _delegate = Delegate;
   [self setupVars];
   [self setupViews];
   self.backgroundColor = [UIColor yellowColor];
   return self;
}
- (void)setupVars;
{
}
- (void)setupViews;
{
}
// - (NSInteger)getSortIndex;
// {
//    return _sortIndex;
// }
// - (void)setSortIndex:(NSInteger)index;
// {
//    _sortIndex = index;
// }
@end
