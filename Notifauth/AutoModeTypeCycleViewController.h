//
//  AutoModeTypeCycleViewController.h
//  Notifauth
//
//  Created by 高浪 悟 on 11/29/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnterPINViewController.h"
#import "RSTwitterEngine.h"
#import "UIFunctions.h"
#import "NSDate-Utilities.h"
#import "Tweet.h"

@interface AutoModeTypeCycleViewController : UITableViewController <RSTwitterEngineDelegate>

@property (strong, nonatomic) RSTwitterEngine *twitterEngine;
@property (nonatomic) UIFunctions *UIF;
@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) NSDateFormatter *twitterDateFormatter;
@property (nonatomic) NSString *tweets;
@property (nonatomic) NSArray *frequencyRank;
@property (nonatomic) NSArray *weekdayTable;

@property (nonatomic) UIView *loadingView;

@property (weak, nonatomic) IBOutlet UITableViewCell *timeCell;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UITableViewCell *weekdayCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weekdaySelector;

@property (weak, nonatomic) IBOutlet UITableViewCell *exampleCell1;
@property (weak, nonatomic) IBOutlet UITableViewCell *exampleCell2;
@property (weak, nonatomic) IBOutlet UITableViewCell *exampleCell3;

@property (weak, nonatomic) IBOutlet UITableViewCell *suggestionCell1;
@property (weak, nonatomic) IBOutlet UITableViewCell *suggestionCell2;
@property (weak, nonatomic) IBOutlet UITableViewCell *suggestionCell3;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property NSInteger showingPickerRow;
@property NSInteger weekday;
@property NSInteger time;
- (IBAction)selectWeekday:(id)sender;
@end
