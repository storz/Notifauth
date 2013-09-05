//
//  EnterPINViewController.m
//  Notifauth
//
//  Created by 高浪 悟 on 11/22/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import "EnterPINViewController.h"

@interface EnterPINViewController ()

@end

@implementation EnterPINViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.UIF = [[UIFunctions alloc] init];
	[self.pinField setSecureTextEntry:YES];
	[self.pinField setKeyboardType:UIKeyboardTypeNumberPad];
	[self.pinField setReturnKeyType:UIReturnKeyDone];
	[self.pinField becomeFirstResponder];
	[self.confirmPINField setSecureTextEntry:YES];
	[self.confirmPINField setKeyboardType:UIKeyboardTypeNumberPad];
	[self.confirmPINField setReturnKeyType:UIReturnKeyDone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)checkCanFinish:(NSString *)passcode withConfirm:(NSString *)confirmPasscode {
	NSLog(@"%@", passcode);
	NSLog(@"%@", confirmPasscode);
	if ([passcode isEqualToString:confirmPasscode]) {
		[self.finishButton setEnabled:YES];
	} else {
		[self.finishButton setEnabled:NO];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
	NSString *confirmStr = (textField.tag == 2) ? self.pinField.text : self.confirmPINField.text;
	if (textField.tag == 1 && str == self.confirmPINField.text) {
		[self.finishButton setEnabled:YES];
	}
	NSLog(@"%d", str.length);
	if (str.length > self.maxPasscodeLength) {
		[self checkCanFinish:textField.text withConfirm:confirmStr];
		return NO;
	} else if (str.length == self.maxPasscodeLength) {
		[self checkCanFinish:str withConfirm:confirmStr];
	} else {
		[self.finishButton setEnabled:NO];
	}
	return YES;
}

- (IBAction)finish:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *key = [self.mode stringByAppendingString:@"_passcode"];
	[defaults setObject:self.pinField.text forKey:key];
	[self.UIF showAlert:@"Please do the first test." withTitle:@"Saved"];
	BOOL successful = [defaults synchronize];
	if (successful) {
		NSLog(@"%@%@", self.mode, @"Save successful");
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}
@end
