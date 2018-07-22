//
//  BasicImageAndTextViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 9/16/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "BasicImageAndTextViewController.h"

@interface BasicImageAndTextViewController ()

@end

@implementation BasicImageAndTextViewController
static NSString *headerText;
static BOOL hasHeader = NO;
static UIView *header;
static int keyboardHeight = 0;
static int buttonHeight = 49;

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (id)initWithHeader:(NSString *)text;
{
   self = [super init];
   headerText = text;
   hasHeader = YES;
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   [Global sharedManager];
   self.view.backgroundColor = [UIColor whiteColor];
   [self setupMainPanel];
   if (hasHeader){
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
      [self setupHeader];
   }
   else {
      [self setupImageView];
      [self setupFooterLabel];
   }
   [self setupButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupHeader;
{
   header = [[UIView alloc] init];
   header.frame = CGRectMake(0,0,screenWidth,80);
   [self.view addSubview:header];
   [self setupHeaderLabel];
}

- (void)setupHeaderLabel;
{
   _headerLabel = [[UILabel alloc] init];
   _headerLabel.frame = CGRectMake(0,0,screenWidth,40);
   _headerLabel.textAlignment = NSTextAlignmentLeft;
   _headerLabel.textColor = [UIColor blackColor];
   _headerLabel.numberOfLines = 1;
   _headerLabel.font = [UIFont systemFontOfSize: 15 weight:UIFontWeightMedium];
   [self.view addSubview:_headerLabel];


   [self setHeaderText:headerText];
}
- (void)setHeaderText:(NSString *)text;
{
   _headerLabel.text = text;
   [_headerLabel sizeToFit];
   _headerLabel.center = header.center;
}


- (void)setupImageView;
{
   _imageView = [[UIImageView alloc] init];
   _imageView.contentMode = UIViewContentModeScaleAspectFit;
   _imageView.frame = CGRectMake(0,0,280, 280);
   _imageView.center = self.view.center;
   [ViewUtilities setY:(.1 * screenHeight) forView:_imageView];
   [self.view addSubview:_imageView];
}
- (void)setImage:(NSString *)imageName;
{
   _imageView.image = [UIImage imageNamed:imageName];
}


- (void)setupFooterLabel;
{
   _footerLabel = [[UILabel alloc] init];
   _footerLabel.textAlignment = NSTextAlignmentCenter;
   _footerLabel.textColor = [UIColor blackColor];
   _footerLabel.numberOfLines = 0;
   _footerLabel.font = [UIFont systemFontOfSize: 18 weight:UIFontWeightLight];
   [self.view addSubview:_footerLabel];
}
- (void)setFooterText:(NSString *)text;
{
   _footerLabel.text = text;
   CGSize size = [_footerLabel sizeThatFits:CGSizeMake(260, CGFLOAT_MAX)];
   [ViewUtilities setSize:size forView:_footerLabel];
   _footerLabel.center = self.view.center;
   int margin = (_button.frame.origin.y - CGRectGetMaxY(_imageView.frame) - _footerLabel.frame.size.height) / 2;
   //[ViewUtilities setY:(_button.frame.origin.y - size.height - 60) forView:_footerLabel];
   [ViewUtilities setY:margin + CGRectGetMaxY(_imageView.frame) forView:_footerLabel];
}


- (void)setupButton;
{
   _button = [UIButton buttonWithType:UIButtonTypeCustom];
   _button.titleLabel.font = [UIFont systemFontOfSize: 15 weight:UIFontWeightMedium];
   _button.titleLabel.textAlignment = NSTextAlignmentCenter;
   _button.titleLabel.numberOfLines = 1;

   _button.frame = CGRectMake(0,screenHeight-buttonHeight,screenWidth,buttonHeight);
   _button.backgroundColor = themeColorLight;
   [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   [self setButtonText:@""];

   //  _button.layer.borderWidth = 1;
   //  _button.layer.borderColor = [UIColor colorWithRed:222/255.0 green:225/255.0 blue:227/255.0 alpha: 1.0].CGColor;
   //  _button.layer.cornerRadius = 5.0;
   //  _button.layer.masksToBounds = YES;
   //  [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
   //  [self setButtonText:@"button"];

   [self.view addSubview:_button];
}
- (void)setButtonText:(NSString *)text;
{
   [_button setTitle:text forState:UIControlStateNormal];
   // if (!hasheader) {
   //    CGSize size = [_button sizeThatFits:CGSizeMake(280, CGFLOAT_MAX)];
   //    size.width +=20;
   //    if (size.width < 100) {
   //       size.width = 100; //width minimum 100
   //    }
   //    [ViewUtilities setSize:size forView:_button];
   //    _button.center = self.view.center;
   //    [ViewUtilities setY:(screenHeight - size.height - 50) forView:_button];
   // }
}


- (void)setupMainPanel;
{
   _mainPanel = [[UIView alloc] init];
   //_mainPanel.backgroundColor = [UIColor whiteColor];
   if (hasHeader) {
      _mainPanel.frame = CGRectMake(0,81,screenWidth, screenHeight - (buttonHeight + 80));
   }
   else {
      _mainPanel.frame = CGRectMake(0,0,screenWidth, screenHeight - buttonHeight);
   }
   [self.view addSubview:_mainPanel];
}


- (void)adjustViews;
{
   [ViewUtilities setY:screenHeight - keyboardHeight - buttonHeight forView:_button];
}

- (void)keyboardWillHide:(NSNotification *)notification 
{
   keyboardHeight = 0;
   [self adjustViews];
}
- (void)keyboardWillShow:(NSNotification *)notification 
{
   keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
   [self adjustViews];
}

@end
