//
//  ServerInterface.m
//  MMCM2
//
//  Created by Richard Montricul on 8/29/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "ServerInterface.h"

// Frameworks
   #import <FBSDKCoreKit/FBSDKAccessToken.h>
   #import <FBSDKCoreKit/FBSDKGraphRequest.h>
   #import <FBSDKLoginKit/FBSDKLoginKit.h>
   #import <AWSLambda/AWSLambda.h>
   #import <AWSS3/AWSS3.h>
   #import <AWSS3/AWSS3TransferManager.h>

// 3rd Party
   #import "Reachability.h"

// local
   #import "MMCMIdentityProvider.h"

@implementation ServerInterface

NSString *FBTokenString;
NSString *FBUserID;
NSString *AWSCognitoID;
NSString *s3ImageBucket     = @"com.matchmecatchme.user.images";
NSString *s3ThumbnailBucket = @"com.matchmecatchme.user.thumbnails";
AWSCognitoCredentialsProvider *credentialsProvider;
AWSServiceConfiguration *configuration;


- (void)AWSTest:(NSString *)string withCompletionBlock:(void (^)(id result))block;
{
   [self invoke:@"MMCM_Private_RegistrationCodes"
      params:@{@"registrationCodesAction" : @"createNewUserCode",
               @"code":string}
      withResultBlock:^void(AWSTask *task) {
         block(task.result);
      }
   ];
}

+ (id)sharedManager {
   static ServerInterface *sharedManager = nil;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{ sharedManager = [[self alloc] init]; });
   return sharedManager;
}

- (id)init 
{
   if (self = [super init]) {
   }
   return self;
}

- (BOOL)hasFBCredentials; 
{
   // if ([FBSDKAccessToken currentAccessToken]) {
   FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
   if (accessToken) {
      FBTokenString = accessToken.tokenString;
      FBUserID = accessToken.userID;
   }
   return accessToken != NULL;
}

- (BOOL)preCheck;
{
   if ([self hasFBCredentials]) {
      //presumeably there will be more here besides just the FBCheck
      return YES;
   }
   return NO;
}

- (void)checkInternet
{
   // Allocate a reachability object
   Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];

   // Set the blocks
   reach.reachableBlock = ^(Reachability*reach) {
       // dispatch_async(dispatch_get_main_queue(), ^{
       //    // not sure what to do here...maybe nothign?
       // });
   };
   reach.unreachableBlock = ^(Reachability*reach) {
       //push intnernet offline notification
   };

   // Start the notifier, which will cause the reachability object to retain itself!
   [reach startNotifier];
}


- (void)invoke:(NSString *)function params:(NSDictionary *)params withResultBlock:(void (^)(AWSTask *task))block;
{
   if (configuration) {
      AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
      NSMutableDictionary *mParams = [NSMutableDictionary dictionaryWithDictionary:params];
      [mParams setObject:FBUserID      forKey:@"userID"];
      [mParams setObject:FBTokenString forKey:@"FBTokenString"];
      [mParams setObject:AWSCognitoID  forKey:@"AWSCognitoID"];
      [mParams setObject:@NO           forKey:@"isError"];
      [[lambdaInvoker invokeFunction:function JSONObject:mParams] continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
            NSLog(@"Error: %@", task.error);
            if ([task.error.domain isEqualToString:AWSLambdaInvokerErrorDomain]
                && task.error.code == AWSLambdaInvokerErrorTypeFunctionError) {
                NSLog(@"Function error: %@", task.error.userInfo[AWSLambdaInvokerFunctionErrorKey]);
            }
         }
         if (task.exception) {
            NSLog(@"Exception: %@", task.exception);
         }
         if (task.result) {
            NSLog(@"%@ Result: %@", [params objectForKey:@"action"], task.result);
            if (block)
               block(task);
         }
         return nil;
      }];
   }
}
- (void)invoke:(NSString *)function action:(NSString *)action withCompletionBlock:(void (^)(id result))block precheck:(BOOL)precheck;
{
   if ((precheck && [self preCheck]) || !precheck) {
      [self invoke:function
         params:@{@"action" : action}
         withResultBlock:^void(AWSTask *task) {
            block(task.result);
         }
      ];
   }
}
- (void)invokeNoPrecheck:(NSString *)action withCompletionBlock:(void (^)(id result))block;
{
   [self invoke:@"MMCM_Public_Login" action:action withCompletionBlock:block precheck:NO];
}
- (void)invoke:(NSString *)action withCompletionBlock:(void (^)(id result))block;
{
   [self invoke:@"MMCM_Public_Login" action:action withCompletionBlock:block precheck:YES];
}


