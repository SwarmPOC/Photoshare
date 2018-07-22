//
//  CameraRollCollectionViewCell.h
//  MMCM2
//
//  Created by Richard Montricul on 2/13/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraRollCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImageView *imageView;

- (void)setImageFromImage:(UIImage *)image;
- (void)setImageFromData:(NSData *)imageData;
@end
