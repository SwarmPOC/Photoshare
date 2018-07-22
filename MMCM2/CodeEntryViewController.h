//
//  CodeEntryViewController.h
//  MMCM2
//
//  Created by Richard Montricul on 4/26/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "BaseTextFieldsViewController.h"

@interface CodeEntryViewController : BaseTextFieldsViewController
   <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *codeEntryTextField;
@property (strong, nonatomic) UILabel *detailLabel;


@end
