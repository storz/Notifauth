//
//  SettingsViewController.m
//  Notifauth
//
//  Created by 高浪 悟 on 11/22/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.defaults = [NSUserDefaults standardUserDefaults];
	self.timeFormatter = [[NSDateFormatter alloc] init];
	[self.timeFormatter setDateFormat:@"h:mm a"];
	[self.timeFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	[self.timeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	self.UIF = [[UIFunctions alloc] init];
	
	NSNumber *sendNotification = [self.defaults objectForKey:@"send_notification"];
	NSString *notificationTime = [self.defaults objectForKey:@"notification_time"];
	NSNumber *sendDetail = [self.defaults objectForKey:@"send_detail"];
	if (sendNotification) [self.notificationSwitch setOn:[sendNotification isEqualToNumber:@1]];
	else [self.defaults setObject:(self.notificationSwitch.on)?@1:@0 forKey:@"send_notification"];
	if (notificationTime) {
		[self.timePicker setDate:[self.timeFormatter dateFromString:notificationTime]];
	} else {
		NSString *timeStr = [self.timeFormatter stringFromDate:self.timePicker.date];
		[self.defaults setObject:timeStr forKey:@"notification_time"];
	}
	if (sendDetail) [self.sendDetailSwitch setOn:[sendDetail isEqualToNumber:@1]];
	else [self.defaults setObject:(self.sendDetailSwitch.on)?@1:@0 forKey:@"send_detail"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section != 0) return;
	if (indexPath.row == 0) {
		[self performSegueWithIdentifier:@"goToAutoModeTypeTermView" sender:self];
	} else if (indexPath.row == 1) {
		[self performSegueWithIdentifier:@"goToAutoModeTypeCycleView" sender:self];
	} else if (indexPath.row == 2) {
		[self performSegueWithIdentifier:@"goToManualModeView" sender:self];
	} else if (indexPath.row == 3) {
		[self performSegueWithIdentifier:@"goToPINModeView" sender:self];
	}
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
		if (indexPath.row == 1) return (self.notificationSwitch.on) ? 100 : 0;
	}
	return 44;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"goToPINModeView"]) {
		EnterPINViewController *enterPINViewController = (EnterPINViewController*)[segue destinationViewController];
		[enterPINViewController setMaxPasscodeLength:5];
		[enterPINViewController setMode:@"pin"];
	}
}

- (IBAction)resetAll:(id)sender {
	[self.UIF showActionSheet:self title:@"Reset all of your settings?" button:@"Reset"];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[self.defaults removeObjectForKey:@"auto_cycle_time"];
			[self.defaults removeObjectForKey:@"auto_cycle_weekday"];
			[self.defaults removeObjectForKey:@"auto_cycle_passcode"];
			[self.defaults removeObjectForKey:@"auto_term_from"];
			[self.defaults removeObjectForKey:@"auto_term_term"];
			[self.defaults removeObjectForKey:@"auto_term_passcode"];
			[self.defaults removeObjectForKey:@"manual_key"];
			[self.defaults removeObjectForKey:@"manual_dummy"];
			[self.defaults removeObjectForKey:@"manual_passcode"];
			[self.defaults removeObjectForKey:@"pin_passcode"];
			break;
		case 1:
			break;
	}
}


- (IBAction)notificationOnOff:(id)sender {
	[self.defaults setObject:(self.notificationSwitch.on)?@1:@0 forKey:@"send_notification"];
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}

- (IBAction)onChangeNotificationTime:(id)sender {
	NSString *timeStr = [self.timeFormatter stringFromDate:self.timePicker.date];
	NSLog(@"%@",timeStr);
	[self.defaults setObject:timeStr forKey:@"notification_time"];
}

- (IBAction)sendDetailOnOFf:(id)sender {
	[self.defaults setObject:(self.sendDetailSwitch.on)?@1:@0 forKey:@"send_detail"];
}

- (IBAction)close:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end
