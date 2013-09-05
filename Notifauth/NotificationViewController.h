//
//  NotificationViewController.h
//  Notifauth
//
//  Created by 高浪 悟 on 11/22/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasscodeViewController.h"
#import "NotificationCell.h"

@interface NotificationViewController : UITableViewController <UITableViewDelegate>

@property (nonatomic) NSString *mode;
@property (nonatomic) NSDictionary *condition;
@property (nonatomic) NSArray *dummy;
@property (nonatomic) NSDictionary *key;
@property (nonatomic) NSDictionary *selected;
@property (nonatomic) NSArray *tweetList;
@property (nonatomic) NSString *passcode;
@property (nonatomic) BOOL succeeded;


@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimer *timer;

- (void)selectCell:(UITableViewCell*)cell;

@end
