//
//  CommonViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 12/14/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "Global.h"
#import "ViewUtilities.h"

typedef NS_ENUM(NSInteger, HEADER_ACCESSORY_BUTTON_TYPE)
{
   MENU = 0,
   ADD = 1
};

@interface CommonViewController : UIViewController
extern Global *global;

@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UILabel *subHeaderLabel;
@property (strong, nonatomic) UIButton *headerBackButton;
@property (strong, nonatomic) UIButton *headerAccessoryButton;

- (void)setupViews;
- (void)setupVars;
- (BOOL)showHeader;
- (BOOL)registerKeyboardNotifications;
// - (void)setupHeaderLabel;
- (void)requestAuthorizationForDevice:(device)device;
- (void)showSimplePopup:(NSString *)title message:(NSString *)message handler:(void (^)(UIAlertAction *action))block;
- (UIButton *)newMenuButon;
- (UIButton *)newButtonHeaderRight:(HEADER_ACCESSORY_BUTTON_TYPE)bType;
- (UIButton *)newTextButton:(NSString *)text;
- (BOOL)isMyID:(NSString *)userID;
@end
