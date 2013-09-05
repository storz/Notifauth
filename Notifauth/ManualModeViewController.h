//
//  ManualModeViewController.h
//  Notifauth
//
//  Created by 高浪 悟 on 2013/10/07.
//  Copyright (c) 2013年 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSTwitterEngine.h"
#import "EnterPINViewController.h"

@interface ManualModeViewController : UITableViewController <RSTwitterEngineDelegate>

@property (strong, nonatomic) RSTwitterEngine *twitterEngine;
@property (nonatomic) UIFunctions *UIF;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) NSDateFormatter *twitterDateFormatter;

@property (strong, nonatomic) IBOutlet UITableView *tweetTable;
@property (strong, nonatomic) NSArray *tweetList;
@property (weak, nonatomic) NSDictionary *keyTweet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@end
