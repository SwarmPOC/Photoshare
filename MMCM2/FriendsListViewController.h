//
//  FriendsListViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 11/3/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "NetworkDetailViewController.h"
#import "FriendList.h"

@interface FriendsListViewController : NetworkDetailViewController 
   <UICollectionViewDelegate,
    UICollectionViewDataSource>

@property (strong, nonatomic) FriendList *friendList;

- (id)init:(FriendList *)FriendList;
@end
