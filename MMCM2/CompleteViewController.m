//
//  CompleteViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "CompleteViewController.h"

@interface CompleteViewController ()

@end

@implementation CompleteViewController
static UIImageView *imageView;
static UIView *mainPanel;
static UILabel *label1;
static UILabel *codeLabel;
static UILabel *label2;

- (NSString *)headerText;
{
   return @"Profile Complete!";
}

- (NSString *)nextButtonText;
{
   return @"done";
}

- (void)setupViews;
{
   [super setupViews];
   [self setupMainPanel];
   [self setupImage];
   [self setupLabel1];
   [self setupCodeLabel];
   [self setupLabel2];
   CGSize size = CGSizeMake(screenWidth, CGRectGetMaxY(label2.frame) - imageView.frame.origin.x);
   int y = (screenHeight - (size.height + headerHeight + buttonHeight)) / 3;
   mainPanel.frame = CGRectMake(0,y,size.width, size.height);
}

- (void)setupMainPanel;
{
   mainPanel = [[UIView alloc] init];
   mainPanel.backgroundColor = [UIColor whiteColor];
   [self.view addSubview:mainPanel];
}

- (void)setupImage;
{
   imageView = [[UIImageView alloc] init];
   imageView.contentMode = UIViewContentModeScaleAspectFit;
   CGRect rect = { {0,0}, [self imageSize] };
   imageView.frame = rect;
   imageView.center = self.view.center;
   imageView.image = [UIImage imageNamed:[self imageName]];
   [ViewUtilities setY:0 forView:imageView];
   [mainPanel addSubview:imageView];
}

- (NSString *)imageName;
{
   return @"LogoNoText";
}

- (CGSize)imageSize;
{
   return CGSizeMake(100,68);
}

- (void)setupLabel1;
{
   UIFont *font = [UIFont systemFontOfSize: 15 weight:UIFontWeightMedium];
   label1 = [self newLabel:@"Your personal invite code is:" font:font];
   [ViewUtilities setY:CGRectGetMaxY(imageView.frame) + 36 forView:label1];
}
- (void)setupCodeLabel;
{
   UIFont *font = [UIFont systemFontOfSize: 28 weight:UIFontWeightSemibold];
   codeLabel = [self newLabel:myUserData.inviteCode font:font];
   //codeLabel = [self newLabel:[myUserData objectForKey:@"inviteCode"] font:font];
   [ViewUtilities setY:CGRectGetMaxY(label1.frame) + 33 forView:codeLabel];
}
- (void)setupLabel2;
{
   NSString *text = @"share this code with any of your friends so that they can sign up and be added to your friend's list automatically";
   UIFont *font = [UIFont systemFontOfSize: 15 weight:UIFontWeightRegular];
   label2 = [self newLabel:text font:font];
   [ViewUtilities setY:CGRectGetMaxY(codeLabel.frame) + 33 forView:label2];
   label2.textColor = [UIColor colorWithRed:(155/255.0) green:(155/255.0) blue:(155/255.0) alpha: 1.0];
}

- (UILabel *)newLabel:(NSString *)text font:(UIFont *)font;
{
   UILabel *label = [[UILabel alloc] init];
   label.textColor = [UIColor blackColor];
   label.numberOfLines = 0;
   label.textAlignment = NSTextAlignmentCenter;

   label.text = text;
   label.font = font;

   CGSize size = [label sizeThatFits:CGSizeMake(300, CGFLOAT_MAX)];
   [ViewUtilities setSize:size forView:label];
   label.center = self.view.center;
   [mainPanel addSubview:label];
   return label;
}

- (void)next;
{
   //[myGroupData updateGroupData:nil];
   [myFriendList update];
   [self dismissViewControllerAnimated:NO completion:nil];
}
@end
