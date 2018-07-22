//
//  AddButton.m
//  MMCM2
//
//  Created by Richard Montricul on 9/25/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "AddButton.h"
#import "Global.h"

@implementation AddButton

- (id)init;
{
   self = [super init];
   // var
      self.diameter = 60;
      // self = [UIButton buttonWithType:UIButtonTypeCustom];
   // base shadow
      UIView *shadow = [[UIView alloc] init];
      shadow.frame = self.frame;
      shadow.layer.cornerRadius = self.diameter/2;
      shadow.backgroundColor = [UIColor whiteColor];
      shadow.layer.shadowColor = [UIColor blackColor].CGColor;
      shadow.layer.shadowOpacity = 0.5;
      shadow.layer.shadowRadius = 1;
      shadow.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
      [self addSubview:shadow];
   // general
      self.frame = CGRectMake( 0, 0, self.diameter, self.diameter);
      self.backgroundColor = themeColorLight;
      [self setTintColor:[UIColor whiteColor]];
      [self addTarget:self action:@selector(_clicked) forControlEvents:UIControlEventTouchUpInside];
   // button icon
      UIImage *image = [[UIImage imageNamed:@"addIconAlt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
      imageView.frame = CGRectMake(15, 15, self.diameter/2, self.diameter/2);
      imageView.contentMode = UIViewContentModeScaleAspectFill;
      [self addSubview:imageView];
   // button border
      self.layer.borderWidth = 4;
      self.layer.borderColor = [UIColor whiteColor].CGColor;
      self.layer.cornerRadius = self.diameter/2;
      self.layer.masksToBounds = YES;
   return self;
}

- (void)_clicked;
{
}
@end
