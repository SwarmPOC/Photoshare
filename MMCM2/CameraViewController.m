//
//  CameraViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/21/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "CameraViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "FocusBox.h"
#import "CaptureConfirmation.h"
#import "FriendSelectorViewController.h"
#import "CameraRollCollectionViewCell.h"
#import "ProfileViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController
// Var
   // device sensor related
      CMMotionManager *motionManager;
      NSOperationQueue *motionQueue;
      AVCaptureVideoPreviewLayer *previewLayer;
      static NSData *imageData;  //image that was captured

   // non-user touch interactive elements
      FocusBox *focusBox;
      UIView *leveler;
         NSInteger levelArmLength = 15;
         NSMutableArray *levelArms;
      UIView *grid;
         NSMutableArray *gridLines;

   // buttons and touch elements
      UIButton *cancelButton;
      UIButton *captureButton;
      UIButton *switchCameraButton;
      UIButton *flashButton;

   // Capture Confirmation elements
      CaptureConfirmation *captureConfirmationView;
      UIButton *preview;
      UIImageView *capturePreview;
      UIView *capturePreviewShade;
      BOOL isDoubleBackspace = NO; //assists with keyboard hiding during caption editing

   // Camera Roll elements
      UICollectionView *cameraRoll;
      PHFetchResult *cameraRollAssets;
      PHImageRequestOptions *requestOptions;

   // helper var
      UIDeviceOrientation lastOrientation = UIDeviceOrientationPortrait;
      NSMutableArray *rotationArray; // every control that needs to be rotated
      static CGFloat defaultButtonAlpha = 0.4;
      // static int keyboardHeight;
      static NSMutableArray *taggeedUsersArray;

   // other
      bool exitRequested = NO;
      NSString *exitError = @"";
      static UITextView *onScreenLog;


- (id)init:(id)Delegate;
{
   self = [super init];
   _delegate = Delegate;
   return self;
}

- (void)setupTemp
{
}

-(BOOL)shouldAutorotate
{
   return NO;
}

- (void)viewDidLoad {
   rotationArray = [[NSMutableArray alloc] init];
   [super viewDidLoad];
   self.view.backgroundColor = [UIColor blackColor];
}
- (void)viewWillAppear:(BOOL)animated;
{
   [self registerObservers];
}
- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   if (exitRequested) {
      [self exitWithError:exitError];
   }
   [self setOrientation];
}
- (void)viewWillDisappear:(BOOL)animated;
{
   [self removeObservers];
}


- (void)exitWithError:(NSString *)text;
{
   UIAlertController * alert=   [UIAlertController
                                    alertControllerWithTitle:@"uh-oh!"
                                    message:text
                                    preferredStyle:UIAlertControllerStyleAlert];
   UIAlertAction* ok = [UIAlertAction
                        actionWithTitle:@"OK"
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action) {
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }];
   [alert addAction:ok];
   [self presentViewController:alert animated:YES completion:nil];
}


- (void)setupViews;
{
   [super setupViews];
   [self setupTouchLayer];
   [self setupCapture];
   // background elements
      // [self setupTemp];
      // [self setupLog];
      [self setupFocusBox];
      [self setupGrid];
      [self setupLeveler];
      [self setupReticle];

   //foreground elements:
      [self setupCancelButton];
      [self setupCaptureButton];
      [self setupSwitchCameraButton];
      [self setupFlashButton];
      [self setupCameraRoll];

      [self setupCapturePreview];
      [self setupCapturePreviewShade];
      [self setupCaptureConfirmation];
      [self registerForKeyboardNotifications];
}


- (void)setupFocusBox;
{
   focusBox = [[FocusBox alloc] init];
   focusBox.alpha = 0.0;
   [self.view addSubview:focusBox];
}


- (void)setupGrid;
{
   grid = [[UIView alloc] init];
   grid.frame = screenRect;
   grid.alpha = 0.0;
   gridLines = [[NSMutableArray alloc] init];
   [gridLines addObject:[self newGridLine:screenHeight/3 isHorizontal:YES]];
   [gridLines addObject:[self newGridLine:2*screenHeight/3 isHorizontal:YES]];
   [gridLines addObject:[self newGridLine:screenWidth/3 isHorizontal:NO]];
   [gridLines addObject:[self newGridLine:2*screenWidth/3 isHorizontal:NO]];
   grid.userInteractionEnabled = NO;
   [self.view addSubview:grid];
}


- (void)setupLeveler;
{
   [self setupMotionManager];
   leveler = [[UIView alloc] init];
   leveler.frame = CGRectMake(0,0,50+2*levelArmLength,1);
   leveler.center = self.view.center;
   levelArms = [[NSMutableArray alloc] init];
   [self newLevelArm:0];
   [self newLevelArm:leveler.frame.size.width - levelArmLength];
   //[levelArms addObject:[self newLevelArm:leveler.frame.size.width - levelArmLength]];

   leveler.alpha = 0.0;
   leveler.userInteractionEnabled = NO;
   [self.view addSubview:leveler];
}


- (void)setupReticle;
{
}

