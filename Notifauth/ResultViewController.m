//
//  ResultViewController.m
//  Notifauth
//
//  Created by 高浪 悟 on 11/22/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import "ResultViewController.h"

@interface ResultViewController ()

@end

@implementation ResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.UIF = [[UIFunctions alloc] init];
	self.defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *eachResult = [NSMutableDictionary dictionaryWithDictionary:@{}];
	NSMutableDictionary *log = [NSMutableDictionary dictionaryWithDictionary:[self.defaults dictionaryForKey:@"results_log"]];
	if ([self.mode isEqualToString:@"pin"]) {
		[eachResult setObject:@"none" forKey:@"notification"];
		[eachResult setObject:(self.succeededOnPasscodeView)?@"true":@"false" forKey:@"passcode"];
		[self stateChange:self.succeededOnPasscodeView];
	} else {
		[eachResult setObject:(self.succeededOnNotificationView)?@"true":@"false" forKey:@"notification"];
		[eachResult setObject:(self.succeededOnPasscodeView)?@"true":@"false" forKey:@"passcode"];
		[self stateChange:(self.succeededOnNotificationView && self.succeededOnPasscodeView)];
	}
	NSDate *now = [NSDate date];
	NSDateFormatter *formater = [[NSDateFormatter alloc] init];
	[formater setTimeZone:[NSTimeZone systemTimeZone]];
	[formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[formater setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	
	NSNumber *sendDetail = [self.defaults objectForKey:@"send_detail"];
	
	NSString *nowDateStr = [formater stringFromDate:now];
	NSDictionary *result = @{@"result":        self.resultLabel.text,
							 @"eachResult":    eachResult,
							 @"date":          nowDateStr,
							 @"time":          [NSString stringWithFormat:@"%f", self.measure],
							 @"condition":     self.condition,
							 @"dummyTweet":    ([sendDetail isEqualToNumber:@1]) ? self.dummyTweet : @[],
							 @"keyTweet":      ([sendDetail isEqualToNumber:@1]) ? self.keyTweet : @{},
							 @"selectedTweet": ([sendDetail isEqualToNumber:@1]) ? self.selectedTweet : @{},
							 @"passcode":      self.passcode,
							 @"passcodeInput": self.passcodeInput};
	NSMutableArray *results = [NSMutableArray arrayWithArray:[log objectForKey:self.mode]];
	[results addObject:result];
	[log setObject:results forKey:self.mode];
	[self.defaults setObject:log forKey:@"results_log"];
	[self.defaults synchronize];
	self.timeLabel.text = [NSString stringWithFormat:@"Time: %@ sec", [NSString stringWithFormat:@"%f", self.measure]];
	[self sendNextExperimentNotification];
}

- (void)stateChange:(BOOL)success {
	if (success) {
		self.resultLabel.text = @"Success";
		self.view.backgroundColor = [UIColor colorWithRed:0.596 green:0.984 blue:0.596 alpha:1.0];
	} else {
		self.resultLabel.text = @"Failure";
		self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.714 blue:0.757 alpha:1.0];
	}
}

- (void)sendNextExperimentNotification {
	NSNumber *myPattern = [self.defaults objectForKey:@"pattern"];
	NSNumber *progressPattern = [self.defaults objectForKey:@"progress_pattern"];
	NSNumber *progressDay = [self.defaults objectForKey:@"progress_day"];
	NSString* path = [[NSBundle mainBundle] pathForResource:@"arrays" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSArray *schedule = [dict objectForKey:@"Schedule"];
	NSArray *pattern = [[dict objectForKey:@"Pattern"] objectAtIndex:[myPattern intValue]];
	
	NSLog(@"myPat:%@ progPat:%@ progDay:%@ pattern: %@", myPattern, progressPattern, progressDay, pattern);
	if ([progressDay isEqualToNumber:[NSNumber numberWithInt:schedule.count - 1]]) {
		if ([progressPattern isEqualToNumber:@4]) {
			[self.UIF showAlert:@"Thank you for cooperation of this experiment."
					  withTitle:@"Thanks!"];
			return;
		}
		progressPattern = [NSNumber numberWithInt:[progressPattern intValue] + 1];
		progressDay = @0;
		[self.defaults setObject:progressPattern forKey:@"progress_pattern"];
		[self.defaults setObject:progressDay forKey:@"progress_day"];
		[self.UIF showAlert:[NSString stringWithFormat:@"Please setting %@.", [self getPatternName:pattern[[progressPattern intValue]]]]
				  withTitle:@"Thanks!"];
	} else {
		progressDay = [NSNumber numberWithInt:[progressDay intValue] + 1];
		[self.defaults setObject:progressDay forKey:@"progress_day"];
		int nextDay = [schedule[[progressDay intValue]] intValue];
		[self.UIF setLocalNotification:[NSString stringWithFormat:@"Please do the test of %@.", [self getPatternName:pattern[[progressPattern intValue]]]]
								 after:nextDay];
	}
	NSDateFormatter *formater = [[NSDateFormatter alloc] init];
	[formater setTimeZone:[NSTimeZone systemTimeZone]];
	[formater setDateFormat:@"yyyy/MM/dd"];
	[formater setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	self.progressLabel.text = [NSString stringWithFormat:
							   @"Next: %@", [formater stringFromDate:
											 [NSDate dateWithDaysFromNow:
											  [schedule[[progressDay intValue]] intValue]]]];
}

- (NSString*)getPatternName:(NSNumber*)no {
	if ([no isEqualToNumber:@0]) return @"Auto 1 (Auto Mode Type Term)";
	else if ([no isEqualToNumber:@1]) return @"Auto 2 (Auto Mode Type Cycle)";
	else if ([no isEqualToNumber:@2]) return @"Manual (Manual Mode)";
	else if ([no isEqualToNumber:@3]) return @"PIN (PIN Mode)";
	else return @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToHome:(id)sender {
	[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
