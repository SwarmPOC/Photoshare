//
//  ProfileViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 12/14/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "CommonViewController.h"
// #import "SegmentedControlWithSearch.h"
#import "User.h"

@interface ProfileViewController : CommonViewController <UITextFieldDelegate,
                                                         UIScrollViewDelegate,
                                                         UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) User *user;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *nameLabel;
// @property (strong, nonatomic) SegmentedControlWithSearch *segmentedControl;


- (id)init:(User *)UserData; 
- (void)newPhotoAdded;

@end
