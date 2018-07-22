//
//  Global.h
//  MMCM2
//
//  Created by Richard Montricul on 7/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "ServerInterface.h"
#import "MyUserData.h"
#import "GroupList.h"
#import "FriendList.h"

typedef NS_ENUM(NSInteger, authStatus)
{
   AUTHORIZED = 0,
   DENIED = 1,
   UNKNOWN = 2
};

typedef NS_ENUM(NSInteger, device)
{
   CAMERA = 0,
   CAMERA_ROLL = 1,
   MICROPHONE = 2
};

typedef NS_ENUM(NSInteger, SORTMODE)
{
   RECENT = 0,
   ALPHABETICAL = 1,
};

typedef NS_OPTIONS(NSUInteger, customControlEvent)
{
   customControlEventContentsUpdated = 1 << 24,
   customControlEventTBD1 = 1 << 25,
   customControlEventTBD2 = 1 << 26,
   customControlEventTBD3 = 1 << 27
};

@interface Global : NSObject

extern CGFloat goldenRatio;

extern CGRect  screenRect;
extern CGFloat screenHeight;
extern CGFloat screenWidth;
extern CGFloat tabBarHeight;

extern UIColor *gray;
extern UIColor *darkGray;
extern UIColor *themeColor;
extern UIColor *themeColorLight;

extern ServerInterface *server;

extern authStatus cameraAuthStatus;
extern authStatus cameraRollAuthStatus;

extern MyUserData *myUserData;
extern GroupList *myGroupList;
extern FriendList *myFriendList;

+ (id)sharedManager;
// - (void)setMyUserData:(id)data;

@end
