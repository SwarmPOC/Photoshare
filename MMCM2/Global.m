//
//  Global.m
//  MMCM2
//
//  Created by Richard Montricul on 7/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "Global.h"

@implementation Global
ServerInterface *server;

CGFloat goldenRatio = 1.61803;

CGRect  screenRect;
CGFloat screenHeight;
CGFloat screenWidth;
CGFloat tabBarHeight;

UIColor *gray;
UIColor *darkGray;
UIColor *themeColor;
UIColor *themeColorLight;

authStatus cameraAuthStatus;
authStatus cameraRollAuthStatus;

MyUserData *myUserData;
FriendList *myFriendList;
GroupList *myGroupList;

// NSInteger gOption_myStatus;
// BOOL gOption_showComplicated;

+ (id)sharedManager {
   static Global *sharedManager = nil;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{ sharedManager = [[self alloc] init]; });
   return sharedManager;
}


- (id)init 
{
   if (self = [super init]) {
      [self setupVars];
      server = [ServerInterface sharedManager];
   }
   return self;
}


- (void)setupVars;
{
   screenRect   = [[UIScreen mainScreen] bounds];
   screenHeight = screenRect.size.height;
   screenWidth  = screenRect.size.width;

   //gray = [UIColor colorWithWhite: 1.00 alpha:1];
   gray = [UIColor colorWithRed:(222/255.0) green:(225/255.0) blue:(227/255.0) alpha: 1.0];
   darkGray = [UIColor colorWithRed:(142/255.0) green:(142/255.0) blue:(147/255.0) alpha: 1.0];
   themeColor = [UIColor colorWithRed:(216/255.0)  green:(67/255.0)  blue:(67/255.0)  alpha:1.0f];
   themeColorLight = [UIColor colorWithRed:(219/255.0)  green:(85/255.0)  blue:(85/255.0)  alpha:1.0f];

   [self checkAuthorization];
}


// - (void)setMyUserData:(id)data;
// {
//    myUserData = [NSMutableDictionary dictionaryWithDictionary:data];
// }


- (void)checkAuthorization
{
   AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
   switch (status) {
      case AVAuthorizationStatusAuthorized:
         cameraAuthStatus = AUTHORIZED;
         break;
      case AVAuthorizationStatusDenied:
         cameraAuthStatus = DENIED;
         break;
      case AVAuthorizationStatusRestricted:
         cameraAuthStatus = DENIED;
         break;
      case AVAuthorizationStatusNotDetermined:
         cameraAuthStatus = UNKNOWN;
         break;
      default:
       break;
   }

   PHAuthorizationStatus pStatus = [PHPhotoLibrary authorizationStatus];
   switch (pStatus) {
      case PHAuthorizationStatusAuthorized:
         cameraRollAuthStatus = AUTHORIZED;
         break;
      case PHAuthorizationStatusDenied:
         cameraRollAuthStatus = DENIED;
         break;
      case PHAuthorizationStatusRestricted:
         cameraRollAuthStatus = DENIED;
         break;
      case PHAuthorizationStatusNotDetermined:
         cameraRollAuthStatus = UNKNOWN;
      default:
         break;
   }
        // [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        //     if (status == PHAuthorizationStatusAuthorized) {
        //         // Access has been granted.         
        //     }
        //     else {
        //         // Access has been denied.
        //     }
        // }];  
   
   //
   //
   //     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please give this app permission to access your photo library in your settings app!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
   //     [alert show];
   // }
}

@end
