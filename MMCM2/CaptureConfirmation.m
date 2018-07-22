//
//  CaptureConfirmation.m
//  MMCM2
//
//  Created by Richard Montricul on 1/22/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "CaptureConfirmation.h"
#import "ViewUtilities.h"
#import "Global.h"

@implementation CaptureConfirmation

static id delegate;
static UIButton *acceptButton;
static UIButton *retakeButton;
static UIButton *preview;
static UIImageView *previewImage;
static UILabel *label;
static UIButton *tagPeopleButton;

- (id)init:(id)Delegate;
{
   self = [super init];
   delegate = Delegate;
   self.frame = CGRectMake(0,0, 300, 325);
   self.layer.cornerRadius = 10;
   self.backgroundColor = [UIColor colorWithRed:(245/255.0) green:(245/255.0) blue:(245/255.0) alpha: 1.0];
   [self setupCapturePreview];
   [self setupCaption];
   [self setupPeopleTags];
   [self setupLabel];
   [self setupSwitch];
   [self setupRetakeButton];
   [self setupAcceptButton];
   return self;
}


- (void)setupCapturePreview;
{
   _preview = [[UIButton alloc] init];
   _preview.frame = CGRectMake(120,30,60,80);
   _preview.layer.cornerRadius = 10;

   previewImage = [[UIImageView alloc] init];
   previewImage.contentMode = UIViewContentModeScaleAspectFill;
   previewImage.frame = CGRectMake(0,0,60,80);
   previewImage.backgroundColor = [UIColor clearColor];
   previewImage.layer.masksToBounds = YES;
   previewImage.layer.cornerRadius = 5;
   [_preview addSubview:previewImage];
   [self addSubview:_preview];
}


- (void)setupCaption;
{
   _caption = [[UITextView alloc] init];
   _caption.frame = CGRectMake(17, 147, 266, 28);
   _caption.delegate = delegate;
   //_caption.numberOfLines = 0;
   _caption.text = @"caption";
   _caption.textColor = [UIColor lightGrayColor];
   [self addSubview:_caption];
}


- (void)setupPeopleTags;
{
   _tagTextView = [[UITextView alloc] init];
   _tagTextView.frame = CGRectMake(17, 184, 266, 28);
   _tagTextView.delegate = delegate;
   [self setEmptyTags];
   _tagTextView.editable = NO;
   _tagTextView.userInteractionEnabled = YES;
   [self addSubview:_tagTextView];

   // _tagButton = [self newButton:@"" selector:@selector(tagButtonClicked)];
   // _tagButton.frame = _tagTextView.frame;
   // _tagButton.backgroundColor = [UIColor clearColor];
   // [self addSubview:_tagButton];
}


- (void)setupLabel;
{
   label = [[UILabel alloc] init];
   label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
   label.frame = CGRectMake(17,233, 300, 60);
   label.numberOfLines = 0;
   label.text = @"save to camera roll";
   [label sizeToFit];
   [self addSubview:label];
}


- (void)setupSwitch;
{
   _switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
   _switchView.onTintColor = themeColor;
   _switchView.center = label.center;
   if (cameraRollAuthStatus == AUTHORIZED) {
      [_switchView setOn:YES animated:YES];
   }
   [ViewUtilities setX:CGRectGetMaxX(_caption.frame) - _switchView.frame.size.width forView:_switchView];
   [self addSubview:_switchView];
}


- (void)setupRetakeButton;
{
   _retakeButton = [self newButton:@"retake" selector:@selector(retakeButtonClicked)];
   _retakeButton.frame = CGRectMake(0,276,114,49);
   _retakeButton.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha: 1.0];
   [_retakeButton setTitleColor:[UIColor colorWithRed:(125/255.0) green:(125/255.0) blue:(125/255.0) alpha: 1.0]
                forState:UIControlStateNormal];
   _retakeButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
   // set rounded corner
      UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_retakeButton.bounds 
         byRoundingCorners:UIRectCornerBottomLeft
         cornerRadii:CGSizeMake(10.0, 10.0)];
      CAShapeLayer *maskLayer = [CAShapeLayer layer];
      maskLayer.frame = _retakeButton.bounds;
      maskLayer.path = maskPath.CGPath;
      _retakeButton.layer.mask = maskLayer;
   [self addSubview:_retakeButton];
}
- (void)setupAcceptButton;
{
   _acceptButton = [self newButton:@"Post" selector:@selector(acceptButtonClicked)];
   _acceptButton.frame = CGRectMake(115,276,186,49);
   _acceptButton.backgroundColor = [UIColor colorWithRed:(219/255.0)  green:(85/255.0)  blue:(85/255.0)  alpha:1.0f];
   [_acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   _acceptButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
   // set rounded corner
      UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_acceptButton.bounds 
         byRoundingCorners:UIRectCornerBottomRight
         cornerRadii:CGSizeMake(10.0, 10.0)];
      CAShapeLayer *maskLayer = [CAShapeLayer layer];
      maskLayer.frame = _acceptButton.bounds;
      maskLayer.path = maskPath.CGPath;
      _acceptButton.layer.mask = maskLayer;
   [self addSubview:_acceptButton];
}

- (UIButton *)newButton:(NSString *)title selector:(SEL)selector;
{
   UIButton *button = [[UIButton alloc] init];
   [button setTitle:title forState:UIControlStateNormal];
   [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
   return button;
}

- (void)retakeButtonClicked;
{
}
- (void)acceptButtonClicked;
{
}

- (void)tagButtonClicked;
{
}

- (void)setImage:(UIImage *)image;
{
   previewImage.image = image;
}

- (void)setTags:(NSString *)text;
{
   if ([text length] == 0) {
      [self setEmptyTags];
   }
   else {
      _tagTextView.text = text;
      _tagTextView.textColor = [UIColor blackColor];
   }
}

- (void)setEmptyTags;
{
   _tagTextView.text = @"tag people";
   _tagTextView.textColor = [UIColor lightGrayColor];
}

// - (BOOL)textViewShouldBeginEditing:(UItextView *)textView;
// {
//    if ([textView.text length] == 0)
//       textView.text = @"#";
//    return YES;
// }
// 
// 
// - (BOOL)textView:(UItextView *)textView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
// {
//    BOOL canEdit=NO;
//    NSCharacterSet *myCharSet = [NSCharacterSet alphanumericCharacterSet];
//    for (int i = 0; i < [string length]; i++) {
//        unichar c = [string characterAtIndex:i];
//        if (![myCharSet characterIsMember:c]) {
//            return NO;
//        }
//    }
//    NSUInteger newLength = [textView.text length] + [string length] - range.length;
//    if (newLength > 0) {
//        for (int i = 0; i < [string length]; i++) {
//            unichar c = [string characterAtIndex:i];
//            if (![myCharSet characterIsMember:c]) {
//                canEdit=NO;
//            }
//            else {
//                canEdit=YES;
//            }
//        }
//    }
//    if ([textView.text length] == 0)
//       textView.text = @"#";
//    return (newLength > 50 && canEdit) ? NO : YES;
// }
// 
// 
// - (void)textViewDidChange :(UItextView *)textView 
// {
//    if ([textView.text length] == 0) {
//    }
// }




@end
