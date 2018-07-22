//
//  TopTagsView.m
//  MMCM2
//
//  Created by Richard Montricul on 6/6/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "TopTagsView.h"
#import "ProfilePhotoStreamView.h"

@implementation TopTagsView 
{
   NSDictionary *userData;
   NSMutableDictionary *tagCountDictionary;
   NSMutableDictionary *tagStreamDictionary;
   NSMutableDictionary *tagDateDictionary;
   NSMutableArray *sortArrays;
   NSMutableArray *tagArrayByAlpha;
   NSMutableArray *tagArrayByCount;
   NSMutableArray *tagArrayByDate;
}


- (id)init:(User *)UserData delegate:(id)Delegate; 
{
   self = [super init:UserData delegate:Delegate];
   return self;
}

#pragma setup
- (void)setupVars;
{
   [super setupVars];
   self.sortIndex = 0;
   _sortValues = @[@"sort: most used",@"sort: alphabetical", @"sort: recent"];
   tagDateDictionary   = [[NSMutableDictionary alloc] init];
   tagCountDictionary  = [[NSMutableDictionary alloc] init];
   tagStreamDictionary = [[NSMutableDictionary alloc] init];
   tagArrayByCount = [[NSMutableArray alloc] init];
   tagArrayByAlpha = [[NSMutableArray alloc] init];
   tagArrayByDate  = [[NSMutableArray alloc] init];
   sortArrays = [[NSMutableArray alloc] init];
   [sortArrays addObject:tagArrayByCount];
   [sortArrays addObject:tagArrayByAlpha];
   [sortArrays addObject:tagArrayByDate];
}

- (void)setupViews;
{
   [super setupViews];
   [self refreshPhotoStreams];
}


- (void)refreshPhotoStreams;
{
   //------------------
      // refresh data
   //------------------
   [server retrieveTagsForUserID:self.userData.userID completionBlock:^(id result){
      for (NSDictionary *dic in result) {
         NSString *tag = [[dic objectForKey:@"tagID"] objectForKey:@"S"];
         NSNumber *count = [NSNumber numberWithLong:[[[dic objectForKey:@"mediaArray"] objectForKey:@"SS"] count]];
         NSNumber *oldCount = [tagCountDictionary objectForKey:tag];
         if (oldCount) { // this photostream already exists
            if ([count intValue] != [oldCount intValue]) { // but it looks the number of pictures for thie stream has changed
               [tagCountDictionary setValue:count forKey:tag];
               [[tagStreamDictionary objectForKey:tag] reload];
            }
         }
         else { // this photostream needs to be created
            [tagCountDictionary setValue:count forKey:tag];
            [self createStream:dic];
         }
         NSNumber *date = [NSNumber numberWithFloat:[[[dic objectForKey:@"lastModifiedDate"] objectForKey:@"N"] floatValue]];
         [tagDateDictionary setValue:date forKey:tag];
      }
      [self updateTagArrays];

      //---------------------
         // refresh View
      //---------------------
      [ViewUtilities setHeight:[tagArrayByCount count] * 130 forView:self];
      [self sendActionsForControlEvents:UIControlEventValueChanged];
   }];
}


- (void)updateTagArrays;
{
   tagArrayByDate = (NSMutableArray *)[[tagDateDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
   {
      NSNumber *first = [tagDateDictionary objectForKey:a];
      NSNumber *second = [tagDateDictionary objectForKey:b];
      return [first compare:second];
   }];
   tagArrayByCount = (NSMutableArray *)[[tagCountDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
   {
      NSNumber *first = [tagCountDictionary objectForKey:a];
      NSNumber *second = [tagCountDictionary objectForKey:b];
      return [first compare:second];
   }];
   tagArrayByAlpha = (NSMutableArray *)[tagArrayByCount sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
}


- (void)createStream:(NSDictionary *)dic;
{
   NSString *tag = [[dic objectForKey:@"tagID"] objectForKey:@"S"];
   ProfilePhotoStreamView *photoStream = [[ProfilePhotoStreamView alloc]
      init: tag
      photoArray:[[dic objectForKey:@"mediaArray"] objectForKey:@"SS"]
      delegate:self.delegate];
   [photoStream addTarget:self action:@selector(streamUpdated:) forControlEvents:(UIControlEvents)customControlEventContentsUpdated];
}

- (void)streamUpdated:(ProfilePhotoStreamView *)sender;
{
   [tagStreamDictionary setObject:sender forKey:sender.streamTag];
   dispatch_async(dispatch_get_main_queue(), ^{
      [self deployStreams];
   });
   [self sendActionsForControlEvents:(UIControlEvents)customControlEventContentsUpdated];
}

- (void)deployStreams;
{
   [self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)]; // remove all subVuews
   int y = 0;
   for (NSString *tag in [self getSortArray]) {
      ProfilePhotoStreamView *stream = [tagStreamDictionary objectForKey:tag];
      [ViewUtilities setY:y forView:stream];
      [self addSubview:stream];
      y = y+130;
   }
}

- (NSArray *)getSortArray;
{
   if (self.sortIndex == 0)
      return tagArrayByCount;
   if (self.sortIndex == 1)
      return tagArrayByAlpha;
   if (self.sortIndex == 2)
      return tagArrayByDate;
   return nil;
}

- (void)setSortIndex:(NSInteger)index;
{
   [super setSortIndex:index];
   [self deployStreams];
}
@end
