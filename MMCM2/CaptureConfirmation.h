//
//  CaptureConfirmation.h
//  MMCM2
//
//  Created by Richard Montricul on 1/22/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptureConfirmation : UIView 
@property (strong, nonatomic) UIButton *acceptButton;
@property (strong, nonatomic) UIButton *retakeButton;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIButton *preview;
@property (strong, nonatomic) UITextView *caption;
@property (strong, nonatomic) UITextView *tagTextView;
@property (strong, nonatomic) UISwitch *switchView;

- (id)init:(id)Delegate;
- (void)setTags:(NSString *)text;
@end
