//
//  SignInViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 7/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "SignInViewController.h"

// Frameworks
   #import <AWSCore/AWSCore.h>
   #import <AWSMobileHubHelper/AWSMobileHubHelper.h>
   #import <FBSDKCoreKit/FBSDKAccessToken.h>

@interface SignInViewController ()
@end

@implementation SignInViewController
FBSDKLoginButton *loginButton;

- (NSString *)footerText;
{
   return @"Match Me Catch Me requires a Facebook Login";
}

- (BOOL)showNextButton;
{
   return NO;
}

- (void)setupViews;
{
   [super setupViews];
   self.footerLabel.alpha = 0.0f;
   self.button.alpha = 0.0f;
   loginButton.alpha = 0.0f;
   [self setupLoginButton];
}

- (void)viewDidAppear:(BOOL)animated 
{
   [UIView animateWithDuration:2.0f
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         self.footerLabel.alpha = 1.0f;
         loginButton.alpha = 1.0f;
      } 
      completion:^(BOOL finished){
      }
   ];
}

- (void)setupLoginButton;
{
   loginButton = [[FBSDKLoginButton alloc] init];
   loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
   [loginButton setDelegate:self];
   loginButton.center = self.view.center;
   [ViewUtilities setY:(screenHeight - loginButton.frame.size.height - 50) forView:loginButton];
   [self.view addSubview:loginButton];
}


- (void) loginButton:(FBSDKLoginButton *)loginButton
         didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
         error:(NSError *)error;
{
   NSLog(@"FBLogin result: %@", result);
   NSLog(@"FBLogin error: %@", error);
   if (!error) {

      [self dismissViewControllerAnimated:NO completion:^{
      }];
   }
}


- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton;
{
   // Maybe show some kind of popup?
}


@end
