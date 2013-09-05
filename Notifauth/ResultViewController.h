//
//  ResultViewController.h
//  Notifauth
//
//  Created by 高浪 悟 on 11/22/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFunctions.h"

@interface ResultViewController : UIViewController

@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) UIFunctions *UIF;

@property (nonatomic) NSString *mode;
@property (nonatomic) NSDictionary *condition;
@property (nonatomic) NSArray *dummyTweet;
@property (nonatomic) NSDictionary *keyTweet;
@property (nonatomic) NSDictionary *selectedTweet;
@property (nonatomic) NSString *passcode;
@property (nonatomic) NSString *passcodeInput;
@property (nonatomic) BOOL succeededOnNotificationView;
@property (nonatomic) BOOL succeededOnPasscodeView;
@property (nonatomic) float measure;

@property (nonatomic) NSDictionary *result;

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
- (IBAction)backToHome:(id)sender;
@end
