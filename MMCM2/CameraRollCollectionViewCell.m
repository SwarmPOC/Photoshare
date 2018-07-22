//
//  CameraRollCollectionViewCell.m
//  MMCM2
//
//  Created by Richard Montricul on 2/13/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "CameraRollCollectionViewCell.h"

@implementation CameraRollCollectionViewCell

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
}

- (void)setupImage;
{
   _imageView = [[UIImageView alloc] init];
   _imageView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
   _imageView.contentMode = UIViewContentModeScaleAspectFill;
   _imageView.layer.masksToBounds = YES;

   [_imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
   [_imageView.layer setBorderWidth: 0.5];

   [self.contentView addSubview:_imageView];
}


- (void)setImageFromImage:(UIImage *)image;
{
   _imageView.image = image;
}
- (void)setImageFromData:(NSData *)imageData;
{
   _imageView.image = [UIImage imageWithData:imageData];
}
@end
