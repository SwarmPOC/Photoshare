//
//  GroupDetailViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 5/10/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "NetworkDetailViewController.h"
#import "Group.h"

@interface GroupDetailViewController : NetworkDetailViewController
   <UICollectionViewDelegate,
    UICollectionViewDataSource>

@property (strong, nonatomic) Group *group;

- (id)init:(Group *)Group;
@end
