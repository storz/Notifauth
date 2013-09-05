//
//  EntranceViewController.m
//  Notifauth
//
//  Created by 高浪 悟 on 2013/09/04.
//  Copyright (c) 2013年 Satoru Takanami. All rights reserved.
//

#import "EntranceViewController.h"

#define pattern 18

@interface EntranceViewController ()

@end

@implementation EntranceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.defaults = [NSUserDefaults standardUserDefaults];
	self.context = [NSManagedObjectContext defaultContext];
	self.twitterDateFormatter = [[NSDateFormatter alloc] init];
	[self.twitterDateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
	[self.twitterDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	[self.twitterDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	self.UIF = [[UIFunctions alloc] init];
	
    self.twitterEngine = [[RSTwitterEngine alloc] initWithDelegate:self];
}

- (void)checkAuthState {
	if (self.twitterEngine.isAuthenticated) {
        self.accountLabel.text = [NSString stringWithFormat:@"Signed in as @%@.", self.twitterEngine.screenName];
		[self.deleteUserButton setEnabled:YES];
		[self.settingsButton setEnabled:YES];
    } else {
        self.accountLabel.text = @"Not signed in.";
		[self.deleteUserButton setEnabled:NO];
    }
}

- (void)checkUserInfo {
	NSString *storedTesteeId = [self.defaults stringForKey:@"testee_id"];
	if (!storedTesteeId) {
		NSLog(@"No Testee ID");
		storedTesteeId = [self createUserId];
		[self.defaults setObject:storedTesteeId forKey:@"testee_id"];
	}
	self.testeeId = storedTesteeId;
	self.idLabel.text = [NSString stringWithFormat:@"ID: %@", self.testeeId];
}

- (void)checkPreparations {
	self.autoModeTypeTermFrom = [self.defaults objectForKey:@"auto_term_from"];
	self.autoModeTypeTermTerm = [self.defaults objectForKey:@"auto_term_term"];
	self.autoModeTypeTermPasscode = [self.defaults stringForKey:@"auto_term_passcode"];
	if (self.autoModeTypeTermFrom && self.autoModeTypeTermTerm && self.autoModeTypeTermPasscode) {
		NSLog(@"%@", @"Auto Mode Type Term Ready");
		[self.testModeSelector setEnabled:YES forSegmentAtIndex:0];
	} else {
		[self.testModeSelector setEnabled:NO forSegmentAtIndex:0];
	}
	
	self.autoModeTypeCycleTime = [self.defaults objectForKey:@"auto_cycle_time"];
	self.autoModeTypeCycleWeekday = [self.defaults objectForKey:@"auto_cycle_weekday"];
	self.autoModeTypeCyclePasscode = [self.defaults stringForKey:@"auto_cycle_passcode"];
	if (self.autoModeTypeCycleTime && self.autoModeTypeCycleWeekday && self.autoModeTypeCyclePasscode) {
		NSLog(@"%@", @"Auto Mode Type Cycle Ready");
		[self.testModeSelector setEnabled:YES forSegmentAtIndex:1];
	} else {
		[self.testModeSelector setEnabled:NO forSegmentAtIndex:1];
	}
	
	self.manualModeDummy = [self.defaults objectForKey:@"manual_dummy"];
	self.manualModeKey = [self.defaults objectForKey:@"manual_key"];
	self.manualModePasscode = [self.defaults stringForKey:@"manual_passcode"];
	if (self.manualModeDummy && self.manualModeKey && self.manualModePasscode) {
		NSLog(@"%@", @"Manual Mode Ready");
		[self.testModeSelector setEnabled:YES forSegmentAtIndex:2];
	} else {
		[self.testModeSelector setEnabled:NO forSegmentAtIndex:2];
	}
	
	self.pinModePasscode = [self.defaults stringForKey:@"pin_passcode"];
	if (self.pinModePasscode) {
		NSLog(@"%@", @"PIN Mode Ready");
		[self.testModeSelector setEnabled:YES forSegmentAtIndex:3];
	} else {
		[self.testModeSelector setEnabled:NO forSegmentAtIndex:3];
	}
	
	[self.testButton setEnabled:(self.testModeSelector.selectedSegmentIndex >= 0)?YES:NO];
	
	NSDictionary *log = [self.defaults dictionaryForKey:@"results_log"];
	[self.sendButton setEnabled:(log)?YES:NO];
	[self.dumpButton setEnabled:(log)?YES:NO];
}

- (NSString*)createUserId {
	NSString *random = [NSString stringWithFormat:@"%d", arc4random()];
	u_char digest[CC_MD5_DIGEST_LENGTH];
	const char* srcbytes = [random UTF8String];
	CC_MD5(srcbytes, strlen(srcbytes), digest);
	NSMutableString* md5Id = [[NSMutableString alloc] init];
	for (int i = 0 ; i < CC_MD5_DIGEST_LENGTH ; ++i) [md5Id appendFormat: @"%02x", digest[i]];
	return [NSString stringWithString:md5Id];
}

- (void)showResultsLog:(int)index {
	if (!index < 0) return;
	NSDictionary *log = [self.defaults dictionaryForKey:@"results_log"];
	NSArray *results = @[];
	switch (index) {
		case 0: results = [log valueForKey:@"auto_term"]; break;
		case 1: results = [log objectForKey:@"auto_cycle"]; break;
		case 2: results = [log objectForKey:@"manual"]; break;
		case 3: results = [log objectForKey:@"pin"]; break;
		default: break;
	}
	NSMutableString *logStr = [NSMutableString string];
	for (NSDictionary *d in results) {
		[logStr appendString:
			[NSString stringWithFormat:@"%@, %@, %@\n",
			[d objectForKey:@"result"],
			[d objectForKey:@"date"],
			[d objectForKey:@"time"]]];
	}
	self.logLabel.text = logStr;
}

- (void)viewDidAppear:(BOOL)animated {
	[self checkPreparations];
	[self checkUserInfo];
		//self.twitterEngine = [[RSTwitterEngine alloc] initWithDelegate:self];
	[self checkAuthState];
	[self showResultsLog:self.testModeSelector.selectedSegmentIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"addNewUser"]) {
		UINavigationController* addNewUserRoute = (UINavigationController*)[segue destinationViewController];
		AddNewUserViewController* addNewUserViewController
			= (AddNewUserViewController*)addNewUserRoute.topViewController;
		addNewUserViewController.authUrl = self.authUrl;
		addNewUserViewController.delegate = self;
	} else if ([[segue identifier] isEqualToString:@"goToNotificationView"]) {
		NotificationViewController *notificationViewController
		= (NotificationViewController*)[segue destinationViewController];
		if (self.testModeSelector.selectedSegmentIndex == 0) {
			[notificationViewController setMode:@"auto_term"];
			[notificationViewController setCondition:@{@"from": self.autoModeTypeTermFrom,
													   @"term": self.autoModeTypeTermTerm}];
			[notificationViewController setDummy:self.autoModeTypeTermDummy];
			[notificationViewController setKey:self.autoModeTypeTermKey];
			[notificationViewController setPasscode:self.autoModeTypeTermPasscode];
		} else if (self.testModeSelector.selectedSegmentIndex == 1) {
			[notificationViewController setMode:@"auto_cycle"];
			[notificationViewController setCondition:@{@"time": self.autoModeTypeCycleTime,
													   @"weekday": self.autoModeTypeCycleWeekday}];
			[notificationViewController setDummy:self.autoModeTypeCycleDummy];
			[notificationViewController setKey:self.autoModeTypeCycleKey];
			[notificationViewController setPasscode:self.autoModeTypeCyclePasscode];
		} else if (self.testModeSelector.selectedSegmentIndex == 2) {
			[notificationViewController setMode:@"manual"];
			[notificationViewController setCondition:@{}];
			[notificationViewController setDummy:self.manualModeDummy];
			[notificationViewController setKey:self.manualModeKey];
			[notificationViewController setPasscode:self.manualModePasscode];
		}
	} else if ([[segue identifier] isEqualToString:@"goToPasscodeView"]) {
		PasscodeViewController *passcodeViewController
		= (PasscodeViewController*)[segue destinationViewController];
		[passcodeViewController setMode:@"pin"];
		[passcodeViewController setPasscode:self.pinModePasscode];
	}
}

- (void)resetAllData {
	NSArray *tweets = [Tweet findAll];
	for (int i = 0, l = tweets.count; i < l; i++) {
		Tweet *tw = [tweets objectAtIndex:i];
		[tw deleteEntity];
	}
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
	[self.defaults removePersistentDomainForName:appDomain];
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (IBAction)addNewUser:(id)sender {
	[self.addNewUserButton setEnabled:NO];
	[self.twitterEngine authenticateWithCompletionBlock:^(NSError *error) {
		if (error) {
			NSLog(@"%@", error);
		} else {
			[self.navigationController popViewControllerAnimated:YES];
			[self resetAllData];
		}
		[self checkPreparations];
		[self checkUserInfo];
		[self checkAuthState];
		[self initExInfo];
		[self.addNewUserButton setEnabled:YES];
	}];
}

- (IBAction)deleteUser:(id)sender {
	[self.UIF showActionSheet:self title:@"Delete all of your experiment data?" button:@"Delete"];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[self.addNewUserButton setEnabled:YES];
			if (self.twitterEngine) {
				[self.twitterEngine forgetStoredToken];
			}
			self.accountLabel.text = @"Not signed in.";
			[self.deleteUserButton setEnabled:NO];
			[self.settingsButton setEnabled:NO];
			[self.idLabel setText:@"ID:"];
			[self resetAllData];
			[self checkPreparations];
			self.testeeId = @"";
			self.idLabel.text = [NSString stringWithFormat:@"ID: %@", self.testeeId];
			[self initExInfo];
			break;
		case 1:
			break;
	}
}

- (void)initExInfo {
	[self.defaults setObject:[NSNumber numberWithInt:pattern] forKey:@"pattern"];
	[self.defaults setObject:@0 forKey:@"progress_pattern"];
	[self.defaults setObject:@0 forKey:@"progress_day"];
	
	[self.defaults setObject:@0 forKey:@"send_notification"];
	[self.defaults setObject:@0 forKey:@"send_detail"];
}

- (IBAction)settings:(id)sender {
	[self performSegueWithIdentifier:@"goToSettingsView" sender:self];
}

- (IBAction)seeInfo:(id)sender {
	[self performSegueWithIdentifier:@"goToInfoView" sender:self];
}

- (IBAction)test:(id)sender {
	[self.UIF startLoading:self.navigationController];
	self.newestTweetIdFromDB = [Tweet findFirstOrderedByAttribute:@"idStr" ascending:NO];
	self.twitterEngine = [[RSTwitterEngine alloc] initWithDelegate:self];
	[self.twitterEngine getMyTimeline:^(NSError *error, NSData *responseData){
		if (error) {
			[self.UIF endLoading];
			[self.UIF showAlert:@"Failed to load data. Please try again later."];
			[self readyForTestByCondition];
			return;
		}
		if (responseData) {
			NSArray *myTweets = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
			NSLog(@"fetched: %d",myTweets.count);
			[self saveMyTimeline:myTweets];
		}
	} withCount:200 before:@""];
}

- (void)saveMyTimeline:(NSArray*)myTweets {
	if (myTweets.count == 0) return [self readyForTestByCondition];
	for (NSDictionary *tw in myTweets) {
		Tweet* tweet = [Tweet findFirstByAttribute:@"idStr" withValue:[tw valueForKey:@"id_str"]];
		if (!tweet) {
			Tweet* tweet = [Tweet createEntity];
			tweet.idStr = [tw valueForKey:@"id_str"];
			tweet.text = [tw valueForKey:@"text"];
			tweet.screenName = [[tw valueForKey:@"user"] valueForKey:@"name"];
			NSDate *created = [self.twitterDateFormatter dateFromString:[tw valueForKey:@"created_at"]];
			tweet.timeStamp = created;
			tweet.weekday = [NSNumber numberWithInteger:[created weekday] - 1];
			tweet.hour = [NSNumber numberWithInteger:[created hour]];
		} else {
			break;
		}
	}
	[self.context saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
		if (error) {
			[self.UIF endLoading];
			[self.UIF showAlert:@"DBError"];
			return;
		}
		NSDictionary *oldestTweetIdFromFetched = myTweets[myTweets.count - 1];
		NSDate *oldestTweetIdFromFetchedDate = [self.twitterDateFormatter dateFromString:oldestTweetIdFromFetched[@"created_at"]];
		if ([oldestTweetIdFromFetchedDate distanceInDaysToDate:self.newestTweetIdFromDB.timeStamp] < 0) {
			[self.twitterEngine getMyTimeline:^(NSError *error, NSData *responseData){
				if (error) {
					[self.UIF endLoading];
					[self.UIF showAlert:@"Failed to load data. Please try again later."];
					return;
				}
				if (responseData) {
					NSArray *myTweets = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
					NSLog(@"fetched: %d",myTweets.count);
					[self saveMyTimeline:myTweets];
				}
			} withCount:200 before:[[myTweets objectAtIndex:myTweets.count-1] objectForKey:@"id_str"]];
		} else {
			[self readyForTestByCondition];
		}
	}];
}

