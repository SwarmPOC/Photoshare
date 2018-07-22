//
//  ViewUtilities.m
//  MMCM2
//
//  Created by Richard Montricul on 7/12/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "ViewUtilities.h"

@implementation ViewUtilities

+ (void)setX:(NSInteger)x forView:(UIView *)view;
{
   view.frame = CGRectMake(x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
}
+ (void)setY:(NSInteger)y forView:(UIView *)view;
{
   view.frame = CGRectMake(view.frame.origin.x, y, view.frame.size.width, view.frame.size.height);
}
+ (void)setXY:(CGPoint)point forView:(UIView *)view;
{
   CGRect tempFrame = view.frame;
   tempFrame.origin = point;
   view.frame = tempFrame;
}
+ (void)setWidth:(NSInteger)width forView:(UIView *)view;
{
   view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, view.frame.size.height);
}
+ (void)setHeight:(NSInteger)height forView:(UIView *)view;
{
   view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height);
}
+ (void)setSize:(CGSize)size forView:(UIView *)view;
{
   view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, size.width, size.height);
}

+ (void)fadeView:(UIView *)view toAlpha:(CGFloat)alpha duration:(CGFloat)duration;
{
   [UIView animateWithDuration:duration
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
            view.alpha = alpha;
      } 
      completion:^(BOOL finished){
      }
   ];
}
+ (void)fadeArray:(NSArray *)array toAlpha:(CGFloat)alpha duration:(CGFloat)duration;
{
   [UIView animateWithDuration:duration
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         for (UIView *view in array) {
            view.alpha = alpha;
         }
      } 
      completion:^(BOOL finished){
      }
   ];
}
+ (void)fadeView:(UIView *)view toAlpha:(CGFloat)alpha;
{
   [ViewUtilities fadeView:view toAlpha:alpha duration:0.3];
}
+ (void)fadeInView:(UIView *)view;
{
   [ViewUtilities fadeView:view toAlpha:1.0];
}
+ (void)fadeOutView:(UIView *)view;
{
   [ViewUtilities fadeView:view toAlpha:0.0];
}

+ (void)flashView:(UIView *)view;
{
   CABasicAnimation *theAnimation;
   theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
   theAnimation.duration=0.2;
   theAnimation.repeatCount=3;
   theAnimation.autoreverses=YES;
   theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
   theAnimation.toValue=[NSNumber numberWithFloat:0];
   [view.layer addAnimation:theAnimation forKey:@"animateOpacity"]; 
}

@end
