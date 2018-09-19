//
//  BaseProfileViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 2/13/18.
//  Copyright © 2018 Shadow Prodigy. All rights reserved.
//

#import "BaseProfileViewController.h"

@interface BaseProfileViewController ()

@end

@implementation BaseProfileViewController

#pragma setup
- (void)setupVars;
{
}

- (void)setupViews;
{
   [super setupViews];
   [self setupScrollView];
}


- (void)setupScrollView;
{
   _scrollView = [[UIScrollView alloc] init];
   _scrollView.frame = screenRect;
   _scrollView.delegate = self;
   _scrollView.backgroundColor = [UIColor whiteColor];
   [self.view addSubview:_scrollView];
}


- (void)setupFeatureView;
{
   [self setupCoverPhoto];
   // [self setupShadow];
   [self setupNameLabel];
   // [self setupFeatureButton];
   // [self setupEditProfileButton];
}

- (void)setupCoverPhoto;
{
   // coverPhotoImageView = [[UIImageView alloc] init];
   // coverPhotoImageView.contentMode = UIViewContentModeScaleAspectFill;
   // CGRect rect = { {0,0}, [self imageSize] };
   // coverPhotoImageView.frame = rect;
   // coverPhotoImageView.image = [UIImage imageNamed:[self imageName]];
   // [_scrollView addSubview:coverPhotoImageView];
}
- (CGSize)imageSize;
{
   return CGSizeMake(screenWidth,screenHeight/goldenRatio);
}
- (NSString *)imageName;
{
   return @"tempImage";
}

- (void)setupNameLabel;
{
   // _nameLabel = [[UILabel alloc] init];
   // _nameLabel.frame = CGRectMake(20,CGRectGetMaxY(coverPhotoImageView.frame) - 42 ,screenWidth,26);
   // _nameLabel.textAlignment = NSTextAlignmentLeft;
   // _nameLabel.text = [self labelText];
   // _nameLabel.textColor = [UIColor whiteColor];
   // _nameLabel.numberOfLines = 1;
   // _nameLabel.font = [UIFont systemFontOfSize: 22 weight:UIFontWeightRegular];
   // [_scrollView addSubview:_nameLabel];
}
- (NSString *)labelText;
{
   return @""; 
}
@end
