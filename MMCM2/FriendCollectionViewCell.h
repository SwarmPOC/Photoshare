//
//  FriendCollectionViewCell.h
//  MMCM2
//
//  Created by Richard Montricul on 11/11/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *label;

- (void)setText:(NSString *)text;
- (void)setImage:(UIImage *)image;

@end