- (void)setupCapturePreview;
{
   preview = [[UIButton alloc] init];
   preview.frame = screenRect;
   preview.alpha = 0.0;
   [preview addTarget:self action:@selector(previewClicked) forControlEvents:UIControlEventTouchUpInside];

   capturePreview = [[UIImageView alloc] init];
   capturePreview.contentMode = UIViewContentModeScaleAspectFill;
   capturePreview.frame = screenRect;
   [preview addSubview:capturePreview];
   [self.view addSubview:preview];
}


- (void)setupCaptureConfirmation;
{
   taggeedUsersArray = [[NSMutableArray alloc] init];
   captureConfirmationView = [[CaptureConfirmation alloc] init:self];
   captureConfirmationView.center = self.view.center;
   captureConfirmationView.alpha = 0.0f;
   [ViewUtilities setY:140 forView:captureConfirmationView];
   [captureConfirmationView.acceptButton addTarget:self
      action:@selector(acceptButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   [captureConfirmationView.retakeButton addTarget:self
      action:@selector(retakeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   [captureConfirmationView.preview addTarget:self
      action:@selector(previewButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
      action:@selector(tagTextViewTapped)];

   [captureConfirmationView.switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
   [captureConfirmationView.tagTextView addGestureRecognizer:gestureRecognizer];
   [self.view addSubview:captureConfirmationView];
}


- (void)setupCancelButton;
{
   cancelButton = [self newTextButton:@"CANCEL"];

   // cancelButton = [[UIButton alloc] init];
   // [cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
   // [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   // cancelButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
   // [cancelButton sizeToFit];
   // cancelButton.backgroundColor =[UIColor clearColor];

   [cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];

   cancelButton.alpha = 0.9f;
   [ViewUtilities setXY:CGPointMake(20,20) forView:cancelButton];
   [self.view addSubview:cancelButton];
   [rotationArray addObject:cancelButton];
}

- (void)setupCaptureButton;
{
   int buttonDiameter = 50;
   captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
   captureButton.frame = CGRectMake(
         (screenWidth - buttonDiameter)/2,
         screenHeight-(buttonDiameter + 20) - 48,
         buttonDiameter,
         buttonDiameter);
   captureButton.backgroundColor = [UIColor whiteColor];
   captureButton.layer.borderWidth = 1;
   captureButton.layer.borderColor = [UIColor clearColor].CGColor;
   captureButton.layer.cornerRadius = buttonDiameter/2;
   captureButton.layer.masksToBounds = YES;
   [captureButton addTarget:self action:@selector(captureButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   captureButton.alpha = 0.3;

   UIView *outerBorder = [[UIView alloc] init];
   outerBorder.backgroundColor = [UIColor clearColor];
   outerBorder.frame = CGRectMake(0,0, buttonDiameter + 12, buttonDiameter + 12);
   outerBorder.layer.borderWidth = 4;
   outerBorder.layer.borderColor = [UIColor whiteColor].CGColor;
   outerBorder.layer.cornerRadius = outerBorder.frame.size.width/2;
   outerBorder.layer.masksToBounds = YES;
   outerBorder.center = captureButton.center;
   outerBorder.alpha = 0.6;

   [self.view addSubview:outerBorder];
   [self.view addSubview:captureButton];

   [rotationArray addObject:outerBorder];
   [rotationArray addObject:captureButton];
}


- (void)setupSwitchCameraButton;
{
   Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
   if (captureDeviceClass != nil) {
      switchCameraButton = [self newTextButton:@"FLIP"];

      // switchCameraButton = [[UIButton alloc] init];
      // [switchCameraButton setTitle:@"FLIP" forState:UIControlStateNormal];
      // [switchCameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      // switchCameraButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
      // [switchCameraButton sizeToFit];

      [switchCameraButton addTarget:self action:@selector(switchCameraButtonClicked) forControlEvents:UIControlEventTouchUpInside];
      switchCameraButton.alpha = defaultButtonAlpha;
      switchCameraButton.center = captureButton.center;
      //[ViewUtilities setX:screenWidth - switchCameraButton.frame.size.width - 20 forView:switchCameraButton];
      CGFloat x = (screenWidth + CGRectGetMaxX(captureButton.frame) - switchCameraButton.frame.size.width)/2;
      [ViewUtilities setX:x forView:switchCameraButton];
      [self.view addSubview:switchCameraButton];
      [rotationArray addObject:switchCameraButton];
   }
}

- (void)setupFlashButton;
{
   if ([_videoDevice hasFlash]){
      flashButton = [self newTextButton:@"FLASH:OFF"];
      [flashButton addTarget:self action:@selector(flashButtonClicked) forControlEvents:UIControlEventTouchUpInside];
      flashButton.alpha = defaultButtonAlpha;
      flashButton.center = captureButton.center;
      CGFloat x = (captureButton.frame.origin.x - flashButton.frame.size.width)/2;
      [ViewUtilities setX:x forView:flashButton];
      [self.view addSubview:flashButton];
      [rotationArray addObject:flashButton];
   }
}

- (void)setupCameraRoll;
{
   UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
   [layout setItemSize:CGSizeMake(48, 48)];
   [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
   layout.minimumLineSpacing = 5;
   layout.minimumInteritemSpacing = 0;
   cameraRoll = [[UICollectionView alloc] initWithFrame:
      CGRectMake(0,screenHeight-48,screenWidth, 48) collectionViewLayout:layout];
   cameraRoll.backgroundColor = [UIColor clearColor];
   cameraRoll.delegate = self;
   cameraRoll.dataSource = self;
   cameraRoll.showsVerticalScrollIndicator = NO;
   cameraRoll.allowsSelection = YES;
   [cameraRoll registerClass:[CameraRollCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
   [self.view addSubview:cameraRoll];

   cameraRollAssets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
   requestOptions = [[PHImageRequestOptions alloc] init];
   requestOptions.synchronous  = true;
   requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
   requestOptions.resizeMode   = PHImageRequestOptionsResizeModeFast;
}

- (void)setupCapturePreviewShade;
{
   capturePreviewShade = [[UIView alloc] init];
   capturePreviewShade.frame = screenRect;
   capturePreviewShade.backgroundColor = [UIColor blackColor];
   capturePreviewShade.alpha = 0.0f;
   [self.view addSubview:capturePreviewShade];
}

#pragma mark button Handlers
- (void)flashButtonClicked;
{
   [_videoDevice lockForConfiguration:nil];
   if (_avSettings.flashMode == AVCaptureFlashModeOff) {
       _avSettings.flashMode = AVCaptureFlashModeAuto;
       _videoDevice.flashMode = AVCaptureFlashModeAuto;
       [self setTitle:@"FLASH:AUTO" forButton:flashButton];
   }
   else if (_avSettings.flashMode == AVCaptureFlashModeAuto) {
       _avSettings.flashMode = AVCaptureFlashModeOn;
       _videoDevice.flashMode = AVCaptureFlashModeOn;
       [self setTitle:@"FLASH:ON" forButton:flashButton];
   }
   else if (_avSettings.flashMode == AVCaptureFlashModeOn) {
       _avSettings.flashMode = AVCaptureFlashModeOff;
       _videoDevice.flashMode = AVCaptureFlashModeOff;
       [self setTitle:@"FLASH:OFF" forButton:flashButton];
   }
   [_videoDevice unlockForConfiguration];
}

- (void)switchCameraButtonClicked;
{
   [_captureSession beginConfiguration];
   AVCaptureInput *currentCameraInput = [_captureSession.inputs objectAtIndex:0];
   [_captureSession removeInput:currentCameraInput];
   AVCaptureDevice *newCamera = nil;
   if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack) {
       newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
       [self setTitle:@"FLIP" forButton:switchCameraButton];
   }
   else {
       newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
       [self setTitle:@"FLIP" forButton:switchCameraButton];
   }
   [self configureDevice:newCamera];
   NSError *err = nil;
   AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
   if(!newVideoInput || err) {
       NSLog(@"Error creating capture device input: %@", err.localizedDescription);
   }
   else {
       [_captureSession addInput:newVideoInput];
   }
   [_captureSession commitConfiguration];
   _videoDevice = newCamera;
}

- (void)captureButtonClicked;
{
   [_avObject capturePhotoWithSettings:_avSettings delegate:self];
}


- (void)cancelButtonClicked;
{
   [self retakeButtonClicked];
   [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)retakeButtonClicked;
{
   //reset EVERYTHING
   CGPoint focusPoint = [previewLayer captureDevicePointOfInterestForPoint:self.view.center];
   AVCaptureDevice *device = [[self videoInput] device];
   if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
       NSError *error;
       if ([device lockForConfiguration:&error]) {
           [device setFocusPointOfInterest:focusPoint];
           [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
           [device unlockForConfiguration];
       }
   }
   [self hideCapturePreview];
   capturePreviewShade.alpha = 0.0;

   [UIView animateWithDuration:0.2f
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         captureConfirmationView.alpha = 0.0;
      } 
      completion:^(BOOL finished){
      }
   ];
   focusBox.center = self.view.center;
   focusBox.alpha = 0.0f;
   leveler.alpha = 0.0f;
   [captureConfirmationView.caption resignFirstResponder];
   // for (UIView *view in rotationArray) {
   //    view.hidden = false;
   // }
}


- (void)previewClicked;
{
   [UIView animateWithDuration:0.2f
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         capturePreviewShade.alpha = 0.5f;
         captureConfirmationView.alpha = 1.0f;
      } 
      completion:^(BOOL finished){
      }
   ];
}


- (void)acceptButtonClicked;
{
   NSString *caption = captureConfirmationView.caption.text;
   if ([caption isEqualToString:@"caption"])
      caption = @"";
   [server addProfilePicture:imageData
      //userArray:@[myUserData.userID]
      userArray:taggeedUsersArray
      tagArray:[self processCaptionForTags]
      caption:caption];
       //tagArray:@[@"untagged"]];

   if (captureConfirmationView.switchView.on)
      UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], nil, nil, nil);
   //[server uploadImageAsDataToS3:data key:[[NSUUID UUID] UUIDString]]; 
   [self resetTextView];
   [self retakeButtonClicked];
   [self dismissViewControllerAnimated:YES completion:^{
      [(ProfileViewController *)_delegate newPhotoAdded];
   }];
}


- (void)previewButtonClicked;
{
   [captureConfirmationView.caption resignFirstResponder];
   [UIView animateWithDuration:0.2f
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         capturePreviewShade.alpha = 0.0f;
         captureConfirmationView.alpha = 0.0f;
      } 
      completion:^(BOOL finished){
      }
   ];
}

- (void)tagTextViewTapped;
{
   FriendSelectorViewController *viewController = [[FriendSelectorViewController alloc] init:self array:taggeedUsersArray];
   [self presentViewController:viewController animated:YES completion:nil];
}

#pragma View modifiers


- (void)setTitle:(NSString *)title forButton:(UIButton *)button;
{
   [button setTitle:title forState:UIControlStateNormal];
   [button sizeToFit];
}


- (void)flashScreen;
{
   UIView *view = [[UIView alloc] init];
   view.frame = screenRect;
   view.backgroundColor = [UIColor whiteColor];
   [self.view addSubview:view];
   [UIView animateWithDuration:0.5
      delay:0.0
      options: UIViewAnimationOptionCurveEaseIn
      animations:^{ 
            view.alpha = 0;
      } 
      completion:^(BOOL finished){
         [view removeFromSuperview];
      }
   ];
}

- (void)flashGrid;
{
   grid.alpha = 0.6;
   [UIView animateWithDuration:4.0
      delay:0.0
      options: UIViewAnimationOptionCurveEaseIn
      animations:^{ 
            grid.alpha = 0;
      } 
      completion:^(BOOL finished){
      }
   ];
}

- (void)showFocusBox:(CGPoint)point;
{
   [self focusBoxAnimation1:point];
   [self flashGrid];
}

- (void)focusBoxAnimation1:(CGPoint)point;
{
   [focusBox setSize:200];
   focusBox.center = point;
   leveler.center = point;
   focusBox.alpha = 0.0;
   [UIView animateWithDuration:0.2
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         [focusBox setSize:50];
         focusBox.alpha = 0.5;
         leveler.alpha = 0.8;
         focusBox.center = point;
      } 
      completion:^(BOOL finished){
      }
   ];
}


- (void)removeFocusBox;
{
   [UIView animateWithDuration:3.0
      delay:3.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
            focusBox.alpha = 0.2;
      } 
      completion:^(BOOL finished){
      }
   ];
}

- (UIView *)newGridLine:(CGFloat)xy isHorizontal:(BOOL)isHorizontal;
{
   UIView *view = [[UIView alloc] init];
   if (isHorizontal) {
      view.frame = CGRectMake(0,xy,screenWidth,1);
   }
   else {
      view.frame = CGRectMake(xy,0,1,screenHeight);
   }
   view.backgroundColor = [UIColor whiteColor];
   [grid addSubview:view];
   return view;
}


- (void)newLevelArm:(CGFloat)x;
{
   UIView *view = [self newArm:0 x:x y:0];
   view.backgroundColor = [UIColor whiteColor];
   [levelArms addObject:view];
   [leveler addSubview:view];
}

- (UIView *)newArm:(int)orientation x:(CGFloat)x y:(CGFloat)y;
{
   UIView *view = [[UIView alloc] init];
   if (orientation == 0) {
      view.frame = CGRectMake(x,y,levelArmLength,1);
   }
   else {
      view.frame = CGRectMake(x,y,1,levelArmLength);
   }
   return view;
}

- (void)setLevelerColor:(UIColor *)color;
{
   for (UIView *view in levelArms) {
      view.backgroundColor = color;
   }
}


- (void)setCapturePreview:(UIImage *)image;
{
   capturePreview.image = image;
   [UIView animateWithDuration:0.2f
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         preview.alpha = 1.0f;
      } 
      completion:^(BOOL finished){
      }
   ];
}
- (void)hideCapturePreview;
{
   [UIView animateWithDuration:0.2f
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         preview.alpha = 0.0f;
      } 
      completion:^(BOOL finished){
      }
   ];
}

- (void)showCaptureConfirmationView:(UIImage *)image;
{
   captureConfirmationView.image = image;
   [UIView animateWithDuration:0.2
      delay:0.0
      options: UIViewAnimationOptionCurveEaseIn
      animations:^{ 
         capturePreviewShade.alpha = 0.5f;
         captureConfirmationView.alpha = 1.0f;
      } 
      completion:^(BOOL finished){
      }
   ];
   // for (UIView *view in rotationArray) {
   //    view.hidden = true;
   // }
}

- (NSArray *)processCaptionForTags;
{
   NSString *string = captureConfirmationView.caption.text;
   NSError *error = nil;
   NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)"
                                 options:0 error:&error];
   NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
   NSMutableArray *tagArray = [[NSMutableArray alloc] init];
   for (NSTextCheckingResult *match in matches) {
       NSRange wordRange = [match rangeAtIndex:1];
       NSString* word = [[string substringWithRange:wordRange] lowercaseString];
       [tagArray addObject:word];
   }
   if (tagArray.count == 0) {
       return @[@"untagged"];
   }
   return tagArray;
}

