//
//  EntranceViewController.h
//  Notifauth
//
//  Created by 高浪 悟 on 2013/09/04.
//  Copyright (c) 2013年 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <CommonCrypto/CommonCrypto.h>
#import "Tweet.h"
#import "UIFunctions.h"
#import "NSDate-Utilities.h"
#import "RSTwitterEngine.h"
#import "AddNewUserViewController.h"
#import "NotificationViewController.h"
#import "PasscodeViewController.h"

@interface EntranceViewController : UIViewController<MFMailComposeViewControllerDelegate, UIActionSheetDelegate, RSTwitterEngineDelegate, AddNewUserViewControllerDelegate>

@property (nonatomic) NSString *testeeId;

@property (strong, nonatomic) RSTwitterEngine *twitterEngine;
@property (nonatomic) UIFunctions *UIF;
@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) NSDateFormatter *twitterDateFormatter;

@property (nonatomic) NSDictionary *autoModeCondition;
@property (nonatomic) NSArray *autoModeDummy;
@property (nonatomic) NSDictionary *autoModeKey;
@property (nonatomic) NSString *autoModePasscode;

@property (nonatomic) NSArray *autoModeTypeTermFrom;
@property (nonatomic) NSArray *autoModeTypeTermTerm;
@property (nonatomic) NSDictionary *autoModeTypeTermKey;
@property (nonatomic) NSArray *autoModeTypeTermDummy;
@property (nonatomic) NSString *autoModeTypeTermPasscode;

@property (nonatomic) NSNumber *autoModeTypeCycleTime;
@property (nonatomic) NSNumber *autoModeTypeCycleWeekday;
@property (nonatomic) NSDictionary *autoModeTypeCycleKey;
@property (nonatomic) NSArray *autoModeTypeCycleDummy;
@property (nonatomic) NSString *autoModeTypeCyclePasscode;

@property (nonatomic) NSArray *manualModeDummy;
@property (nonatomic) NSDictionary *manualModeKey;
@property (nonatomic) NSString *manualModePasscode;

@property (nonatomic) NSString *pinModePasscode;

@property (nonatomic) Tweet *newestTweetIdFromDB;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteUserButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addNewUserButton;
@property (weak, nonatomic) IBOutlet UIButton *testButton;
@property (weak, nonatomic) IBOutlet UIButton *dumpButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *testModeSelector;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;

- (IBAction)addNewUser:(id)sender;
- (IBAction)deleteUser:(id)sender;
- (IBAction)settings:(id)sender;
- (IBAction)test:(id)sender;
- (IBAction)selected:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)dump:(id)sender;

@property (nonatomic) NSURL *authUrl;
@property BOOL selectedNotification;


@end
