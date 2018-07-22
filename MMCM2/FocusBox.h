//
//  FocusBox.h
//  MMCM2
//
//  Created by Richard Montricul on 1/25/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FocusBox : UIView
@property (strong, nonatomic) UIView* tickLeft;
@property (strong, nonatomic) UIView* tickRight;
@property (strong, nonatomic) UIView* tickTop;
@property (strong, nonatomic) UIView* tickBottom;

- (void)setColor:(UIColor *)color;
- (void)setSize:(CGFloat)size;
@end