- (void)readyForTestByCondition {
	if (self.autoModeTypeTermFrom && self.autoModeTypeTermTerm && self.autoModeTypeTermPasscode) {
		NSArray *keys = [Tweet findAllWithPredicate:[self createPredicateFromTermConditon:self.autoModeTypeTermFrom
																				  andTerm:self.autoModeTypeTermTerm
																				  isDummy:NO]];

		NSMutableArray *dummies = [NSMutableArray arrayWithArray:
								   [Tweet findAllWithPredicate:
									[self createPredicateFromTermConditon:self.autoModeTypeTermFrom
																  andTerm:self.autoModeTypeTermTerm
																  isDummy:YES]]];
		if (keys.count == 0) {
			self.autoModeTypeTermKey = [self convertTweetToMinDict:nil];
		} else {
			Tweet *key = [keys objectAtIndex:arc4random_uniform(keys.count)];
			self.autoModeTypeTermKey = [self convertTweetToMinDict:key];
		}
		self.autoModeTypeTermDummy = [self createDummyList:dummies size:9];
	}
	if (self.autoModeTypeCycleTime && self.autoModeTypeCycleWeekday && self.autoModeTypeCyclePasscode) {
		NSArray *keys = [Tweet findAllWithPredicate:[self createPredicateFromCycleCondition:self.autoModeTypeCycleTime
																				 andWeekday:self.autoModeTypeCycleWeekday
																				    isDummy:NO]];
		NSMutableArray *dummies = [NSMutableArray arrayWithArray:
								   [Tweet findAllWithPredicate:[self createPredicateFromCycleCondition:self.autoModeTypeCycleTime
																							andWeekday:self.autoModeTypeCycleWeekday
																				               isDummy:YES]]];
		if (keys.count == 0) {
			self.autoModeTypeCycleKey = [self convertTweetToMinDict:nil];
		} else {
			Tweet *key = [keys objectAtIndex:arc4random_uniform(keys.count)];
			self.autoModeTypeCycleKey = [self convertTweetToMinDict:key];
		}
		self.autoModeTypeCycleDummy = [self createDummyList:dummies size:9];
	}
	if (self.testModeSelector.selectedSegmentIndex == 0) {
		[self performSegueWithIdentifier:@"goToNotificationView" sender:self];
	} else if (self.testModeSelector.selectedSegmentIndex == 1) {
		[self performSegueWithIdentifier:@"goToNotificationView" sender:self];
	}
	[self.UIF endLoading];
	if (self.testModeSelector.selectedSegmentIndex == 2) {
		NSMutableArray *dummies = [NSMutableArray arrayWithArray:self.manualModeDummy];
		NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:(dummies.count < 9) ? dummies.count : 9];
		for (int i = 0, l = (dummies.count < 9) ? dummies.count : 9; i < l; i++) {
			NSNumber *ran = [NSNumber numberWithInt:arc4random_uniform(dummies.count)];
			[tmp addObject:[dummies objectAtIndex:[ran intValue]]];
			[dummies removeObjectAtIndex:[ran intValue]];
		}
		self.manualModeDummy = [tmp copy];
		[self performSegueWithIdentifier:@"goToNotificationView" sender:self];
	} else if (self.testModeSelector.selectedSegmentIndex == 3) {
		[self performSegueWithIdentifier:@"goToPasscodeView" sender:self];
	}
}

