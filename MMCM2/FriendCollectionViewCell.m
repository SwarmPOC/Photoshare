//
//  FriendCollectionViewCell.m
//  MMCM2
//
//  Created by Richard Montricul on 11/11/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "FriendCollectionViewCell.h"
#import "ViewUtilities.h"

@implementation FriendCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
 self = [super initWithFrame:frame];
    if (self) {
      [self setupViews];
    }
    return self;
}

- (void)setupViews;
{
   [self setupImage];
   [self setupLabel];
}

- (void)setupImage;
{
   _imageView = [[UIImageView alloc] init];
   _imageView.frame = CGRectMake(5,0,60,80);
   _imageView.contentMode = UIViewContentModeScaleAspectFill;
   _imageView.layer.masksToBounds = YES;

   _imageView.image = [UIImage imageNamed:@"Logo"];

   [self.contentView addSubview:_imageView];
}


- (void)setImage:(UIImage *)image;
{
   _imageView.image = image;
}

- (void)setupLabel;
{
   _label = [[UILabel alloc] init];
   _label.frame = CGRectMake(0,80,75,20);
   _label.text = @"";
   _label.font = [UIFont systemFontOfSize:12];
   _label.textColor = [UIColor blackColor];
   _label.textAlignment = NSTextAlignmentCenter;
   _label.numberOfLines = 1;
   [self.contentView addSubview:_label];
}

- (void)setText:(NSString *)text;
{
   _label.text = text;
}

@end