- (void)initAWSCognito:(void (^)(NSNumber *userHasRegisteredWithAWS))block;
{
   MMCMIdentityProvider *provider = [[MMCMIdentityProvider alloc] init:[FBSDKAccessToken currentAccessToken].tokenString];
   credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
      initWithRegionType:AWSRegionUSEast1
      identityPoolId:@"us-east-1:b344a3f0-60b6-480f-8edb-cae3e213ebd1"
      identityProviderManager:provider];
   configuration = [[AWSServiceConfiguration alloc]
      initWithRegion:AWSRegionUSEast1
      credentialsProvider:credentialsProvider];
   [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

   [[credentialsProvider getIdentityId] continueWithBlock:^id(AWSTask *task) {
       if (task.error) {
           NSLog(@"Error: %@", task.error);
       }
       else {
         AWSCognitoID = task.result;
         [self invoke:@"checkUser" withCompletionBlock:block];
       }
       return nil;
   }];
}

// - (void)checkUserRegistration:(void (^)(NSNumber *userHasRegisteredWithAWS))block;
// {
//    if ([self preCheck]) {
//       [self invoke:@"MMCM_Public_Login"
//          params:@{@"action" : @"checkUser"}
//          withResultBlock:^void(AWSTask *task) {
//             block(task.result);
//          }
//       ];
//    }
// }

- (void)loginWithNewUserFlag:(BOOL)isNewUser completionBlock:(void (^)(id result))block;
{
   [self invokeNoPrecheck:(isNewUser) ? @"registerUser" : @"login" withCompletionBlock:block];
   // [self invoke:@"MMCM_Public_Login"
   //    params:@{@"action" : (isNewUser) ? @"registerUser" : @"login"}
   //    withResultBlock:^void(AWSTask *task) {
   //       block(task.result);
   //    }
   // ];
}


- (void)logout;
{
   [self invoke:@"logout" withCompletionBlock:nil];
}

- (void)retrieveFBProfileData:(void (^)(NSDictionary *result))block;
{
   [[[FBSDKGraphRequest alloc]
      initWithGraphPath:@"me"
      parameters:@{@"fields": @"id,name,first_name, last_name, name_format, email, locale, cover, gender, interested_in, relationship_status"}]
      startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
            block(result);
         } else {
            NSLog(@"error:%@", error);
         }
      }
   ];
}

- (void)saveFBProfileDataToAWS:(NSDictionary *)FBProfileData completionBlock:(void (^)(id result))block;
{
   NSLog(@"FBProfileData: %@", FBProfileData);
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"saveFBProfileData",
         @"name":[FBProfileData objectForKey:@"name"],
         @"first_name":[FBProfileData objectForKey:@"first_name"],
         @"last_name":[FBProfileData objectForKey:@"last_name"],
         @"name_format":[FBProfileData objectForKey:@"name_format"],
         @"email":[FBProfileData objectForKey:@"email"],
         @"locale":[FBProfileData objectForKey:@"locale"],
         @"gender":[FBProfileData objectForKey:@"gender"]}
      withResultBlock:^void(AWSTask *task) {
         block(task.result);
      }
   ];
}