- (NSDictionary*)convertTweetToMinDict:(Tweet*)tweet {
	if (tweet == nil) return @{@"text":@"", @"id_str":@"0", @"created_str":@""};
	return @{@"text":tweet.text,
			 @"id_str":tweet.idStr,
			 @"created_str":[self.twitterDateFormatter stringFromDate:tweet.timeStamp]};
}

- (NSArray*)createDummyList:(NSMutableArray*)dummies size:(int)size {
	NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:(dummies.count < size) ? dummies.count : size];
	for (int i = 0, l = (dummies.count < size) ? dummies.count : size; i < l; i++) {
		NSNumber *ran = [NSNumber numberWithInt:arc4random_uniform(dummies.count)];
		Tweet *dummy = [dummies objectAtIndex:[ran intValue]];
		[tmp addObject:[self convertTweetToMinDict:dummy]];
		[dummies removeObjectAtIndex:[ran intValue]];
	}
	return [tmp copy];
}

- (NSPredicate*)createPredicateFromTermConditon:(NSArray*)from andTerm:(NSArray*)term isDummy:(BOOL)isDummy {
	NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate date];
	
	[dateComponents setDay:-[from[3] intValue]];
	[dateComponents setWeek:-[from[2] intValue]];
	[dateComponents setMonth:-[from[1] intValue]];
	[dateComponents setYear:-[from[0] intValue]];
	NSDate *startDate = [calendar dateByAddingComponents:dateComponents toDate:now options:0];
	
	[dateComponents setDay:[term[3] intValue]];
	[dateComponents setWeek:[term[2] intValue]];
	[dateComponents setMonth:[term[1] intValue]];
	[dateComponents setYear:[term[0] intValue]];
	NSDate *endDate = [calendar dateByAddingComponents:dateComponents toDate:startDate options:0];
	return [NSPredicate predicateWithFormat:
			(isDummy) ? @"(timeStamp < %@) OR (timeStamp > %@)" : @"(timeStamp >= %@) AND (timeStamp <= %@)", startDate, endDate];
}

