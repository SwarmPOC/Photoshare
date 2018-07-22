//
//  BasicImageAndTextViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 9/16/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

// Common
   #import "Global.h"
   #import "ViewUtilities.h"

@interface BasicImageAndTextViewController : UIViewController
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UILabel *footerLabel;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIView *mainPanel;
//@property (strong, nonatomic) UILabel *label;

- (id)initWithHeader:(NSString *)text;
- (void)setImage:(NSString *)imageName;
- (void)setFooterText:(NSString *)text;
- (void)setButtonText:(NSString *)text;
@end
