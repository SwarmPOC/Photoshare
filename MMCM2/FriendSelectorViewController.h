//
//  FriendSelectorViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 2/7/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "BaseTableViewViewController.h"

@interface FriendSelectorViewController : BaseTableViewViewController <UITableViewDataSource, UITableViewDelegate>

- (id)init:(UIViewController *)viewController array:(NSArray *)array;
@end
