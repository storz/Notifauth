//
//  AutoModeTypeTermViewController.h
//  Notifauth
//
//  Created by 高浪 悟 on 12/5/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSTwitterEngine.h"
#import "UIFunctions.h"
#import "ManualModeViewController.h"
#import "NSDate-Utilities.h"
#import "Tweet.h"

@interface AutoModeTypeTermViewController : UITableViewController <RSTwitterEngineDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIFunctions *UIF;
@property (nonatomic) NSArray *condition;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) NSDateFormatter *twitterDateFormatter;
@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSNumber *maxConditionIndex;
@property (nonatomic) NSArray *conditionFrom;
@property (nonatomic) NSArray *conditionTerm;
@property int apiCount;

@property (strong, nonatomic) RSTwitterEngine *twitterEngine;

@property (weak, nonatomic) IBOutlet UITableViewCell *conditionFromCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *conditionTermCell;
@property (weak, nonatomic) IBOutlet UISlider *fromSlider;
@property (weak, nonatomic) IBOutlet UISlider *termSlider;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *exampleCell1;
@property (weak, nonatomic) IBOutlet UITableViewCell *exampleCell2;
@property (weak, nonatomic) IBOutlet UITableViewCell *exampleCell3;
@end

