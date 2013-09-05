//
//  PasscodeViewController.h
//  Notifauth
//
//  Created by 高浪 悟 on 11/22/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultViewController.h"

@interface PasscodeViewController : UIViewController

@property int maxPasscodeLength;
@property (nonatomic) NSString *mode;
@property (nonatomic) NSDictionary *condition;
@property (nonatomic) NSArray *dummyTweet;
@property (nonatomic) NSDictionary *keyTweet;
@property (nonatomic) NSDictionary *selectedTweet;
@property (nonatomic) NSString *passcode;
@property (nonatomic) NSString *currentInput;
@property (nonatomic) BOOL succeededOnNotificationView;
@property (nonatomic) float measure;

@property (nonatomic) NSTimeInterval startTime;

- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *passcodeLabel;
- (IBAction)button1:(id)sender;
- (IBAction)button2:(id)sender;
- (IBAction)button3:(id)sender;
- (IBAction)button4:(id)sender;
- (IBAction)button5:(id)sender;
- (IBAction)button6:(id)sender;
- (IBAction)button7:(id)sender;
- (IBAction)button8:(id)sender;
- (IBAction)button9:(id)sender;
- (IBAction)button0:(id)sender;
@end
