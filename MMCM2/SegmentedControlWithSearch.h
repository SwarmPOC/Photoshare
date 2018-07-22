//
//  SegmentedControlWithSearch.h
//  MMCM2
//
//  Created by Richard Montricul on 12/14/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "Global.h"
#import "SortButton.h"

@interface SegmentedControlWithSearch : UIControl
//@property (strong, nonatomic)  *imageView;

@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UIButton *searchButton;
@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) SortButton *sortButton;
@property NSInteger selectedSegmentIndex;
@property NSInteger sortIndex;
@property bool isExpanded;

- (id)init:(id)Delegate;
- (void)setSegmentTitles:(NSArray *)titles;
- (void)setSortValues:(NSArray *)SortValues;
@end