- (void)retrieveFBFriendData:(void (^)(NSArray *result))block;
{
   [[[FBSDKGraphRequest alloc]
      initWithGraphPath:@"me/friends"
      parameters:@{@"fields": @"id"}]
      startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
            NSMutableArray *mArrayID = [[NSMutableArray alloc] init];
            NSArray *data = [result objectForKey:@"data"];
            for (NSDictionary *dic in data) {
               [mArrayID addObject:[dic objectForKey:@"id"]];
            }
            // NSLog(@"\r\n\r\nFBFriendData Dictionary!!!\r\nresult:%@", result);
            block(mArrayID);
         } else {
            NSLog(@"error:%@", error);
         }
      }
   ];
}

- (void)saveFBFriendDataToAWS:(NSArray *)FBFriendData isNewUser:(BOOL)isNewUser
        withCompletionBlock:(void (^)(NSNumber *friendCount))block;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"saveFBFriendData",
               @"ids":FBFriendData,
               @"isNewUser":isNewUser ? @"YES" : @"NO",
               @"FBFriendCount":[@([FBFriendData count]) stringValue]}
               // TODO: add way to remove someone from my list
      withResultBlock:^void(AWSTask *task) {
         if (task.error) {
             NSLog(@"Error: %@", task.error);
         }
         else {
             NSLog(@"saveFBFriendDataToAWS: %@", task.result);
             block(task.result);
         }
      }
   ];
}


- (void)retrieveFriendsForUser:(NSString *)userID withCompletionBlock:(void (^)(NSArray *result))block;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"retrieveFriends",
               @"friendsForUserID":userID}
      withResultBlock:^void(AWSTask *task) {
         block(task.result);
      }
   ];
}

- (void)verifyInviteCode:(NSString *)code withCompletionBlock:(void (^)(id result))block;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"verifyInviteCode",
               @"code":code}
      withResultBlock:^void(AWSTask *task) {
         block(task.result);
      }
   ];
}

- (void)updateName:(NSDictionary *)vals;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"updateName",
               @"name":[vals objectForKey:@"name"],
               @"first_name":[vals objectForKey:@"firstName"],
               @"last_name":[vals objectForKey:@"lastName"]}
      withResultBlock:nil
   ];
}

- (void)updateGender:(NSString *)gender;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"updateGender",
               @"gender":gender}
      withResultBlock:nil
   ];
}

- (void)updateRelationshipStatus:(NSString *)relationshipStatus isInitialStatus:(BOOL)isInitialStatus;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"updateRelationshipStatus",
               @"relationshipStatus":relationshipStatus,
               @"isInitialStatus":isInitialStatus ? @"YES": @"NO"}
      withResultBlock:nil
   ];
}

- (void)updateLookingFor:(NSString *)lookingFor;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"updateLookingFor",
               @"lookingFor":lookingFor}
      withResultBlock:nil
   ];
}




#pragma Profile functions
- (void)retrieveGroupData:(void (^)(id result))block;
{
   [self invoke:@"retrieveGroupData" withCompletionBlock:block];
}

//- (void)getUserMediaTagCount

// types of media uploads:
//    camera captured profile picture
//    camera roll profile picture
//    camera captured conversation picture
//    camera roll conversation picture
// 
//    variables: source
//               destination

- (void)addProfilePicture:(NSData *)data userArray:(NSArray *)userArray tagArray:(NSArray *)tagArray caption:(NSString *)caption;
{
   NSString *key = [[NSUUID UUID] UUIDString];
   // send to s3
      [self uploadImageAsDataToS3:data key:key withCompletionBlock:^(id result){ 
         // create db record
            NSMutableDictionary *mParams = [[NSMutableDictionary alloc] init];
               [mParams setObject:@"addProfilePicture" forKey:@"action"];
               [mParams setObject:key                  forKey:@"mediaID"];
               [mParams setObject:s3ImageBucket        forKey:@"s3BucketName"];
               [mParams setObject:tagArray             forKey:@"tagArray"];
               if ([caption length] > 0)
                  [mParams setObject:caption           forKey:@"caption"];
               if ([userArray count] > 0)
                  [mParams setObject:userArray         forKey:@"userArray"];
            [self invoke:@"MMCM_Public_Login" params:mParams withResultBlock:nil];
      }];
}


