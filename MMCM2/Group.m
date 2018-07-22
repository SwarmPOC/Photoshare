//
//  Group.m
//  MMCM2
//
//  Created by Richard Montricul on 6/20/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "Group.h"
#import "ServerInterface.h"
#import "User.h"

@implementation Group {
   NSInteger upperIndex;
   NSDictionary *groupDetailLastEvaluatedKey;
   ServerInterface *server;
}

- (id)initWithDictionary:(NSDictionary *)dic;
{
   self = [super init];
   _groupID      = [dic objectForKey:@"groupID"];
   _name         = [dic objectForKey:@"name"];
   _memberCount  = [dic objectForKey:@"memberCount"];
   _singlesCount = [dic objectForKey:@"singlesCount"];
   _creationDate = [dic objectForKey:@"creationDate"];
   [self setupVars];
   return self;
}

- (void)setupVars;
{
   upperIndex = 0;
   _allUsersPulled = false;
   _userDictionary = [[NSMutableDictionary alloc] init];
   _userArrayByName = [[NSMutableArray alloc] init];
   _userArrayByDate = [[NSMutableArray alloc] init];
   server = [ServerInterface sharedManager];
}

- (void)refreshAllUsersWithCompletionBlock:(void (^)(void))block;
{
   upperIndex = 0;
   [self pullUsersWithCompletionBlock:block];
}

- (void)pullUsersWithCompletionBlock:(void (^)(void))block;
{
   NSString *startKey = (upperIndex == 0) ? @"0" : groupDetailLastEvaluatedKey;
   [server retrieveGroupUsers:_groupID
           startKey:(upperIndex == 0) ? @"0" : groupDetailLastEvaluatedKey
           limit:50
           withCompletionBlock:^void (id result){
      int index = 0;
      for (NSDictionary *dic in [result objectForKey:@"userList"]) {
         User *user = [[User alloc] initWithDictionary:dic];
         if (![_userDictionary objectForKey:user.userID]) {
            [_userDictionary setObject:user forKey:user.userID];
            [server downloadThumbnail:user.imageS3Key withCompletionBlock:^(UIImage *image){
               user.image = image;
               if (index == [[result objectForKey:@"userList"] count] - 1)
                  block();
            }];
         }
         index++;
      }
      [self updateSortArrays];
      upperIndex = [_userDictionary count] - 1;
      if ([result objectForKey:@"LastEvaluatedKey"]) {
         groupDetailLastEvaluatedKey = [result objectForKey:@"LastEvaluatedKey"];
      }
      else {
      //if ([[result objectForKey:@"userList"] count] == 0){
         _allUsersPulled = YES;
      }
      block();
   }];
}

- (void)updateSortArrays;
{
   _userArrayByDate = (NSMutableArray *)[[_userDictionary allKeys]
      sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
   {
      NSString *first  = ((User *)[_userDictionary objectForKey:a]).creationDate;
      NSString *second = ((User *)[_userDictionary objectForKey:b]).creationDate;
      return [second compare:first];
   }];
   _userArrayByName = (NSMutableArray *)[[_userDictionary allKeys]
      sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
   {
      NSString *first  = ((User *)[_userDictionary objectForKey:a]).firstName;
      NSString *second = ((User *)[_userDictionary objectForKey:b]).firstName;
      return [first compare:second];
   }];
}


@end
