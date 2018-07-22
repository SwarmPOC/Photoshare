//
//  User.m
//  MMCM2
//
//  Created by Richard Montricul on 8/23/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "User.h"
#import "FriendList.h"

@implementation User

- (id)initWithDictionary:(NSDictionary *)dic;
{
   self = [super init];

  _userID             = [dic objectForKey:@"userID"];
  _fullName           = [dic objectForKey:@"fullName"];
  _firstName          = [dic objectForKey:@"firstName"];
  _lastName           = [dic objectForKey:@"lastName"];
  _gender             = [dic objectForKey:@"gender"];
  _relationshipStatus = [dic objectForKey:@"relationshipStatus"];

  _imageS3Key         = [dic objectForKey:@"imageS3Key"];
  _lookingFor         = [dic objectForKey:@"lookingFor"];
  _creationDate       = [dic objectForKey:@"creationDate"];
  return self;
}



// + (NSString *)dynamoDBTableName {
//     return @"MMCM_User";
// }
// 
// + (NSString *)hashKeyAttribute {
//     return @"userID";
// }

@end
