//
//  RegistrationViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/2/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "RegistrationViewController.h"
// #import "ServerInterface.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

// Controls
   static UIScrollView *sView;
   static UILabel *name;
   static UIView *namePanel;

- (void)viewDidLoad {
   [super viewDidLoad];
   [self setupViews];
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}

- (void)setupViews; 
{
   [self setButtonText:@"next"];
   [self.button addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
   [self setupScrollView];
   [self setupNamePanel];
   [self setupUpdateNameButton];
   [self setupGenderOption];
}

- (void)setupScrollView;
{
   sView = [[UIScrollView alloc] init];
   sView.frame = self.mainPanel.frame;
   sView.delegate = self;
   sView.backgroundColor = [UIColor whiteColor];
   [self.view addSubview:sView];
}

- (void)setupNamePanel;
{
   namePanel = [[UIView alloc] init];
   namePanel.frame = CGRectMake(0,0,screenWidth, 120);
   [sView addSubview:namePanel];

   name = [[UILabel alloc] init];
   //name.text = myUserData.name;
   [name sizeToFit];
   name.textAlignment = NSTextAlignmentCenter;
   name.textColor = [UIColor blackColor];
   name.numberOfLines = 1;
   name.font = [UIFont systemFontOfSize: 15 weight:UIFontWeightBold];
   name.center = namePanel.center;
   [ViewUtilities setY:30 forView:name];
   [namePanel addSubview:name];
}

- (void)setupUpdateNameButton;
{
   UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
   [button setTitle:@"update" forState:UIControlStateNormal];
   button.titleLabel.font = [UIFont systemFontOfSize:13];
   button.titleLabel.textAlignment = NSTextAlignmentCenter;
   button.titleLabel.numberOfLines = 1;
   [button setTitleColor:themeColor forState:UIControlStateNormal];
   [button sizeToFit];
   button.center = namePanel.center;
   [ViewUtilities setY:CGRectGetMaxY(name.frame)+ 8 forView:button];
   [namePanel addSubview:button];
}

- (void)setupGenderOption;
{
   OptionPanel *genderOption = [[OptionPanel alloc] initWithHeader:@"gender"];
   [genderOption.option1 setLabel:@"female"];
   [genderOption.option3 setLabel:@"male"];
   genderOption.option2.enabled = false;
   //[ViewUtilities setY:100 forView:genderOption.view];
   CGFloat x = (screenWidth - 116*3)/2;
   [ViewUtilities setXY:CGPointMake(x,100) forView:genderOption.view];

   [sView addSubview: genderOption.view];
}

@end

@implementation Option
// - (void)clicked;
// {
//    NSLog(@"clicked");
// }

- (id)init;
{
   return [self initWithLabel:@"option"];
}
- (id)initWithLabel:(NSString *)text;
{
   self = [super init];
   [self setupViews];
   [self setLabel:text];
   _state = false;
   _enabled = true;
   return self;
}

- (void)setEnabled:(BOOL)value;
{
   _view.hidden = !value;
}

- (void)setupViews;
{
   _view = [[UIView alloc] init];
   _view.frame = CGRectMake(0,0,116,86);
   _view.backgroundColor = [UIColor whiteColor];
   [self setupLabel];
   [self setupRadioButton];
}

- (void)setupLabel;
{
   _label = [[UILabel alloc] init];
   _label.frame = CGRectMake(0,0,_view.frame.size.width,18);
   _label.backgroundColor = [UIColor whiteColor];
   _label.textAlignment = NSTextAlignmentCenter;
   _label.textColor = [UIColor blackColor];
   _label.numberOfLines = 1;
   _label.font = [UIFont systemFontOfSize: 15 weight:UIFontWeightBold];
   [_view addSubview:_label];
   [self setLabel:@"Option"];
}

- (void)setLabel:(NSString *)text;
{
   _label.text = text;
}

- (void)setupRadioButton;
{
   _button = [[UIButton alloc] init];
   _button.frame = CGRectMake(0,0,26,26);
   _button.backgroundColor = [UIColor whiteColor];
   _button.layer.borderWidth = 2;
   _button.layer.borderColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha: 1.0].CGColor;
   _button.layer.cornerRadius = 13.0;
   _button.layer.masksToBounds = YES;
   _button.center = _view.center;
   [ViewUtilities setY:CGRectGetMaxY(_label.frame) + 18 forView:_button];
   [_view addSubview:_button];
   [self setupFill];
}