- (NSPredicate*)createPredicateFromCycleCondition:(NSNumber*)time andWeekday:(NSNumber*)weekday isDummy:(BOOL)isDummy {
	return [NSPredicate predicateWithFormat:
			(isDummy) ? @"not((hour = %@) AND (weekday = %@))" : @"(hour = %@) AND (weekday = %@)", [time stringValue], [weekday stringValue]];
}

- (IBAction)selected:(id)sender {
	[self.testButton setEnabled:YES];
	[self showResultsLog:self.testModeSelector.selectedSegmentIndex];
}

- (NSString*)getbase64EncodedJson:(id)dataObject {
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataObject options:NSJSONWritingPrettyPrinted error:nil];
	return [data base64EncodedString];
}

- (IBAction)send:(id)sender {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	if (!picker) return [self.UIF showAlert:@"If you can't mail, please push \"copy experiment data on clipboard\" button and retry other mail applecation." withTitle:@"Failure"];
    picker.mailComposeDelegate = self;
	
	[picker setToRecipients:@[@"satorutakanami@gmail.com"]];
    [picker setSubject:[NSString stringWithFormat:@"Experiment Data / %@", self.testeeId]];
	
	NSString *logStr = [self getbase64EncodedJson:[self.defaults dictionaryForKey:@"results_log"]];
    [picker addAttachmentData:[logStr dataUsingEncoding:NSUTF8StringEncoding]
					 mimeType:@"application/json"
					 fileName:[NSString stringWithFormat:@"exData_%@", self.testeeId]];
	
    NSString *emailBody = @"このまま送信してください";
    [picker setMessageBody:emailBody isHTML:NO];
	[self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)dump:(id)sender {
	UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
	NSString *logStr = [self getbase64EncodedJson:[self.defaults dictionaryForKey:@"results_log"]];
	[pasteBoard setValue:logStr forPasteboardType: @"public.utf8-plain-text"];
	[self.UIF showAlert:@"Paste and send to satorutakanami@gmail.com" withTitle:@"Copied on clipboard"];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result){
        case MFMailComposeResultCancelled:
			[self.UIF showAlert:@"If you can't mail, please push \"copy experiment data on clipboard\" button and retry other mail applecation." withTitle:@"Tips"];
            break;
        case MFMailComposeResultSaved://保存した場合
            break;
        case MFMailComposeResultSent://送信した場合
			[self.UIF showAlert:@"Thanks for sending experiment data!" withTitle:@"Data is sent"];
            break;
        case MFMailComposeResultFailed://失敗
			[self.UIF showAlert:@"If you can't mail, please push \"copy experiment data on clipboard\" button and retry other mail applecation."];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Add New User View Controller Delegate Methods

- (void)cancelAddNewUser {
    NSLog(@"cancel");
    if (self.twitterEngine) {
		[self.twitterEngine cancelAuthentication];
	}
}

- (void)handleURL:(NSURL *)url {
    if ([url.query hasPrefix:@"denied"]) {
        if (self.twitterEngine) [self.twitterEngine cancelAuthentication];
    } else {
        if (self.twitterEngine) [self.twitterEngine resumeAuthenticationFlowWithURL:url];
    }
}

#pragma mark - RSTwitterEngine Delegate Methods

- (void)twitterEngine:(RSTwitterEngine *)engine needsToOpenURL:(NSURL *)url {
	self.authUrl = url;
	[self performSegueWithIdentifier:@"addNewUser" sender:self];
	NSLog(@"%@", url);
}

- (void)twitterEngine:(RSTwitterEngine *)engine statusUpdate:(NSString *)message {
	NSLog(@"%@", message);
}

@end
