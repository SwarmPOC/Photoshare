//
//  CommonViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/14/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "CommonViewController.h"

@interface CommonViewController ()

@end

@implementation CommonViewController
Global *global;
int headerHeight = 80;

-(BOOL)shouldAutorotate
{
   return NO;
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (BOOL)registerKeyboardNotifications; {
    return false;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   global = [Global sharedManager];
   [self setupVars];
   [self setupViews];
   [self setupNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupVars;
{
}

- (void)setupViews;
{
   self.view.backgroundColor = [UIColor whiteColor];
   if ([self showHeader]) {
      [self setupHeaderLabel];
      if ([self showSubHeader]) {
         [self setupSubHeaderLabel];
      }
      if ([self showBackButton]) {
         [self setupHeaderBackButton];
      }
      if ([self showHeaderAccessoryButton]) {
         [self setupHeaderAccessoryButton];
      }
   }
}

- (void)setupNotifications;
{
   if ([self registerKeyboardNotifications]) {
      [self registerForKeyboardNotifications];
   }
}

- (void)registerForKeyboardNotifications
{
   [[NSNotificationCenter defaultCenter]
      addObserver:self
      selector:@selector(keyboardWasShown:)
      name:UIKeyboardDidShowNotification
      object:nil];
   [[NSNotificationCenter defaultCenter] 
      addObserver: self 
      selector: @selector(keyboardWillShow:) 
      name: UIKeyboardWillChangeFrameNotification 
      object: nil];
   [[NSNotificationCenter defaultCenter] 
      addObserver: self 
      selector: @selector(keyboardWillHide:) 
      name: UIKeyboardWillHideNotification 
      object: nil];
}

- (BOOL)showHeader;
{
   return NO;
}
- (NSInteger)headerHeight;
{
   return 80;
}
- (NSString *)headerText;
{
   return @"";
}
- (BOOL)showSubHeader;
{
   return NO;
}
- (NSInteger)subHeaderHeight;
{
   return 20;
}
- (NSString *)subHeaderText;
{
   return @"";
}
- (BOOL)showBackButton;
{
   return NO;
}
- (BOOL)showHeaderAccessoryButton;
{
   return NO;
}
- (HEADER_ACCESSORY_BUTTON_TYPE)headerAccessoryButtonType;
{
   return MENU;
}


- (void)setupHeaderLabel;
{
   _headerLabel = [self newHeaderLabel:NO];
   [self.view addSubview:_headerLabel];
}
- (void)setupSubHeaderLabel;
{
   _subHeaderLabel = [self newHeaderLabel:YES];
   [self.view addSubview:_subHeaderLabel];
}

- (UILabel *)newHeaderLabel:(BOOL)isSubHeader;
{
   UILabel *label = [[UILabel alloc] init];
   label.frame = CGRectMake(
         0,
         isSubHeader ? CGRectGetMaxY(_headerLabel.frame) : 0,
         screenWidth,
         isSubHeader ? [self subHeaderHeight] : [self headerHeight]
   );
   label.textAlignment = NSTextAlignmentCenter;
   label.textColor = [UIColor blackColor];
   label.numberOfLines = 1;
   label.font = isSubHeader ? 
      [UIFont systemFontOfSize: 13 weight:UIFontWeightRegular] :
      [UIFont systemFontOfSize: 15 weight:UIFontWeightMedium];
   label.text = isSubHeader ? [self subHeaderText] : [self headerText];
   return label;
}


- (void)setupHeaderBackButton;
{
   CGFloat size = 25;
   _headerBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
   [_headerBackButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   [_headerBackButton setBackgroundColor: [UIColor redColor]];

   _headerBackButton.frame = CGRectMake(0,0,size,size);
   _headerBackButton.center = _headerLabel.center;
   [ViewUtilities setX:20 forView:_headerBackButton];

   UIImage *image = [[UIImage imageNamed:@"arrowLeft"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
   UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
   imageView.frame = CGRectMake(0,0,25,25);
   imageView.contentMode = UIViewContentModeScaleAspectFit;
   [_headerBackButton setTintColor:[UIColor blackColor]];
   [_headerBackButton addSubview:imageView];
   [self.view addSubview:_headerBackButton];
}



- (void)showSimplePopup:(NSString *)title message:(NSString *)message handler:(void (^)(UIAlertAction *action))block;
{
   UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];

   UIAlertAction* defaultAction = [UIAlertAction
      actionWithTitle:NSLocalizedString(@"OK", @"OK action")
      style:UIAlertActionStyleDefault
      handler:block];
   [alert addAction:defaultAction];

   UIAlertAction *cancelAction = [UIAlertAction 
      actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
      style:UIAlertActionStyleCancel
      handler:^(UIAlertAction *action) {} ];
   [alert addAction:cancelAction];

   [self presentViewController:alert animated:YES completion:nil];
}


- (void)requestAuthorizationForDevice:(device)device;
{
   switch (device) {
      case CAMERA:
         [self showSimplePopup:@"We're about to ask you for permission to use the camera..."
            message:@"Click OK on the following popup to allow access to your camera"
            handler:^void (UIAlertAction *action) {
               [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {}];
            }];
         break;
      case CAMERA_ROLL:
         [self showSimplePopup:@"We're about to ask you for permission to access your photos"
            message:@"This is necessary in order to save pictures to your phone or to let you choose pictures from your camera roll"
            handler:^void (UIAlertAction *action) {
               [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {}];
            }];
         break;
      case MICROPHONE:
         break;
      default:
         break;
   }

         //[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // if(granted) // Access has been granted ..do something
               // NSLog(@"hasbeengranted");
            // else  // Access denied ..do something
               // NSLog(@"hasbeendenied");
               // dispatch_async(dispatch_get_main_queue(), ^{
               //     [[[UIAlertView alloc] initWithTitle:@"AVCam!"
               //        message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
               //        delegate:self
               //        cancelButtonTitle:@"OK"
               //        otherButtonTitles:nil] show];
               // });
}

- (void)setupHeaderAccessoryButton;
{
   _headerAccessoryButton = [self newButtonHeaderRight:[self headerAccessoryButtonType]];
   [_headerAccessoryButton
      addTarget:self
      action:@selector(headerAccessoryButtonClicked)
      forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:_headerAccessoryButton];
}


- (UIButton *)newMenuButon;
{
   return [self newButtonHeaderRight:MENU];
}

- (UIButton *)newButtonHeaderRight:(HEADER_ACCESSORY_BUTTON_TYPE)bType;
{
   UIButton *button = [[UIButton alloc] init];
   [button setBackgroundColor: [UIColor redColor]];
   button.frame = CGRectMake(0,0,25,25);
   NSString *imageName;
   if (bType == MENU) {
      [button setTintColor:[UIColor blackColor]];
      imageName = @"ellipses";
   }
   else
   if (bType == ADD) {
      [button setTintColor:themeColor];
      imageName = @"addIconAlt";
   }
   UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
   UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
   imageView.frame = CGRectMake(0,0,25,25);
   imageView.contentMode = UIViewContentModeScaleAspectFit;
   [button addSubview:imageView];
   button.center = self.headerLabel.center;
   [ViewUtilities setX:screenWidth - button.frame.size.width - 20 forView:button];
   return button;
}

- (UIButton *)newTextButton:(NSString *)text;
{
   UIButton *button = [[UIButton alloc] init];
   [button setTitle:text forState:UIControlStateNormal];
   [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
   [button sizeToFit];
   button.backgroundColor = [UIColor redColor];
   return button;
}

- (void)backButtonClicked;
{
   [self.navigationController popViewControllerAnimated:YES];
}
- (void)headerAccessoryButtonClicked;
{
}

//==================================
- (BOOL)isMyID:(NSString *)userID; {
//==================================
   return ([userID isEqual:myUserData.userID]) ? YES : NO;
}
@end
