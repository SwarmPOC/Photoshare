//
//  FriendList.m
//  MMCM2
//
//  Created by Richard Montricul on 11/14/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "FriendList.h"
#import "Global.h"
#import "User.h"


@implementation FriendList {
   NSString *s_userID;

   NSMutableArray *arrSinglesSecondDegree;
   NSMutableArray *arrComplicatedSecondDegree;
}


- (id)init; 
{
   self = [super init];
   [self setupVars];
   return self;
}

- (id)initWithUserID:(NSString *)UserID; 
{
   self = [self init];
   s_userID = UserID;
   return self;
}


- (void)setupVars;
{
   _dicAllFirstDegree                   = [[NSMutableDictionary alloc] init]; 
   _arrSinglesAndComplicatedFirstDegree = [[NSMutableArray alloc] init]; 
   _arrSinglesFirstDegree               = [[NSMutableArray alloc] init]; 
   _arrComplicatedFirstDegree           = [[NSMutableArray alloc] init]; 
   _arrTakenFirstDegree                 = [[NSMutableArray alloc] init]; 

   _dicAllSecondDegree                   = [[NSMutableDictionary alloc] init]; 
   _arrSinglesAndComplicatedSecondDegree = [[NSMutableArray alloc] init]; 
   _arrSinglesSecondDegree               = [[NSMutableArray alloc] init]; 
   _arrComplicatedSecondDegree           = [[NSMutableArray alloc] init]; 
   _arrTakenSecondDegree                 = [[NSMutableArray alloc] init]; 

   //Sort Arrays
   _arrFirstDegreeByAlpha = [[NSMutableArray alloc] init]; 
   _arrFirstDegreeByDate = [[NSMutableArray alloc] init];
}


- (void)update;
{
   [self updateWithCompletionBlock:nil];
}
- (void)updateWithUserID:(NSString *)UserID;
{
   s_userID = UserID;
   [self updateWithCompletionBlock:nil];
}
- (void)updateWithUserID:(NSString *)UserID withCompletionBlock:(void (^)(void))block;
{
   s_userID = UserID;
   [self updateWithCompletionBlock:block];
}
- (void)updateWithCompletionBlock:(void (^)(void))block;
{
   if (!s_userID)
      return;


   ///////////////////////////////////////////
   //TODO:work on the "update" portion of this
   ///////////////////////////////////////////


   [self wipeArrays];
   [server retrieveFriendsForUser:s_userID withCompletionBlock:^void (NSArray *result) {
      for (NSDictionary *dic in result) {
         User *user = [[User alloc] initWithDictionary:dic];
         NSString *userID = user.userID;
         [_dicAllFirstDegree setValue:user forKey:userID];
         if ([self isMatched:user]) {
            if ([user.relationshipStatus isEqual:@"1"]) {
               [_arrSinglesFirstDegree addObject:userID];
            }
            if ([user.relationshipStatus isEqual:@"4"]) {
               [_arrComplicatedFirstDegree addObject:userID];
            }
            [_arrSinglesAndComplicatedFirstDegree addObject:userID];
         }
      }
      [self updateSortArrays];
      if (block)
         block();
   }];
}

- (void)updateSortArrays;
{
   _arrFirstDegreeByDate = (NSMutableArray *)[[_dicAllFirstDegree allKeys]
      sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
   {
      NSString *first  = ((User *)[_dicAllFirstDegree objectForKey:a]).creationDate;
      NSString *second = ((User *)[_dicAllFirstDegree objectForKey:b]).creationDate;
      return [second compare:first];
   }];
   _arrFirstDegreeByAlpha = (NSMutableArray *)[[_dicAllFirstDegree allKeys]
      sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
   {
      NSString *first  = ((User *)[_dicAllFirstDegree objectForKey:a]).firstName;
      NSString *second = ((User *)[_dicAllFirstDegree objectForKey:b]).firstName;
      return [first compare:second];
   }];
}

- (BOOL)isMatched:(User *)user;
{
   if ([user.relationshipStatus isEqual:@"2"]) {
      [_arrTakenFirstDegree addObject:user.userID];
      return NO;
   }

   BOOL isMatch = YES;
   NSString *myGender = myUserData.gender;
   NSString *myPreference = myUserData.lookingFor;
   NSString *theirGender = user.gender;
   NSString *theirPreference = user.lookingFor;

   if ([myPreference isEqual:@"3"]) {
      if ([theirPreference isEqual:[self getOppositeGender:myGender]]) {
         isMatch = NO;      
      }
   }
   else  {
      if ([theirGender isEqual:[self getOppositeGender:myPreference]]) {
         isMatch = NO;      
      }
      else if ([theirPreference isEqual:[self getOppositeGender:myGender]]) {
         isMatch = NO;      
      }
   }
   return isMatch;
}

- (NSString *)getOppositeGender:(NSString *)gender;
{
   if ([gender isEqual:@"1"])
      return @"2";
   else return @"1";
}


- (void)wipeArrays;
{
   [_arrSinglesFirstDegree removeAllObjects];
   [_arrComplicatedFirstDegree removeAllObjects];
   [_arrSinglesAndComplicatedFirstDegree removeAllObjects];
}



- (NSInteger)getUserCount:(NSInteger)selectedSegmentIndex;
{
   // get MERGE option
   //    include second degree
   //    include complicated
   // if (selectedSegmentIndex == ALL_FRIENDS) {
   //    //return [arrAllFriends count];
   // }
   // else if (selectedSegmentIndex == SINGLES) {
   //    int total = [_arrSinglesFirstDegree count];
      // if (gOption_showComplicated == YES) {
      //    total += [_arrComplicatedFirstDegree count];
      // }
      // if (gOption_myStatus == SINGLE) {
      //    total += [arrSinglesSecondDegree count];
      //    if (gOption_showComplicated == YES) {
      //       total += [arrComplicatedSecondDegree count];
      //    }
      // }
   //    return total;
   // }
   return 0;
}

- (NSArray *)getSortedFilterWithFilter:(NSArray *)filter sort:(NSArray *)sort;
{
   NSMutableArray *sortedFilter = [[NSMutableArray alloc] init];
   for (NSString *userID in sort) {
      if ([filter containsObject:userID]) {
         [sortedFilter addObject:userID];
      }
   }
   return sortedFilter;
}

@end
