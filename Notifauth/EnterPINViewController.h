//
//  EnterPINViewController.h
//  Notifauth
//
//  Created by 高浪 悟 on 11/22/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFunctions.h"

@interface EnterPINViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic) UIFunctions *UIF;
@property int maxPasscodeLength;
@property (nonatomic, retain) NSString *mode;
@property (weak, nonatomic) IBOutlet UITextField *pinField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPINField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishButton;
- (IBAction)finish:(id)sender;
@end