- (void)setupFill;
{
   _buttonFill = [[UIView alloc] init];
   _buttonFill.frame = CGRectMake(0,0,18,18);
   _buttonFill.backgroundColor = themeColor;
   _buttonFill.layer.cornerRadius = 9.0;
   _buttonFill.center = _button.center;
   _buttonFill.hidden = true;
   [ViewUtilities setY:_button.frame.origin.y + 4 forView:_buttonFill];
   [_view addSubview:_buttonFill];
}

- (void)setState:(BOOL)value;
{
   _buttonFill.hidden = !value;
}

@end

@implementation OptionPanel

static NSArray *arrTitles;

- (id)initWithHeader:(NSString *)text;
{
   self = [super init];
   [self setupViews];
   [self setHeaderText:text];
   return self;
}
- (id)initWithTitles:(NSArray *)titles;
{
   self = [super init];
   arrTitles = [[NSArray alloc] initWithArray:titles];
   [self setupViews];
   return self;
}


- (void)setupViews;
{
   [self setupContainerPanel];
   [self setupHeader];
   [self setupOptionPanels];
}

- (void)setupContainerPanel;
{
   _view = [[UIView alloc] init];
   _view.backgroundColor = [UIColor whiteColor];
   _view.frame = CGRectMake(0,0,116*3, 124);
}

- (void)setupHeader;
{
   _headerLabel = [[UILabel alloc] init];
   _headerLabel.backgroundColor = gray;
   _headerLabel.textAlignment = NSTextAlignmentCenter;
   _headerLabel.textColor = [UIColor blackColor];
   _headerLabel.numberOfLines = 1;
   _headerLabel.font = [UIFont systemFontOfSize: 13 weight:UIFontWeightRegular];
   [_view addSubview:_headerLabel];
   [self setHeaderText:@"header"];
}

- (void)setHeaderText:(NSString *)text;
{
   _headerLabel.text = text;
   [_headerLabel sizeToFit];
   _headerLabel.frame = CGRectMake(10,0,_headerLabel.frame.size.width + 20, 24);
}


- (void)setupOptionPanels;
{
   CGFloat y = 24+14;

   _option1 = [[Option alloc] init];
   [ViewUtilities setXY:CGPointMake(0,y) forView:_option1.view];
   [_view addSubview:_option1.view];
   _option1.delegate = self;
   _option1.button.tag = 1;
   [_option1.button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];

   _option2 = [[Option alloc] init];
   [ViewUtilities setXY:CGPointMake(116,y) forView:_option2.view];
   [_view addSubview:_option2.view];
   _option2.delegate = self;
   _option2.button.tag = 2;
   [_option2.button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];

   _option3 = [[Option alloc] init];
   [ViewUtilities setXY:CGPointMake(116*2,y) forView:_option3.view];
   [_view addSubview:_option3.view];
   _option3.delegate = self;
   _option3.button.tag = 3;
   [_option3.button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];

   //_option2.enabled = false;
   // _option3.state = true;
   //[_option1 setState:true];
}

- (void)clicked:(UIButton *)sender;
{
   if (sender.tag == 1) {
      _option1.state = true;
      _option2.state = false;
      _option3.state = false;
   }
   else if (sender.tag == 2) {
      _option1.state = false;
      _option2.state = true;
      _option3.state = false;
   }
   else if (sender.tag == 3) {
      _option1.state = false;
      _option2.state = false;
      _option3.state = true;
   }
}


@end
