//
//  NameViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 12/7/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "NameViewController.h"
#import "GenderViewController.h"

@interface NameViewController ()

@end

@implementation NameViewController
static UITextField *firstNameTextField;
static UITextField *lastNameTextField;

- (void)viewDidAppear:(BOOL)animated 
{
   [firstNameTextField becomeFirstResponder];
}

- (int)getRowCount
{
   return 2;
}

- (NSString *)labelText;
{
   return @"Let's double check your name:";
}

- (void)customizeTextField:(UITextField *)textField forIndexPath:(NSIndexPath *)indexPath;
{
   if ([indexPath row] == 0) {
       firstNameTextField = textField;
       firstNameTextField.placeholder = @"first name";
       firstNameTextField.text = myUserData.firstName;
       //firstNameTextField.text = [myUserData objectForKey:@"firstName"];
       firstNameTextField.returnKeyType = UIReturnKeyNext;
   }
   else {
       lastNameTextField = textField;
       lastNameTextField.placeholder = @"last name";
       lastNameTextField.text = myUserData.lastName;
       //lastNameTextField.text = [myUserData objectForKey:@"lastName"];
       lastNameTextField.returnKeyType = UIReturnKeyDone;
   }       
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == firstNameTextField) {
        [lastNameTextField becomeFirstResponder];
        return false;
    }
    else if (textField == lastNameTextField) {
        [self next];
    }
    return true;
}

- (BOOL)nameCheck;
{
   // NSString *text1 = [firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   // NSString *text2 = [lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   if (firstNameTextField.text.length == 0 || lastNameTextField.text.length == 0)
      return NO;
   return YES;
}


- (void)next;
{
   if ([self nameCheck]) {
      dispatch_async(dispatch_get_main_queue(), ^{
         [self.navigationController pushViewController:[[GenderViewController alloc] init] animated:YES];
      });
      NSString *firstName = firstNameTextField.text;
      NSString *lastName = lastNameTextField.text;
      NSString *name = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
      NSDictionary *vals = @{@"name":name,  
                             @"firstName":firstName,
                             @"lastName":lastName};
      [server updateName:vals];
      myUserData.fullName = name;
      myUserData.firstName = firstName;
      myUserData.lastName = lastName;
      // [myUserData setValue:name forKey:@"fullName"];
      // [myUserData setValue:firstName forKey:@"firstName"];
      // [myUserData setValue:lastName forKey:@"lastName"];
   }
}
@end
