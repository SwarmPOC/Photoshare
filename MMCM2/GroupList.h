//
//  GroupList.h
//  MMCM2
//
//  Created by Richard Montricul on 6/12/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupList : NSObject

@property (strong, nonatomic) NSMutableDictionary *groupDictionary;
@property (strong, nonatomic) NSMutableArray *groupIDByAlpha;
@property (strong, nonatomic) NSMutableArray *groupIDByDate;
@property (strong, nonatomic) NSMutableArray *groupIDByMemberCount;
@property (strong, nonatomic) NSMutableArray *groupIDBySinglesCount;

- (id)init; 
- (void)update;
- (void)updateWithCompletionBlock:(void (^)(void))block;
- (NSInteger)getSinglesCount;
@end
