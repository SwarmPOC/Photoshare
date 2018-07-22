//
//  ViewUtilities.h
//  MMCM2
//
//  Created by Richard Montricul on 7/12/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewUtilities : UIView
+ (void)setX:(NSInteger)x forView:(UIView *)view;
+ (void)setY:(NSInteger)y forView:(UIView *)view;
+ (void)setXY:(CGPoint)point forView:(UIView *)view;
+ (void)setWidth:(NSInteger)width forView:(UIView *)view;
+ (void)setHeight:(NSInteger)height forView:(UIView *)view;
+ (void)setSize:(CGSize)size forView:(UIView *)view;
+ (void)fadeView:(UIView *)view toAlpha:(CGFloat)alpha;
+ (void)fadeView:(UIView *)view toAlpha:(CGFloat)alpha duration:(CGFloat)duration;
+ (void)fadeArray:(NSArray *)array toAlpha:(CGFloat)alpha duration:(CGFloat)duration;
+ (void)fadeInView:(UIView *)view;
+ (void)fadeOutView:(UIView *)view;

+ (void)flashView:(UIView *)view;
@end
