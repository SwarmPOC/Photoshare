//
//  BasicChoiceViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "BasicChoiceViewController.h"

@interface BasicChoiceViewController ()

@end

@implementation BasicChoiceViewController

- (void)viewDidAppear:(BOOL)animated 
{
   [self selectDefaultOption];
}

- (void)customizeCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
{
   cell.textLabel.text = [self getCellTextForIndexPath:indexPath];
   cell.layoutMargins = UIEdgeInsetsMake(0,self.label.frame.origin.x, 0, 0);
   cell.textLabel.font = [UIFont systemFontOfSize: 15 weight:UIFontWeightRegular];
   if([_checkedIndexPath isEqual:indexPath]) {
       cell.accessoryType = UITableViewCellAccessoryCheckmark;
   }
   else {
       cell.accessoryType = UITableViewCellAccessoryNone;
   }
}

- (NSString *)getCellTextForIndexPath:(NSIndexPath *)indexPath;
{
   return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // Uncheck the previous checked row
    if(self.checkedIndexPath)
    {
        UITableViewCell* uncheckCell = [tableView
                     cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;

        uncheckCell.textLabel.font = [UIFont systemFontOfSize: 15 weight:UIFontWeightRegular];
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.font = [UIFont systemFontOfSize: 15 weight:UIFontWeightBold];
    self.checkedIndexPath = indexPath;
}


- (void)selectDefaultOption;
{
   [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:[self defaultOption] inSection:0]];
}

- (int)defaultOption;
{
   return 0;
}

- (void)next{}


@end
