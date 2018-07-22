//
//  FocusBox.m
//  MMCM2
//
//  Created by Richard Montricul on 1/25/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "FocusBox.h"

@implementation FocusBox
NSMutableArray *ticks;
CGFloat tickLength = 10;

- (id)init;
{
   self = [super init];

   self.layer.borderWidth = 2;
   self.layer.borderColor = [UIColor greenColor].CGColor;
   self.userInteractionEnabled = NO;

   [self setupTicks];
   return self;
}

- (void)setupTicks;
{
   ticks = [[NSMutableArray alloc] init];
   _tickLeft = [self newTick];
   _tickRight = [self newTick];
   _tickTop = [self newTick];
   _tickBottom = [self newTick];
   for (UIView *view in ticks) {
      view.backgroundColor = [UIColor greenColor];
      [self addSubview:view];
   }
}

- (UIView *)newTick;
{
   UIView *view = [[UIView alloc] init];
   [ticks addObject:view];   
   return view;
}


- (void)setColor:(UIColor *)color;
{
   self.layer.borderColor = color.CGColor;
   for (UIView *view in ticks) {
      view.backgroundColor = color;
   }
}

- (void)setSize:(CGFloat)size;
{
   self.frame = CGRectMake(0, 0, size, size);
   CGFloat mid = size/2;
   mid = mid-1;
   _tickLeft.frame = CGRectMake(0,mid,tickLength,1);
   _tickRight.frame = CGRectMake(size-tickLength,mid,tickLength,1);
   _tickTop.frame = CGRectMake(mid,0,1,tickLength);
   _tickBottom.frame = CGRectMake(mid,size-tickLength,1,tickLength);

   self.layer.cornerRadius = size/2;
}

@end
