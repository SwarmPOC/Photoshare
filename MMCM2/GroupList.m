//
//  GroupList.m
//  MMCM2
//
//  Created by Richard Montricul on 6/12/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "GroupList.h"
#import "ServerInterface.h"
#import "Group.h"

@implementation GroupList {
   ServerInterface *server;
}

- (id)init; 
{
   self = [super init];
   [self setupVars];
   return self;
}

- (void)setupVars;
{
   _groupDictionary = [[NSMutableDictionary alloc] init];
   _groupIDByAlpha = [[NSMutableArray alloc] init];
   _groupIDByDate = [[NSMutableArray alloc] init];
   _groupIDByMemberCount = [[NSMutableArray alloc] init];
   _groupIDBySinglesCount = [[NSMutableArray alloc] init];
   server = [ServerInterface sharedManager];
   //serverObject = [ServerInterface sharedManager];
}


- (void)update;
{
   [self updateWithCompletionBlock:nil];
}
- (void)updateWithCompletionBlock:(void (^)(void))block;
{


   ///////////////////////////////////////////
   //TODO:work on the "update" portion of this
   ///////////////////////////////////////////


   [server retrieveGroupData:^void (NSArray *result){
      for (NSDictionary *dic in result) {
         Group *group = [[Group alloc] initWithDictionary:dic];
         [_groupDictionary setValue:group forKey:group.groupID];
      }
      [self updateSortArrays];
      if (block)
         block();
   }];
}

- (void)updateSortArrays
{
   _groupIDByDate = (NSMutableArray *)[[_groupDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
   {
      NSNumber *first  = [NSNumber numberWithFloat:[((Group *)[_groupDictionary objectForKey:a]).creationDate floatValue]];
      NSNumber *second = [NSNumber numberWithFloat:[((Group *)[_groupDictionary objectForKey:b]).creationDate floatValue]];
      return [second compare:first];
   }];
   _groupIDByMemberCount = (NSMutableArray *)[[_groupDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
   {
      NSNumber *first  = [NSNumber numberWithInt:[((Group *)[_groupDictionary objectForKey:a]).memberCount intValue]];
      NSNumber *second = [NSNumber numberWithInt:[((Group *)[_groupDictionary objectForKey:b]).memberCount intValue]];
      return [second compare:first];
   }];
   _groupIDBySinglesCount = (NSMutableArray *)[[_groupDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
   {
      NSNumber *first  = [NSNumber numberWithInt:[((Group *)[_groupDictionary objectForKey:a]).singlesCount intValue]];
      NSNumber *second = [NSNumber numberWithInt:[((Group *)[_groupDictionary objectForKey:b]).singlesCount intValue]];
      return [second compare:first];
   }];
   _groupIDByAlpha = (NSMutableArray *)[_groupIDByDate sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];

   // NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
   // NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
   // _groupIDByAlpha = [myGroupsArray sortedArrayUsingDescriptors:sortDescriptors];
}


// - (NSInteger)getCount;
// {
//    return [_groupDictionary count];
// }
- (NSInteger)getSinglesCount;
{
   NSInteger singlesCount = 0;
   for (NSString *groupID in _groupIDBySinglesCount) {
      Group *group = [_groupDictionary objectForKey:groupID];
      singlesCount = singlesCount + [group.singlesCount intValue];
   }
   return singlesCount;
}
@end
