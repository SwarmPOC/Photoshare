//
//  FriendList.h
//  MMCM2
//
//  Created by Richard Montricul on 11/14/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendList : NSObject
@property (strong, nonatomic) NSMutableDictionary *dicAllFirstDegree;
@property (strong, nonatomic) NSMutableArray *arrFirstDegreeByAlpha;
@property (strong, nonatomic) NSMutableArray *arrFirstDegreeByDate;
@property (strong, nonatomic) NSMutableArray *arrSinglesAndComplicatedFirstDegree;
@property (strong, nonatomic) NSMutableArray *arrSinglesFirstDegree;
@property (strong, nonatomic) NSMutableArray *arrComplicatedFirstDegree;
@property (strong, nonatomic) NSMutableArray *arrTakenFirstDegree;

@property (strong, nonatomic) NSMutableDictionary *dicAllSecondDegree;
@property (strong, nonatomic) NSMutableArray *arrSecondDegreeByAlpha;
@property (strong, nonatomic) NSMutableArray *arrSecondDegreeByDate;
@property (strong, nonatomic) NSMutableArray *arrSinglesAndComplicatedSecondDegree;
@property (strong, nonatomic) NSMutableArray *arrSinglesSecondDegree;
@property (strong, nonatomic) NSMutableArray *arrComplicatedSecondDegree;
@property (strong, nonatomic) NSMutableArray *arrTakenSecondDegree;

- (id)init; 
- (id)initWithUserID:(NSString *)UserID; 
- (void)update;
- (void)updateWithUserID:(NSString *)UserID;
- (void)updateWithCompletionBlock:(void (^)(void))block;
- (void)updateWithUserID:(NSString *)UserID withCompletionBlock:(void (^)(void))block;
- (NSArray *)getSortedFilterWithFilter:(NSArray *)filter sort:(NSArray *)sort;
@end
