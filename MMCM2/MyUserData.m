//
//  MyUserData.m
//  MMCM2
//
//  Created by Richard Montricul on 6/16/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "MyUserData.h"

@implementation MyUserData

- (id)initWithDictionary:(NSDictionary *)dic;
{
   self = [super initWithDictionary:dic];
   _inviteCode  = [dic objectForKey:@"inviteCode"];
   // myGroupData  = [[GroupData alloc] init];
   // myFriendList = [[FriendList alloc] initWithUserID:self.userID];
   return self;
}


@end
