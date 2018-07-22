//
//  CameraViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 12/21/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "CommonViewController.h"

@interface CameraViewController : CommonViewController 
   <AVCapturePhotoCaptureDelegate,
   // UITextViewDelegate,
   UITextFieldDelegate,
   UICollectionViewDelegate,
   UICollectionViewDataSource>
@property (strong, nonatomic) AVCapturePhotoOutput *avObject;
@property (strong, nonatomic) AVCapturePhotoSettings *avSettings;
@property (strong, nonatomic) AVCaptureSession* captureSession;
@property (strong, nonatomic) AVCaptureDeviceInput* videoInput;
@property (strong, nonatomic) AVCaptureDeviceInput* audioInput;
@property (strong, nonatomic) AVCaptureDevice *videoDevice;
@property (strong, nonatomic) UIViewController *delegate;

- (id)init:(id)Delegate;
//- (void)setSelected:(NSArray *)array userDict:(NSDictionary *)dictionary;
- (void)setSelected:(NSArray *)array;
@end