- (void)setSelected:(NSArray *)array;
{
   [taggeedUsersArray removeAllObjects];
   [taggeedUsersArray addObjectsFromArray:array];
   NSString *string;
   for (NSString *str in taggeedUsersArray) {
      NSDictionary *dic = [myFriendList.dicAllFirstDegree objectForKey:str];
      if (string) {
         string = [NSString stringWithFormat:@"%@, %@", string, [dic objectForKey:@"fullName"]];
      }
      else string = [dic objectForKey:@"fullName"];
   }
   [captureConfirmationView setTags:string];
   //[self showTags];
}


- (void)switchValueChanged:(UISwitch *)sender;
{
   if (cameraRollAuthStatus == UNKNOWN) {
      [self requestAuthorizationForDevice:CAMERA_ROLL];
   }
   if (cameraRollAuthStatus == DENIED) {
      [self showSimplePopup:@"Uh oh! We don't have access to your camera roll"
         message:@"You need to change this in your phone settings"
         handler:^void (UIAlertAction *action) {
         }
      ];
      [captureConfirmationView.switchView setOn:NO animated:YES];
   }
}



#pragma mark - AVCapture methods
- (void)setupCapture;
{
   // NSError *error = nil;
   // [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
   // if(!error) {
   //     [[AVAudioSession sharedInstance] setActive:YES error:&error];
   //     if(error) NSLog(@"Error while activating AudioSession : %@", error);
   // }
   // else {
   //     NSLog(@"Error while setting category of AudioSession : %@", error);
   // }

   // Create the capture session
      _captureSession = [[AVCaptureSession alloc] init];
   // Configure the inputs
      _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
      if (_videoDevice == nil) {
         exitRequested = YES;
         exitError = @"Your device doesn't have a supported camera";
      }
      else {
         _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:nil];
         [self configureDevice:_videoDevice];
         
         //AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
         //_audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];

      // Create and Configure the photo capture object
         _avObject = [[AVCapturePhotoOutput alloc] init];
         _avSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{
                          AVVideoCodecKey:@"jpeg",
                          AVVideoCompressionPropertiesKey:
                             @{AVVideoQualityKey:[NSNumber numberWithFloat:0.8]}}];

      // Configure the capture session by adding the camera input and the capture output
         [self.captureSession beginConfiguration];
         [_captureSession addInput:_videoInput];
         //[_captureSession addInput:self.audioInput];
         [_captureSession addOutput:_avObject];
         [_captureSession commitConfiguration];

      // Live Capture Preview
         previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
         //previewLayer.frame = screenRect;
         previewLayer.frame = CGRectMake(0,0,screenWidth, screenHeight);;
         [self.view.layer addSublayer:previewLayer];

      [_captureSession startRunning];
      }
}

