//
//  MyUserData.h
//  MMCM2
//
//  Created by Richard Montricul on 6/16/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "User.h"

@interface MyUserData : User
@property BOOL isMyProfile;
@property (strong, nonatomic) NSString *inviteCode;

@end
