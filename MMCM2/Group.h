//
//  Group.h
//  MMCM2
//
//  Created by Richard Montricul on 6/20/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

@property (strong, nonatomic) NSString *groupID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *memberCount;
@property (strong, nonatomic) NSString *singlesCount;
@property (strong, nonatomic) NSString *creationDate;

@property (strong, nonatomic) NSMutableDictionary *userDictionary;
@property (strong, nonatomic) NSMutableArray *userArrayByName;
@property (strong, nonatomic) NSMutableArray *userArrayByDate;

@property BOOL allThumbnailsLoaded;
@property BOOL allUsersPulled;


- (id)initWithDictionary:(NSDictionary *)dic;
- (void)refreshAllUsersWithCompletionBlock:(void (^)(void))block;
- (void)pullUsersWithCompletionBlock:(void (^)(void))block;

@end
