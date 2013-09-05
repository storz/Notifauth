//
//  SettingsViewController.h
//  Notifauth
//
//  Created by 高浪 悟 on 11/22/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnterPINViewController.h"
#import "UIFunctions.h"

@interface SettingsViewController : UITableViewController

@property (nonatomic) UIFunctions *UIF;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) NSDateFormatter *timeFormatter;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableViewCell *autoModeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *manualModeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *pinModeCell;

@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UISwitch *sendDetailSwitch;

- (IBAction)close:(id)sender;
@end
