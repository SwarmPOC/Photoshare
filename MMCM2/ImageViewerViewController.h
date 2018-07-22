//
//  ImageViewerViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 3/6/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "CommonViewController.h"

typedef NS_ENUM(NSInteger, lockType)
{
   NONE = 0,
   MIN  = 1,
   MAX  = 2
};
typedef NS_ENUM(NSInteger, EDITTYPE)
{
   EDITTYPE_NONE = 0,
   EDITTYPE_FULL = 1,
   EDITTYPE_PARTIAL = 2
};

@interface ImageViewerViewController : CommonViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) UIButton *exitButton;


- (id)initWithImage:(UIImage *)image;
- (id)initWithKey:(NSString *)Key editType:(EDITTYPE)EditType;
- (void)centerScrollViewContents;

@end
