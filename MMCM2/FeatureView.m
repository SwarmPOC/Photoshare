//
//  FeatureView.m
//  MMCM2
//
//  Created by Richard Montricul on 2/13/18.
//  Copyright © 2018 Shadow Prodigy. All rights reserved.
//

#import "FeatureView.h"

@implementation FeatureView
   CGSize size;
   UIImageView *imageView;


- (void)setImage:(NSString *)string;
{
   imageView.image = [UIImage imageNamed:string];
}


#pragma setup
- (id)init:(id)Delegate;
{
   self = [super init];
   [self setupVars];
   [self setupImageView];
   [self setupShadow];
   [self setupNameLabel];
   [self setupFeatureButton];
   [self setupEditProfileButton];

   [self setImage:"tempImage"];
   return self;
}

- (void)setupVars;
{
   delegate             = Delegate;
   size                 = CGSizeMake(screenWidth,screenHeight/goldenRatio);
   self.frame           = CGRectMake(0,0,screenWidth,size);
   self.backgroundColor = [UIColor blackColor];
   imageView            = [[UIImageView alloc] init];
}

- (void)setupImageView;
{
   imageView.contentMode = UIViewContentModeScaleAspectFill;
   imageView.frame = { {0,0}, size };
   [self addSubview:imageView];
}

- (void)setupShadow;
{
   UIView *view = [[UIView alloc] init];
   //view.backgroundColor = [UIColor blackColor];
   view.alpha = 1.0;
   view.frame = CGRectMake(0,CGRectGetMaxY(imageView.frame) - shadowHeight, screenWidth, shadowHeight);
   CAGradientLayer *gradient = [CAGradientLayer layer];
   gradient.frame = view.bounds;
   gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
   [view.layer insertSublayer:gradient atIndex:0];
   [self addSubview:view];
}

- (void)setupNameLabel;
{
   _textLabel = [[UILabel alloc] init];
   _textLabel.frame = CGRectMake(20,CGRectGetMaxY(imageView.frame) - 42 ,screenWidth,26);
   _textLabel.textAlignment = NSTextAlignmentLeft;
   _textLabel.text = [self labelText];
   _textLabel.textColor = [UIColor whiteColor];
   _textLabel.numberOfLines = 1;
   _textLabel.font = [UIFont systemFontOfSize: 22 weight:UIFontWeightRegular];
   [self addSubview:_textLabel];
}
- (NSString *)labelText;
{
   return _user.fullName;
}


- (void)setupFeatureButton;
{
   UIButton *button;
   if (isMyProfile) { // elipses button
      button = [self newMenuButon];
      button.center = _textLabel.center;
      [ViewUtilities setX:screenWidth - 45 forView:button];
   }
   else { // chat button
      // button = [self newTextbutton:@"chat"];
      // [ViewUtilities setX:screenWidth - button.frame.size.width - 12 forView:button];
      // [_headerBackButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   }
   [self addSubview:button];
}


- (void)setupEditProfileButton;
{
   UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
   button.frame = CGRectMake(0,CGRectGetMaxY(imageView.frame) - 60, screenWidth, 60);
   [button setBackgroundColor: [UIColor clearColor]];
   [button addTarget:self action:@selector(editProfileClicked) forControlEvents:UIControlEventTouchUpInside];
   [self addSubview:button];
}



@end