- (void)configureDevice:(AVCaptureDevice *)device;
{
   [device lockForConfiguration:nil];
   if (device.lowLightBoostSupported)
      device.automaticallyEnablesLowLightBoostWhenAvailable = YES;
   if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
      device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
   if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
      device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
   [device unlockForConfiguration];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position)
            return device;
    }
    return nil;
}


- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput
  didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer
  previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer
  resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
  bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings
  error:(nullable NSError *)error;
{
   [self flashScreen];
   if (error) {
        NSLog(@"error : %@", error.localizedDescription);
    }
    if (photoSampleBuffer) {
       _avSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{
                        AVVideoCodecKey:@"jpeg",
                        AVVideoCompressionPropertiesKey:
                           @{AVVideoQualityKey:[NSNumber numberWithFloat:0.8]}}];
       imageData = [AVCapturePhotoOutput
          JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer
          previewPhotoSampleBuffer:previewPhotoSampleBuffer];
       //confirm capture
         UIImage *image = [UIImage imageWithData:imageData];
         [self setCapturePreview:image];
         [self showCaptureConfirmationView:image];
    }
}



#pragma mark - TextView Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
   if ([captureConfirmationView.caption.text isEqualToString:@"caption"]) {
      captureConfirmationView.caption.text = @"";
      captureConfirmationView.caption.textColor = [UIColor blackColor];
   }
   return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
   return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
   [captureConfirmationView.caption resignFirstResponder];
   if ([captureConfirmationView.caption.text isEqualToString:@""]) {
      [self resetTextView];
   }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text 
{
   if (([textView.text length] == 0) && ([text length] == 0)) {
      if (isDoubleBackspace) {
         [captureConfirmationView.caption resignFirstResponder];
         isDoubleBackspace = NO;
      }
      else {
         isDoubleBackspace = YES;
      }
   }
   return YES;
}


