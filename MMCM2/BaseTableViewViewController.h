//
//  BaseTableViewViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 12/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseTableViewViewController : BaseViewController
   <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UITableView *tableView;

- (void)setupLabel;
- (void)setTableHeight;
@end
