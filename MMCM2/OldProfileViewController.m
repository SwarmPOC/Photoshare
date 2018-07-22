//
//  ProfileViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 7/13/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "OldProfileViewController.h"

// Common
   #import "Global.h"
   #import "ViewUtilities.h"

// Frameworks
   #import <FBSDKCoreKit/FBSDKAccessToken.h>
   #import <FBSDKCoreKit/FBSDKGraphRequest.h>
   #import <AWSS3/AWSS3.h>
   #import <AWSS3/AWSS3TransferManager.h>
   #import <AWSCore/AWSCore.h>
   #import <AWSCognito/AWSCognito.h>

// local
   #import "MMCMIdentityProvider.h"

@interface OldProfileViewController ()

@end


@implementation OldProfileViewController

// Controls
   static UIScrollView *scrollView;
   static UIView *photoFrame;
   static NSMutableArray *photoArray;
   static UIImageView *imageView;

// Var
   static NSString *fbProfileName;
   static NSData *fbProfilePic;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self loadFBProfileData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)loadFBProfileData;
{
   if ([FBSDKAccessToken currentAccessToken]) {
      [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
         parameters:@{ @"fields" : @"id,name,picture.width(100).height(100)"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
               fbProfileName = [result valueForKey:@"name"];
               NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
               dispatch_async(dispatch_get_global_queue(0,0), ^{
                   NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:imageStringOfLoginUser]];
                   if ( data == nil ) { return; }
                   dispatch_async(dispatch_get_main_queue(), ^{
                       imageView.image =  [UIImage imageWithData: data];
                   });
               });
            }
         }
      ];
   }
}


- (void)setupViews;
{
   [self setupScrollView];
      [self setupPhotoFrame];
   // [self setupBioFrame];
   // [self setupFriendBioFrame];
   // [self setupGamesFrame];
   [self setupTEMP];
}


- (void)updateViews;
{
}


- (void)updateScrollView;
{
   //resize scrollView according to the number of containers that exist
}


- (void)setupScrollView;
{
   scrollView = [[UIScrollView alloc] init];

   // NOTE: may need to adjust this for tab menue
      scrollView.frame = screenRect;
   //

   scrollView.delegate = self;
   scrollView.backgroundColor = [UIColor whiteColor];
   [self.view addSubview:scrollView];
}


- (void)setupPhotoFrame;
{
   photoFrame = [[UIView alloc] init];
   // NOTE: height needs to be adjusted
      photoFrame.frame = CGRectMake(0,0, screenWidth, screenHeight/3);
   imageView = [[UIImageView alloc] init];
   imageView.frame = CGRectMake(0,0,100,100);
   imageView.center = photoFrame.center;
   //imageView.contentMode = UIViewContentModeScaleAspectFill;
   // rounding
      CALayer *l = [imageView layer];
      [l setMasksToBounds:YES];
      [l setCornerRadius:10.0];
   [photoFrame addSubview:imageView];
   [scrollView addSubview:photoFrame];
}


- (void)setupBioFrame;
{
   NSInteger y = CGRectGetMaxY(photoFrame.frame);
   //CGRectGetMinX(view.frame)
}


- (void)setupTEMP;
{
   UIButton *button = [[UIButton alloc] init];
   [button setTitle:@"add pic" forState:UIControlStateNormal];
   [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
   [button addTarget:self action:@selector(addProfilePicture) forControlEvents:UIControlEventTouchUpInside];
   [button sizeToFit];
   [ViewUtilities setXY:CGPointMake(20, screenHeight - 100) forView:button];
   [self.view addSubview:button];


   UIButton *button2 = [[UIButton alloc] init];
   [button2 setTitle:@"upload" forState:UIControlStateNormal];
   [button2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
   [button2 addTarget:self action:@selector(uploadToS3) forControlEvents:UIControlEventTouchUpInside];
   [button2 sizeToFit];
   [ViewUtilities setXY:CGPointMake(20, screenHeight - 50) forView:button2];
   [scrollView addSubview:button2];
}


- (void)retrieveProfilePhotos;
{
   photoArray = [[NSMutableArray alloc] init];
}


- (void)addProfilePicture;
{
   NSLog(@"hit");
   //launch picture selelction
   //
}


- (void)uploadProfilePicture;
{
}


- (CGSize)getImageSize:(UIImage *)image;
{
   //int defaultWidth = self.appState.screenWidth*3/5;
   int defaultWidth = screenWidth*3/5;
   float factor;
   CGSize size = image.size;
   if (size.width < defaultWidth)
      return size;
   factor = defaultWidth/size.width;
   return CGSizeMake(defaultWidth, factor*size.height);
}




- (void)uploadToS3
{


   AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
//image you want to upload
UIImage* imageToUpload = imageView.image;

//convert uiimage to 
NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", dateKey]];
NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"test.png"]];
[UIImagePNGRepresentation(imageToUpload) writeToFile:filePath atomically:YES];

NSURL* fileUrl = [NSURL fileURLWithPath:filePath];

NSString *bucketName;
bucketName = @"com.matchmecatchme.user";
//bucketName = @"mmcm-userfiles-mobilehub-804182031";
//upload the image
AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
uploadRequest.body = fileUrl;
uploadRequest.bucket = bucketName;
uploadRequest.key = @"test1/test2/image2.png";
uploadRequest.contentType = @"image/png";

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
           } else {
               // Unknown error.
               NSLog(@"Error: %@", task.error);
           }
       }

       if (task.result) {
           AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
           // The file uploaded successfully.
       }
       return nil;
   }];


}

- (void)downloadFromS3
{
}




@end
