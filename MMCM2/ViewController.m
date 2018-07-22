//
//  ViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 7/8/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "ViewController.h"

// Connected View Controllers
   #import "SignInViewController.h"
   //#import "ProfileViewController.h"
   #import "RootTabBarViewController.h"
   #import "InviteViewController.h"
   #import "WelcomeViewController.h"

// Other Imports
   #import "AWSTaskObjectHandler.h"
// TEMP
   #import "NameViewController.h"

@interface ViewController ()
@end

@implementation ViewController
static NSDictionary *FBProfileData;
static NSArray *FBFriendData;
static int state = 0;

static BOOL bypass = NO;

static UIActivityIndicatorView *spinner;

- (BOOL)showNextButton;
{
   return NO;
}

- (NSString *)footerText;
{
   return @"loading...";
}


- (void)viewDidLoad 
{
   [super viewDidLoad];
   [server checkInternet];
}


- (void)viewDidAppear:(BOOL)animated 
{
   //XXX TEMP TEMP TEMP
   if (bypass) {
      [self loadRootTabBarController:2];
   }
   else {
   //pause here...then continue (splash)
   if (state == 0){
      [NSTimer scheduledTimerWithTimeInterval:0
               target:self
               selector:@selector(endSplash)
               //selector:@selector(temp)
               userInfo:nil
               repeats:NO];
   }
   else if (state == 1) {
      // Registration has been dismissed so we should go to the profile screen
      [self loadRootTabBarController:2];
   }
   }
}

- (void)loadRootTabBarController:(int)index;
{
   // XXX XXX XXX
      index = 2;
   // XXX XXX XXX
   dispatch_async(dispatch_get_main_queue(), ^{
       UITabBarController *viewController = [[RootTabBarViewController alloc] init];
       [viewController setSelectedIndex:index];
       [self presentViewController:viewController animated:YES completion:nil];
   });
}


- (void)endSplash;
{
   if (![server hasFBCredentials]) {
      UIViewController *viewController = [[SignInViewController alloc] init];
      [self presentViewController:viewController animated:NO completion:nil];
   } else {
      [server preCheck];

      [self setupSpinner];

      [server retrieveFBProfileData:^void (NSDictionary *result) {
         FBProfileData = [NSDictionary dictionaryWithDictionary:result];
         [server retrieveFBFriendData:^void (NSArray *result) {
            FBFriendData = [NSArray arrayWithArray:result];
            [self finishLoading];
         }];
      }];
   }
}


- (void)finishLoading;
{
   [server initAWSCognito:^void(NSNumber *userHasRegisteredWithAWS) {
      if ([userHasRegisteredWithAWS intValue] == 1) {
         [self login];
      }
      else {
         [self registerUser];
      }
   }];
}


- (void)setupSpinner;
{
   spinner = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(0,0,50,50)];
   spinner.center = self.view.center;
   [ViewUtilities setY:CGRectGetMaxY(self.footerLabel.frame) + 10 forView:spinner];
   spinner.color = [UIColor blackColor];
   [spinner startAnimating];
   [self.view addSubview:spinner];
}


- (void)login;
{
   [server loginWithNewUserFlag:NO completionBlock:^(id result){
      // i'm not entirely new but i may not have been invited or i may not have finished
      // registration so...check to see if they can get through or not...
      //[global setMyUserData:result];
      myUserData = [[MyUserData alloc] initWithDictionary:result];
      //myUserData = [NSMutableDictionary dictionaryWithDictionary:result];
      //AWSTaskObjectHandler *task = [[AWSTaskObjectHandler alloc] initWithDictionary:result];
      if ([[result objectForKey:@"registrationAccepted"] intValue] == 1) {
         //send users straight to feed
         [self loadRootTabBarController:0];
         //[myFriendList updateWithUserID:[myUserData objectForKey:@"userID"]];
         myGroupList = [[GroupList alloc] init];
         myFriendList = [[FriendList alloc] initWithUserID:myUserData.userID];
      }
      else {
         //so registration isn't accepted which means...
         //check to see if they have finished registration
         //check to see current registration restrictions
            [self loadRegistrationNav:[[NameViewController alloc] init]];
      }
   }];
}


- (void)registerUser;
{
   [server loginWithNewUserFlag:YES completionBlock:^(id result){
      [server saveFBProfileDataToAWS:FBProfileData completionBlock:^(id result) {
          //[global setMyUserData:result];
         //myUserData = [NSMutableDictionary dictionaryWithDictionary:result];
         myUserData = [[MyUserData alloc] initWithDictionary:result];
         myGroupList = [[GroupList alloc] init];
         myFriendList = [[FriendList alloc] initWithUserID:myUserData.userID];
      }];
      //send user to registration process
         [self loadRegistrationNav:[[WelcomeViewController alloc] init]];
   }];
}

- (void)loadRegistrationNav:(UIViewController *)viewController;
{
   dispatch_async(dispatch_get_main_queue(), ^{
      UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
      [navController setNavigationBarHidden:YES animated:NO];
      //[self presentViewController:navController animated:NO completion:nil];
      [self presentViewController:navController animated:NO completion:^{
         self.footerLabel.alpha = 0;
         spinner.alpha = 0;
         }];
      state = 1;
   });
}
- (void)presentNextViewController:(BOOL)isNewUser;
{
   // XXX TEMP TEMP TEMP
      dispatch_async(dispatch_get_main_queue(), ^{
   //UIViewController *viewController = [[NameViewController alloc] initWithHeader:@"Preferences"];
   UIViewController *viewController = [[NameViewController alloc] init];
   [self presentViewController:viewController animated:NO completion:nil];
          // UIViewController *viewController = [[RegistrationViewController alloc] initWithHeader:@"Preferences"];
          // [self presentViewController:viewController animated:NO completion:nil];
      // UIViewController *viewController = [[FriendsListViewController alloc] init];
      // [self presentViewController:viewController animated:NO completion:nil];
      });
/*

   [server saveFBFriendDataToAWS:FBFriendData isNewUser:isNewUser withCompletionBlock:^void (NSNumber *friendCount) { 
      if ([friendCount intValue] < 5) {
         if (isNewUser) {

         NSLog(@"isNewUser");
          dispatch_async(dispatch_get_main_queue(), ^{
             UIViewController *viewController = [[WelcomeViewController alloc] init:friendCount];
             [self presentViewController:viewController animated:NO completion:nil];
          });
         }
         else {
         NSLog(@"is NOT a new User");
          dispatch_async(dispatch_get_main_queue(), ^{
             UIViewController *viewController = [[InviteViewController alloc] init:friendCount];
             [self presentViewController:viewController animated:NO completion:nil];
          });
         }
      }
      else {
         // if first time getting into the app (might not be a new user)
         //    take to profile page
         // else
            NSLog(@"I should be showing feedViewController");
         //presentViewController inviteScreenWithFriendCount
      }
   }];
*/
}


@end