- (void)removeMediaReferences:(NSString *)mediaID;
{
   NSMutableDictionary *mParams = [[NSMutableDictionary alloc] init];
      [mParams setObject:@"removeMediaReferences" forKey:@"action"];
      [mParams setObject:mediaID                  forKey:@"mediaID"];
   [self invoke:@"MMCM_Public_Login" params:mParams withResultBlock:nil];
}


- (void)retrieveTagsForUserID:(NSString *)userID completionBlock:(void (^)(id result))block;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"retrieveTagsForUserID",
               @"forUser" : userID}
      withResultBlock:^void(AWSTask *task) {
         block(task.result);
      }
   ];
}
- (void)retrieveMediaForTag:(NSString *)tag completionBlock:(void (^)(id result))block;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"retrieveMediaForTag",
               @"tag" : tag}
      withResultBlock:^void(AWSTask *task) {
         block(task.result);
      }
   ];
}


- (void)uploadImageAsDataToS3:(NSData *)data key:(NSString *)key bucket:(NSString *)bucket withCompletionBlock:(void (^)(id result))block;
{
   AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", key]];
   //NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"test.png"]];
   [data writeToFile:filePath atomically:YES];
   //upload the image
   AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
   uploadRequest.body = [NSURL fileURLWithPath:filePath];
   uploadRequest.bucket = bucket;
   uploadRequest.key = [NSString stringWithFormat:@"%@.jpg", key];
   [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
      if (task.error) {
          if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
              switch (task.error.code) {
                  case AWSS3TransferManagerErrorCancelled:
                  case AWSS3TransferManagerErrorPaused:
                      break;
                  default:
                      NSLog(@"Error: %@", task.error);
                      break;
              }
          } else { // Unknown error.
              NSLog(@"Error: %@", task.error);
          }
      }
      if (task.result) { // The file uploaded successfully.
          //AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
          block(task.result);
      }
      return nil;
   }];
}

- (void)uploadImageAsDataToS3:(NSData *)data key:(NSString *)key withCompletionBlock:(void (^)(id result))block;
{
   [self uploadImageAsDataToS3:data key:key bucket:s3ImageBucket withCompletionBlock:^(id result){
         [self uploadImageAsDataToS3:[self croppedImageData:data] key:key bucket:s3ThumbnailBucket 
            withCompletionBlock:block];
      }];
}


