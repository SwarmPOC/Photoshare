//
//  ServerInterface.h
//  MMCM2
//
//  Created by Richard Montricul on 8/29/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ServerInterface : NSObject

+ (id)sharedManager;
- (void)AWSTest:(NSString *)string withCompletionBlock:(void (^)(id result))block;
- (BOOL)hasFBCredentials; 
- (BOOL)preCheck;
- (void)checkInternet;
- (void)invoke:(NSString *)action withCompletionBlock:(void (^)(id result))block;

- (void)initAWSCognito:(void (^)(NSNumber *userHasRegisteredWithAWS))block;
- (void)loginWithNewUserFlag:(BOOL)isNewUser completionBlock:(void (^)(id result))block;
- (void)logout;

- (void)retrieveFBProfileData:(void (^)(NSDictionary *result))block;
- (void)saveFBProfileDataToAWS:(NSDictionary *)FBProfileData completionBlock:(void (^)(id result))block;
- (void)retrieveFBFriendData:(void (^)(NSArray *result))block;
- (void)saveFBFriendDataToAWS:(NSArray *)FBFriendData isNewUser:(BOOL)isNewUser
        withCompletionBlock:(void (^)(NSNumber *friendCount))block;
- (void)retrieveFriendsForUser:(NSString *)userID withCompletionBlock:(void (^)(NSArray *result))block;

- (void)verifyInviteCode:(NSString *)code withCompletionBlock:(void (^)(id result))block;
- (void)updateName:(NSDictionary *)vals;
- (void)updateGender:(NSString *)gender;
- (void)updateRelationshipStatus:(NSString *)relationshipStatus isInitialStatus:(BOOL)isInitialStatus;
- (void)updateLookingFor:(NSString *)lookingFor;


- (void)retrieveGroupData:(void (^)(id result))block;
- (void)addProfilePicture:(NSData *)data userArray:(NSArray *)userArray tagArray:(NSArray *)tagArray caption:(NSString *)caption;
- (void)removeMediaReferences:(NSString *)mediaID;
- (void)retrieveTagsForUserID:(NSString *)userID completionBlock:(void (^)(id result))block;
//- (void)retrieveMediaForTag:(NSString *)tag completionBlock:(void (^)(NSArray *result))block;
- (void)retrieveMediaForTag:(NSString *)tag completionBlock:(void (^)(id result))block;
// - (void)uploadImageAsDataToS3:(NSData *)data key:(NSString *)key;
- (void)uploadImageAsDataToS3:(NSData *)data key:(NSString *)key withCompletionBlock:(void (^)(id result))block;
- (void)downloadFullImage:(NSString *)key withCompletionBlock:(void (^)(id result))block; 
- (void)downloadThumbnail:(NSString *)key withCompletionBlock:(void (^)(id result))block;

// - (void)retrieveGroupUsers:(NSString *)groupID withCompletionBlock:(void (^)(id result))block;
- (void)retrieveGroupUsers:(NSString *)groupID
                  //startKey:(NSString *)startKey
                  startKey:(NSDictionary *)startKey
                     limit:(NSInteger)limit
       withCompletionBlock:(void (^)(id result))block;
- (void)retrieveUser:(NSString *)groupID withCompletionBlock:(void (^)(id result))block;
- (void)getUserRelationType:(NSString *)userIDRelation withCompletionBlock:(void (^)(id result))block;

@end
