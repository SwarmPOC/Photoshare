//
//  BaseInformationalViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/11/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "BaseInformationalViewController.h"

@interface BaseInformationalViewController ()

@end

@implementation BaseInformationalViewController
static UIImageView *imageView;

- (void)setupViews;
{
   [super setupViews];
   [self setupImageView];
   [self setupFooterLabel];
}

- (BOOL)showHeader;
{
   return NO;
}

- (void)setupImageView;
{
   imageView = [[UIImageView alloc] init];
   imageView.contentMode = UIViewContentModeScaleAspectFit;
   CGRect rect = { {0,0}, [self imageSize] };
   imageView.frame = rect;
   imageView.center = self.view.center;
   imageView.image = [UIImage imageNamed:[self imageName]];
   [ViewUtilities setY:(.1 * screenHeight) forView:imageView];
   [self.view addSubview:imageView];
}

- (NSString *)imageName;
{
   return @"Logo";
}

- (CGSize)imageSize;
{
   return CGSizeMake(280,280);
}

- (void)setupFooterLabel;
{
   _footerLabel = [[UILabel alloc] init];
   _footerLabel.textColor = [UIColor blackColor];
   _footerLabel.numberOfLines = 0;
   _footerLabel.textAlignment = NSTextAlignmentCenter;
   _footerLabel.font = [UIFont systemFontOfSize: 18 weight:UIFontWeightLight];

   _footerLabel.text = [self footerText];
   CGSize size = [_footerLabel sizeThatFits:CGSizeMake(260, CGFLOAT_MAX)];
   [ViewUtilities setSize:size forView:_footerLabel];
   _footerLabel.center = self.view.center;
   //int margin = (self.button.frame.origin.y - CGRectGetMaxY(imageView.frame) - _footerLabel.frame.size.height) / 2;
   [ViewUtilities setY:CGRectGetMaxY(imageView.frame) + 80 forView:_footerLabel];
   [self.view addSubview:_footerLabel];
}

- (NSString *)footerText;
{
   return @"";
}

@end
