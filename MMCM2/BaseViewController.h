//
//  BaseViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 8/8/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "CommonViewController.h"

@interface BaseViewController : CommonViewController
extern int headerHeight;
extern int buttonHeight;

@property (strong, nonatomic) UIButton *button;

- (BOOL)showNextButton;

@end