- (NSData *)croppedImageData:(NSData *)originalImageData;
{
   UIImage *image = [UIImage imageWithData:originalImageData];
   CGRect rect = [self getCropRectForImage:image];
   // resize image
      //UIGraphicsBeginImageContext(CGSizeMake(180,240));
      UIGraphicsBeginImageContext(CGSizeMake(rect.size.width,rect.size.height));
      [image drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
      UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();    
      UIGraphicsEndImageContext();
   // crop image
      CGImageRef imageRef = CGImageCreateWithImageInRect(
            [resizedImage CGImage],
            CGRectMake(rect.origin.x, rect.origin.y, 180, 240) );
      UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
      CGImageRelease(imageRef);
   return UIImageJPEGRepresentation(croppedImage, 0.8);
}


- (CGRect)getCropRectForImage:(UIImage *)image;
{
   double width  = CGImageGetWidth(image.CGImage);
   double height = CGImageGetHeight(image.CGImage);
   double ratio = (width > height) ? 240/height : 180/width; 
   height = height * ratio;
   width = width * ratio;
   return CGRectMake(width/2 - 90, height/2 - 120, width, height);
}


- (void)downloadImage:(NSString *)key bucket:(NSString *)bucket withCompletionBlock:(void (^)(id result))block;
{
   AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
   NSString *downloadingFilePath = [NSTemporaryDirectory()
      stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", key]];
   NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
   AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
   downloadRequest.bucket = bucket;
   downloadRequest.key = [NSString stringWithFormat:@"%@.jpg", key];
   downloadRequest.downloadingFileURL = downloadingFileURL;

   [[transferManager download:downloadRequest ] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
       if (task.error){
           if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
               switch (task.error.code) {
                   case AWSS3TransferManagerErrorCancelled:
                   case AWSS3TransferManagerErrorPaused:
                   break;

                   default:
                       NSLog(@"Error: %@", task.error);
                       break;
               }
           } else { // Unknown error.
               NSLog(@"Error: %@", task.error);
           }
       }
       if (task.result) { //File downloaded successfully.
           //AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
           UIImage *image = [UIImage imageWithContentsOfFile:downloadingFilePath];
           block(image);
       }
       return nil;
   }];
}
- (void)downloadFullImage:(NSString *)key withCompletionBlock:(void (^)(id result))block; 
{
   [self downloadImage:key bucket:s3ImageBucket withCompletionBlock:block];
}
- (void)downloadThumbnail:(NSString *)key withCompletionBlock:(void (^)(id result))block;
{
   [self downloadImage:key bucket:s3ThumbnailBucket withCompletionBlock:block];
}


- (void)retrieveGroupUsers:(NSString *)groupID
                  startKey:(NSDictionary *)startKey
                     limit:(NSInteger)limit
       withCompletionBlock:(void (^)(id result))block;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"retrieveGroupUsers",
               @"groupID" : groupID,
               @"exclusiveStartKey" : startKey,
               @"limit" : @(limit)}
      withResultBlock:^void(AWSTask *task) {
         block(task.result);
      }
   ];
}

- (void)retrieveUser:(NSString *)userID withCompletionBlock:(void (^)(id result))block;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"retrieveUser",
               @"userIDToRetrieve" : userID}
      withResultBlock:^void(AWSTask *task) {
         block(task.result);
      }
   ];
}

- (void)getUserRelationType:(NSString *)userIDRelation withCompletionBlock:(void (^)(id result))block;
{
   [self invoke:@"MMCM_Public_Login"
      params:@{@"action" : @"getUserRelationType",
               @"userIDRelation" : userIDRelation}
      withResultBlock:^void(AWSTask *task) {
         block(task.result);
      }
   ];
}


////////////////////////////////////////////////////////////////////////////////
#pragma OLD CODE
////////////////////////////////////////////////////////////////////////////////

/*
- (void)loadAWSDynamoDBUserRecord;
{
   AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
   [[dynamoDBObjectMapper load:[User class] hashKey:FBUserID rangeKey:nil]
   continueWithBlock:^id(AWSTask *task) {
      if (task.error) {
         NSLog(@"The request failed. Error: [%@]", task.error);
      }
      else if (task.exception) {
         NSLog(@"The request failed. Exception: [%@]", task.exception);
      }
      else if (task.result) {
         NSLog(@"The request SUCCEEDED");
         User *user = task.result;
      }
      else { //Amazon isn't responding correctly
         NSLog(@"The request FAILED TO GET A RESPONSE: creating new user object");
         [dynamoDBObjectMapper save:[self newUser]];
      }
      return nil;
   }];
}

- (User *)newUser;
{
   User *user = [[User alloc] init];
   user.userID = FBUserID;
   user.FBTokenString = FBTokenString;
   user.creationDate = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
   user.lastModifiedDate = user.creationDate;
   user.lastLoginDate = user.creationDate;
   user.loginCount = [NSNumber numberWithInt:1];
   return user;
}
*/

@end
