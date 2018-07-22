//
//  BasicChoiceViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 12/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "BaseTableViewViewController.h"

@interface BasicChoiceViewController : BaseTableViewViewController
   <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSIndexPath* checkedIndexPath;

@end
