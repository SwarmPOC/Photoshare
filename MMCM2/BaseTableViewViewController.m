//
//  BaseTableViewViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "BaseTableViewViewController.h"

@interface BaseTableViewViewController ()

@end

@implementation BaseTableViewViewController

- (void)setupViews;
{
   [super setupViews];
   [self setupLabel];
   [self setupTableView];
}

- (void)setupLabel;
{
   _label = [[UILabel alloc] init];
   _label.frame = CGRectMake(0,0,300,18);
   _label.text = [self labelText];
   _label.textAlignment = NSTextAlignmentLeft;
   _label.textColor = [UIColor blackColor];
   _label.numberOfLines = 1;
   _label.font = [UIFont systemFontOfSize: 15 weight:UIFontWeightRegular];
   _label.center = self.view.center;
   [ViewUtilities setY:123 forView:_label];
   [self.view addSubview:_label];
}

- (NSString *)labelText;
{
   return @"";
}

- (void)setupTableView;
{
   CGRect frame = CGRectMake(0, CGRectGetMaxY(_label.frame) + 29, screenWidth, 58 * [self getRowCount]);
   _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
   _tableView.dataSource = self;
   _tableView.delegate = self;
   _tableView.scrollEnabled = NO;
   [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
   [_tableView setBackgroundColor:[UIColor clearColor]];

   _tableView.layer.borderWidth = 1.0;
   _tableView.layer.borderColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha: 1.0].CGColor;
   [_tableView setTintColor:themeColor];

   [self setMask];
   [self.view addSubview:_tableView];
}

- (void)setMask;
{
   int borderWidth = 1;
   UIView* mask = [[UIView alloc] initWithFrame:CGRectMake(
         borderWidth, 0, _tableView.frame.size.width, _tableView.frame.size.height)];
   mask.backgroundColor = [UIColor blackColor];
   _tableView.layer.mask = mask.layer;
}

- (void)setTableHeight;
{
   int height = 58 * [self getRowCount];
   int maxTableHeight = [self getMaxTableHeight];
   if (height > maxTableHeight) {
      height = maxTableHeight;
      self.tableView.scrollEnabled = YES;
   }
   [ViewUtilities setHeight:height forView:self.tableView];
   [self setMask];
}

- (int)getMaxTableHeight;
{
   return self.button.frame.origin.y - _tableView.frame.origin.y;
}

- (int)getRowCount{
   return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
   static NSString *CellIdentifier = @"Cell";
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil){
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      [self customizeNewCell:cell forIndexPath:indexPath];
   }
   [self customizeCell:cell forIndexPath:indexPath];
   return cell;
}

- (void)customizeNewCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {}
- (void)customizeCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {}


-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath 
{
   return 58;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self getRowCount];
}

@end
