//
//  RegistrationViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 12/2/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "BasicImageAndTextViewController.h"

@interface RegistrationViewController : BasicImageAndTextViewController <UIScrollViewDelegate>

@end

@interface Option : NSObject
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIView *buttonFill;
@property (strong, nonatomic) id delegate;
@property BOOL state;
@property BOOL enabled;
- (id)init;
- (id)initWithLabel:(NSString *)text;
- (void)setLabel:(NSString *)text;
- (void)setState:(BOOL)state;
@end

@interface OptionPanel : NSObject
@property (strong, nonatomic) UIView  *view;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) Option  *option1;
@property (strong, nonatomic) Option  *option2;
@property (strong, nonatomic) Option  *option3;
- (id)initWithHeader:(NSString *)text;
- (id)initWithTitles:(NSArray *)titles;
- (void)setHeaderText:(NSString *)text;

@end