- (void)textViewDidChange:(UITextView *)textView {}

- (void)resetTextView;
{
    captureConfirmationView.caption.textColor = [UIColor lightGrayColor];
    captureConfirmationView.caption.text = @"caption";
    [captureConfirmationView.caption resignFirstResponder];
}

#pragma mark - keyboard

- (void)keyboardWillShow:(NSNotification *)notification 
{
   float y = ((screenHeight 
            - [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height) 
            - captureConfirmationView.frame.size.height)/2;
   [ViewUtilities setY:y forView:captureConfirmationView];
}
- (void)keyboardWasShown:(NSNotification *)aNotification 
{
}
- (void)keyboardWillHide:(NSNotification *)aNotification 
{
   captureConfirmationView.center = self.view.center;
}


#pragma mark - collectionView

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
   return [cameraRollAssets count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
   NSString *identifier = @"cell";
   CameraRollCollectionViewCell *cell = (CameraRollCollectionViewCell*) [collectionView
      dequeueReusableCellWithReuseIdentifier:identifier
      forIndexPath:indexPath];
   if (cell == nil) {
      cell = [[CameraRollCollectionViewCell alloc] initWithFrame:CGRectMake(0,0,48,48)];
   }
   [[PHImageManager defaultManager] requestImageForAsset:
      [cameraRollAssets objectAtIndex:([cameraRollAssets count] - indexPath.row - 1)]
      targetSize:CGSizeMake(48,48)
      contentMode:PHImageContentModeAspectFill
      options:requestOptions
      resultHandler:^void(UIImage *image, NSDictionary *info) {
         [cell setImageFromImage:image];
      }
   ];
   return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   [[PHImageManager defaultManager] requestImageForAsset:[cameraRollAssets objectAtIndex:([cameraRollAssets count] - indexPath.row - 1)]
      targetSize:CGSizeMake(screenWidth,screenHeight)
      contentMode:PHImageContentModeAspectFill
      options:requestOptions
      resultHandler:^void(UIImage *image, NSDictionary *info) {
         imageData = UIImageJPEGRepresentation(image, 1.0);
         [self setCapturePreview:image];
         [self showCaptureConfirmationView:image];
      }
   ];
}

#pragma mark - motion, observer, and gesture functions
- (void)registerObservers;
{
   [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];

   //AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
   int flags = NSKeyValueObservingOptionNew; 
   [_videoDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
   [_avObject addObserver:self forKeyPath:@"isFlashScene" options:flags context:nil];
}

- (void)removeObservers;
{
   [[NSNotificationCenter defaultCenter] removeObserver:self 
      name:UIDeviceOrientationDidChangeNotification
      object:nil];
   AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
   [camDevice removeObserver:self forKeyPath:@"adjustingFocus"];
}

- (void)setupMotionManager;
{
   motionQueue = [[NSOperationQueue alloc] init];
   CMDeviceMotionHandler motionHandler = ^(CMDeviceMotion *motion, NSError *error) {
      if (leveler.alpha > 0.0f) {
         double gravityX =  motionManager.deviceMotion.gravity.x;
         double gravityY =  motionManager.deviceMotion.gravity.y;
         double rotation = atan2(gravityX, gravityY) - M_PI;
         float margin = 0.005;
         //[self setLog:[NSString stringWithFormat:@"%f", rotation]];
         dispatch_async(dispatch_get_main_queue(), ^{
            leveler.transform = CGAffineTransformMakeRotation(rotation); 
            if (rotation > margin || rotation < -2*M_PI + margin ||
               (rotation < (-1)*M_PI_2 + margin && rotation > (-1)*M_PI_2 - margin) ||
               (rotation < (-3)*M_PI_2 + margin && rotation > (-3)*M_PI_2 - margin)) {
               [self setLevelerColor:[UIColor greenColor]];
            }
            else {
               [self setLevelerColor:themeColor];
            }
         });
      }
   };
   motionManager = [[CMMotionManager alloc] init];
   if (motionManager.deviceMotionAvailable) {
      motionManager.deviceMotionUpdateInterval = 1/50;
      //motionManager.startDeviceMotionUpdates;
      [motionManager startDeviceMotionUpdatesToQueue:motionQueue
         withHandler:motionHandler];
   }
}

- (void)setupTouchLayer;
{
   UITapGestureRecognizer *singleFingerTap = 
     [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
   singleFingerTap.cancelsTouchesInView = NO;
   [self.view addGestureRecognizer:singleFingerTap];
   // UIPanGestureRecognizer *pan = 
   //   [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
   // [self.view addGestureRecognizer:pan];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"adjustingFocus"] ){
       if (focusBox.alpha > 0.0) {
          BOOL adjustingFocus = [ [change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
          //[self setLog:[NSString stringWithFormat:@"Is adjusting focus? %@", adjustingFocus ? @"YES" : @"NO" ]];
          focusBox.alpha = 0.8;
          if (adjustingFocus){
             [focusBox setColor:themeColor];
             [ViewUtilities flashView:focusBox];
          }
          else {
             [focusBox setColor:[UIColor greenColor]];
             [self removeFocusBox];
          }
       }
    }
    if([keyPath isEqualToString:@"isFlashScene"] ){
       if (flashButton.alpha != 0) {
          [ViewUtilities flashView:flashButton];
       }
    }
}


- (void)orientationChanged:(NSNotification *)notif 
{
   [self setOrientation];
}

- (void)setOrientation;
{
   UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
   //[self setLog:[NSString stringWithFormat:@"orientation: %d", deviceOrientation]];

   BOOL transform = YES;
   CGFloat angle = -1;
   AVCaptureConnection *connection = _avObject.connections[0];
   switch (deviceOrientation) {
       case UIDeviceOrientationLandscapeLeft:
           connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
           angle = M_PI_2;
           lastOrientation = deviceOrientation;
           break;
       case UIDeviceOrientationLandscapeRight:
           connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
           angle = - M_PI_2;
           lastOrientation = deviceOrientation;
           break;
       case UIDeviceOrientationPortrait:
           connection.videoOrientation = AVCaptureVideoOrientationPortrait;
           angle = 0;
           lastOrientation = deviceOrientation;
           break;
       case UIDeviceOrientationPortraitUpsideDown:
           connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
           angle = M_PI;
           lastOrientation = deviceOrientation;
           break;
       default:
           transform = NO;
           break;
   }
   if (transform) {
      [UIView animateWithDuration:.3
          animations:^{
             onScreenLog.transform = CGAffineTransformMakeRotation(angle);
             for (UIView *view in rotationArray) {
                view.transform = CGAffineTransformMakeRotation(angle);
             }
             // flashButton.transform = CGAffineTransformMakeRotation(angle);
             // switchCameraButton.transform = CGAffineTransformMakeRotation(angle);
          }
          completion:^(BOOL finished) {
         }
      ];
   }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer;
{
   CGPoint location = [recognizer locationInView:[recognizer.view superview]];
   CGPoint focusPoint = [previewLayer captureDevicePointOfInterestForPoint:location];
   // [self setLog:[NSString stringWithFormat:@"tapped: {%d,%d}", (int)location.y, (int)cameraRoll.frame.origin.y]];

   BOOL shouldSetFocus = YES;
   if (CGRectContainsPoint(cameraRoll.frame, location))
      shouldSetFocus = NO;
   if (captureConfirmationView.alpha == 1.0f) {
      shouldSetFocus = NO;
      [captureConfirmationView.caption resignFirstResponder];
      if (!CGRectContainsPoint(captureConfirmationView.frame, location))
         [self previewButtonClicked];
   }
   for (UIView *view in rotationArray) {
      if (CGRectContainsPoint(view.frame, location))
         shouldSetFocus = NO;
   }
   if (shouldSetFocus) {
      AVCaptureDevice *device = [[self videoInput] device];
      //if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
      if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
          NSError *error;
          if ([device lockForConfiguration:&error]) {
              [device setFocusPointOfInterest:focusPoint];
              [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
              [device unlockForConfiguration];
              [self showFocusBox:location];
          }
      }
      if ([device isExposurePointOfInterestSupported] && 
          [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
          NSError *error;
          if ([device lockForConfiguration:&error]) {
              [device setExposurePointOfInterest:focusPoint];
              [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
              //[device setExposureMode:AVCaptureExposureModeAutoExpose];
              [device unlockForConfiguration];
          }
      }
   }
}


// - (void)handlePan:(UIPanGestureRecognizer *)recognizer;
// {
//    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
//    if (CGPointEqualToPoint(lastPoint,CGPointMake(0,0))){
//       lastPoint = location;
//    }
//    CGFloat radians = atan2f(imageView.transform.b, imageView.transform.a); 
//    //CGFloat degrees = radians * (180 / M_PI);
//    CGFloat change = 0;
//    BOOL isReversed = NO;
// 
//    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
//    if (deviceOrientation != lastOrientation)
//       deviceOrientation = lastOrientation;
//    switch (deviceOrientation) {
//        case UIDeviceOrientationLandscapeLeft:
//           change = lastPoint.x - location.x;
//           if (lastPoint.y < screenHeight/2)
//              isReversed = YES;
//           break;
//        case UIDeviceOrientationLandscapeRight:
//           change =  location.x - lastPoint.x;
//           if (lastPoint.y > screenHeight/2)
//              isReversed = YES;
//           break;
//        case UIDeviceOrientationPortrait:
//           change = location.y - lastPoint.y;
//           if (lastPoint.x < screenWidth/2)
//              isReversed = YES;
//           break;
//        case UIDeviceOrientationPortraitUpsideDown:
//           change = lastPoint.y - location.y;
//           if (lastPoint.x > screenWidth/2)
//              isReversed = YES;
//           break;
//        default:
//           break;
//    }
//    if (isReversed)
//       change = (-1)*change;
//    
//    imageView.transform = CGAffineTransformMakeRotation(radians+change/100); 
//    if (recognizer.state == UIGestureRecognizerStateEnded) {
//       lastPoint = CGPointMake(0,0);
//    }
//    else {
//       lastPoint = location;
//    }
// }

// - (double)magnitudeFromAttitude:(CMAttitude *)attitude {
//     return sqrt(pow(attitude.roll, 2.0f) + pow(attitude.yaw, 2.0f) + pow(attitude.pitch, 2.0f));
// }

#pragma mark - log

// - (void)setupLog;
// {
//    onScreenLog = [[UITextView alloc] init];
//    onScreenLog.frame = screenRect;
//    onScreenLog.backgroundColor = [UIColor clearColor];
//    onScreenLog.textAlignment = NSTextAlignmentLeft;
//    onScreenLog.textColor = [UIColor whiteColor];
//    onScreenLog.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
//    onScreenLog.text = @"";
//    onScreenLog.editable = NO;
//    onScreenLog.userInteractionEnabled = NO;
//    //onScreenLog.scrollEnabled = NO;
//    //onScreenLog.delegate = self;
//    [self.view addSubview:onScreenLog];
// }
// - (void)setLog:(NSString *)text;
// {
//    dispatch_async(dispatch_get_main_queue(), ^{
//       onScreenLog.text = [NSString stringWithFormat:@"%@\r\n%@", onScreenLog.text, text];
//       if(onScreenLog.text.length > 0 ) {
//            NSRange bottom = NSMakeRange(onScreenLog.text.length -1, 1);
//            [onScreenLog scrollRangeToVisible:bottom];
//       }
//    });
// }
// 
#pragma mark - unused/old code
// - (void)setupOptionsPanel;
// {
//    optionsPanel = [[UIView alloc] init];
//    optionsPanel.frame = CGRectMake(0,0,60,60);
//    optionsPanel.backgroundColor = [UIColor blackColor];
//    optionsPanel.layer.cornerRadius = 30;
//    optionsPanel.layer.masksToBounds = YES;
//    optionsPanel.center = captureButton.center;
//    optionsPanel.alpha = 0;
//    [ViewUtilities setX:10 forView:optionsPanel];
//    [self.view addSubview:optionsPanel];
// 
//    optionsButton = [[UIButton alloc] init];
//    optionsButton.frame = CGRectMake(0,0,50,50);
//    [optionsButton addTarget:self action:@selector(toggleOptionsPanel) forControlEvents:UIControlEventTouchUpInside];
//    optionsButton.backgroundColor =[UIColor clearColor];
// 
//      int size = optionsButton.frame.size.width;
//      UIImage *image = [[UIImage imageNamed:@"settingsIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//      UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//      imageView.frame = CGRectMake(0, 0, size, size);
//      imageView.contentMode = UIViewContentModeScaleAspectFill;
// 
//    [optionsButton addSubview:imageView];
//    [optionsButton setTintColor:[UIColor whiteColor]];
//    optionsButton.alpha = defaultButtonAlpha;
//    optionsButton.center = optionsPanel.center;
//    [self.view addSubview:optionsButton];
//    [rotationArray addObject:optionsButton];
// }

// - (void)toggleOptionsPanel;
// {
//    if (optionsPanel.alpha == 0) {
//       [UIView animateWithDuration:0.2
//          delay:0.0
//          options: UIViewAnimationOptionCurveEaseOut
//          animations:^{ 
//             optionsPanel.alpha = 0.2;
//             [ViewUtilities setHeight:200 forView:optionsPanel];
//             [ViewUtilities setY:optionsPanel.frame.origin.y - (200-60) forView:optionsPanel];
//             //flashButton
//                flashButton.alpha = defaultButtonAlpha;
//                [ViewUtilities setY:optionsButton.frame.origin.y - 40 forView:flashButton];
//             //levelButton
//                levelButton.alpha = defaultButtonAlpha;
//                [ViewUtilities setY:optionsButton.frame.origin.y - 80 forView:levelButton];
//          } 
//          completion:^(BOOL finished){
//          }
//       ];
//    }
//    else {
//       [UIView animateWithDuration:0.2
//          delay:0.0
//          options: UIViewAnimationOptionCurveEaseOut
//          animations:^{ 
//             optionsPanel.alpha = 0.0;
//             [ViewUtilities setHeight:60 forView:optionsPanel];
//             [ViewUtilities setY:optionsPanel.frame.origin.y + (200 - 60) forView:optionsPanel];
//             //flashButton
//                flashButton.alpha = 0.0;
//                flashButton.center = optionsButton.center;
//             //levelButton
//                levelButton.alpha = 0.0;
//                levelButton.center = optionsButton.center;
//          } 
//          completion:^(BOOL finished){
//          }
//       ];
//    }
// }


// - (void)setupLevelButton;
// {
//    levelButton = [[UIButton alloc] init];
//    levelButton.frame = CGRectMake(0,0,50,50);
//    [levelButton addTarget:self action:@selector(toggleLevel) forControlEvents:UIControlEventTouchUpInside];
//    levelButton.backgroundColor =[UIColor clearColor];
// 
//      int size = levelButton.frame.size.width;
//      UIImage *image = [[UIImage imageNamed:@"settingsIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//      UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//      imageView.frame = CGRectMake(0, 0, size, size);
//      imageView.contentMode = UIViewContentModeScaleAspectFill;
// 
//    [levelButton addSubview:imageView];
//    [levelButton setTintColor:[UIColor whiteColor]];
//    levelButton.alpha = 0.0;
//    levelButton.center = optionsPanel.center;
//    [self.view addSubview:levelButton];
//    [rotationArray addObject:levelButton];
// }

// - (void)toggleLevel;
// {
//    if (motionManager == nil) {
//       [self setupMotionManager];
//    }
//    if (motionManager) {
//       if (imageView.alpha == 0) {
//          [ViewUtilities fadeView:imageView toAlpha:0.6];
//       }
//       else {
//          [ViewUtilities fadeView:imageView toAlpha:0.0];
//       }
//    }
// }

// - (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
// {
//    if ([textField.text length] == 0)
//       textField.text = @"#";
//    return YES;
// }
// 
// 
// - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
// {
//    BOOL canEdit=NO;
//    NSCharacterSet *myCharSet = [NSCharacterSet alphanumericCharacterSet];
//    for (int i = 0; i < [string length]; i++) {
//        unichar c = [string characterAtIndex:i];
//        if (![myCharSet characterIsMember:c]) {
//            return NO;
//        }
//    }
//    NSUInteger newLength = [textField.text length] + [string length] - range.length;
//    if (newLength > 0) {
//        for (int i = 0; i < [string length]; i++) {
//            unichar c = [string characterAtIndex:i];
//            if (![myCharSet characterIsMember:c]) {
//                canEdit=NO;
//            }
//            else {
//                canEdit=YES;
//            }
//        }
//    }
//    if ([textField.text length] == 0) {
//       textField.text = @"#";
//    }
//    return (newLength > 50 && canEdit) ? NO : YES;
// }
// 
// - (BOOL)textFieldShouldClear:(UITextField *)textField;
// {
//       [self.view endEditing:YES];
//       return YES;
// }
// - (BOOL)textFieldShouldReturn:(UITextField *)textField;
// {
//       [self.view endEditing:YES];
//       return YES;
// }
@end
