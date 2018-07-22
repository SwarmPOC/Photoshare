//
//  CodeEntryViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 4/26/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "CodeEntryViewController.h"

@interface CodeEntryViewController ()

@end

@implementation CodeEntryViewController

- (void)setupViews;
{
   [super setupViews];
   [self setupDetailText];
}

- (void)viewDidAppear:(BOOL)animated
{
   [_codeEntryTextField becomeFirstResponder];
}

- (NSString *)headerText;
{
   return @"";
}

- (int)getRowCount
{
   return 1;
}

- (NSString *)labelText;
{
   return @"";
}

- (void)setupLabel;
{
   [super setupLabel];
   self.label.textAlignment = NSTextAlignmentCenter;
}

- (void)customizeTextField:(UITextField *)textField forIndexPath:(NSIndexPath *)indexPath;
{
   _codeEntryTextField = textField;
   [ViewUtilities setX:textField.frame.origin.x - 10 forView:textField];
   textField.textAlignment = NSTextAlignmentCenter;
   textField.font = [UIFont systemFontOfSize:28];
   textField.returnKeyType = UIReturnKeyDone;
   textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
   //textField.keyboardType = UIKeyboardTypeASCIICapable;
}

- (void)setupDetailText;
{
   _detailLabel = [[UILabel alloc] init];
   _detailLabel.textAlignment = NSTextAlignmentCenter;
   _detailLabel.textColor = darkGray;
   _detailLabel.numberOfLines = 0;
   _detailLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
   [self setDetailText:[self detailText]];
   _detailLabel.center = self.view.center;
   [ViewUtilities setY:CGRectGetMaxY(self.tableView.frame) + 20 forView:_detailLabel];
   [self.view addSubview:_detailLabel];
}

- (NSString *)detailText;
{
   return @"";
}

- (void)setDetailText:(NSString *)text;
{
   _detailLabel.text = text;
   CGSize size = [_detailLabel sizeThatFits:CGSizeMake(300, CGFLOAT_MAX)];
   [ViewUtilities setSize:size forView:_detailLabel];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self next];
    return true;
}

- (void)next;
{
   if (_codeEntryTextField.text.length > 0) {
      [self.view endEditing:YES];
      [server verifyInviteCode:_codeEntryTextField.text withCompletionBlock:^(id result){
         if ([result boolValue] == YES) {
            [self verifyPassed];
         }
         else {
            [self verifyFailed];
         }
      }];
   }
}

- (void)verifyPassed;
{
}

- (void)verifyFailed;
{
   dispatch_async(dispatch_get_main_queue(), ^{
      [self setDetailText:@"We couldn't find your invitation code!  Double check your code and try again"];
      _detailLabel.textColor = themeColor;
      [_codeEntryTextField becomeFirstResponder];
   });
}

@end
