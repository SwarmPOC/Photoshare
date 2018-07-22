//
//  BaseTextFieldsViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/9/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "BaseTextFieldsViewController.h"

@interface BaseTextFieldsViewController ()

@end

@implementation BaseTextFieldsViewController
static CGFloat keyboardHeight = 0;

- (void)viewDidLoad
{
   [super viewDidLoad];
   [[NSNotificationCenter defaultCenter] 
      addObserver: self 
      selector: @selector(keyboardWillShow:) 
      name: UIKeyboardWillChangeFrameNotification 
      object: nil];
   [[NSNotificationCenter defaultCenter] 
      addObserver: self 
      selector: @selector(keyboardWillHide:) 
      name: UIKeyboardWillHideNotification 
      object: nil];
}

- (void)customizeCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
{
    UITextField *textField = [[UITextField alloc] init];
    [self setTextFieldDefaultsFor:textField];
    [self customizeTextField:textField forIndexPath:indexPath];

    [cell.contentView addSubview:textField];
}

- (void)customizeTextField:(UITextField *)textField forIndexPath:(NSIndexPath *)indexPath; {}

- (void)setTextFieldDefaultsFor:(UITextField *)textField;
{
   int x = self.label.frame.origin.x;
   textField.frame = CGRectMake(
        x,
        0,
        self.tableView.frame.size.width - (x + 10), // 10 for margin
        58);
   textField.delegate = self;
   textField.font = [UIFont systemFontOfSize:15];
   textField.returnKeyType = UIReturnKeyDone;
   textField.clearButtonMode = UITextFieldViewModeWhileEditing;
   textField.autocorrectionType = UITextAutocorrectionTypeNo;
   textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;    
   textField.borderStyle = UITextBorderStyleNone;
   textField.backgroundColor = [UIColor whiteColor];
   [textField addTarget:self 
      action:@selector(textFieldDidChange:)
      forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange :(UITextField *)textField {}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (void)keyboardWillHide:(NSNotification *)notification 
{
   keyboardHeight = 0;
   [self adjustViews];
}
- (void)keyboardWillShow:(NSNotification *)notification 
{
   keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
   [self adjustViews];
}

- (void)adjustViews;
{
   [ViewUtilities setY:screenHeight - keyboardHeight - buttonHeight forView:self.button];
}

@end
