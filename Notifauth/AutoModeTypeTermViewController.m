	//
	//  SettingsDetailViewController.m
	//  Notifauth
	//
	//  Created by 高浪 悟 on 2013/09/05.
	//  Copyright (c) 2013年 Satoru Takanami. All rights reserved.
	//

#import "AutoModeTypeTermViewController.h"

@interface AutoModeTypeTermViewController ()

@end

@implementation AutoModeTypeTermViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.UIF = [[UIFunctions alloc] init];
	[self.UIF startLoading:self.navigationController];
	
	self.defaults = [NSUserDefaults standardUserDefaults];
	self.context = [NSManagedObjectContext defaultContext];
	self.twitterDateFormatter = [[NSDateFormatter alloc] init];
	[self.twitterDateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
	[self.twitterDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	[self.twitterDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	
	NSString* path = [[NSBundle mainBundle] pathForResource:@"arrays" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	self.condition = [dict objectForKey:@"Term"];
	[self.fromSlider addTarget:self action:@selector(showExample)forControlEvents:UIControlEventTouchUpInside];
	[self.termSlider addTarget:self action:@selector(showExample)forControlEvents:UIControlEventTouchUpInside];
	self.apiCount = 0;
    self.twitterEngine = [[RSTwitterEngine alloc] initWithDelegate:self];
	[self.twitterEngine getMyTimeline:^(NSError *error, NSData *responseData){
		self.apiCount++;
		NSLog(@"API Access: %d", self.apiCount);
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
	} withCount:200 before:@""];
}

- (void)saveMyTimeline:(NSArray*)myTweets {
	self.apiCount++;
	NSLog(@"API Access: %d", self.apiCount);
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
		NSLog(@"Saved: %d", myTweets.count);
		if ([Tweet countOfEntities] < 1000 && myTweets.count > 0) {
			[self.twitterEngine getMyTimeline:^(NSError *error, NSData *responseData){
				if (error) {
					[self.UIF endLoading];
					[self.UIF showAlert:@"Failed to load data. Please try again later."];
					return;
				}
				if (responseData) {
					NSArray *myTweets = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
					NSLog(@"fetched: %d",myTweets.count);
					if (myTweets.count == 1) {
						[self.UIF endLoading];
						return;
					}
					[self saveMyTimeline:myTweets];
				}
			} withCount:200 before:[[myTweets objectAtIndex:myTweets.count-1] objectForKey:@"id_str"]];
		} else {//取得終了
			[self setFromMax];
		}
	}];
}

- (void)setFromMax {//スライダー最大値の設定
	NSLog(@"setFromMax: %d",self.apiCount);
	Tweet *oldestTweet = [Tweet findFirstOrderedByAttribute:@"timeStamp" ascending:YES];
	NSDate* now = [NSDate date];

	int len = self.condition.count;
	for (int i = 1; i < len; i++) {
		NSArray *d = self.condition[i];
		NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
		NSCalendar* calendar = [NSCalendar currentCalendar];
		[dateComponents setDay:[d[3] intValue]];
		[dateComponents setWeek:[d[2] intValue]];
		[dateComponents setMonth:[d[1] intValue]];
		[dateComponents setYear:[d[0] intValue]];
		NSDate *addedAll = [calendar dateByAddingComponents:dateComponents toDate:oldestTweet.timeStamp options:0];
		
		if ([addedAll distanceInDaysToDate:now] < 0) {
			self.maxConditionIndex = [NSNumber numberWithInt:i];
			break;
		}
	}
	NSArray *fromLoaded = [self.defaults objectForKey:@"auto_term_from"];
	int fromLoadedIndex = (int)[self.maxConditionIndex floatValue]/2;
	if (fromLoaded) {
		for (int i = 0; i < len; i++) {
			if ([fromLoaded isEqualToArray:self.condition[i]]) fromLoadedIndex = i;
		}
	}
	NSArray *termLoaded = [self.defaults objectForKey:@"auto_term_term"];
	int termLoadedIndex = (int)[self.maxConditionIndex floatValue]/4;
	if (fromLoaded) {
		for (int i = 0; i < len; i++) {
			if ([termLoaded isEqualToArray:self.condition[i]]) termLoadedIndex = i;
		}
	}
	[self.fromSlider setMaximumValue:[self.maxConditionIndex floatValue]];
	[self.fromSlider setValue:fromLoadedIndex];
	[self.termSlider setMaximumValue:[self.maxConditionIndex floatValue]];
	[self.termSlider setValue:termLoadedIndex];
	[self refreshSliders];
	[self showExample];
	[self.UIF endLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)fromChanged:(id)sender {
	if (self.termSlider.value > self.fromSlider.value) {
		self.termSlider.value = self.fromSlider.value;
	}
	[self refreshSliders];
}

- (IBAction)termChanged:(id)sender {
	if (self.termSlider.value > self.fromSlider.value) {
		self.fromSlider.value = self.termSlider.value;
	}
	[self refreshSliders];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
		if (indexPath.row == 0 && [self.exampleCell1.textLabel.text isEqualToString:@""]) return 0;
		else if (indexPath.row == 1 && [self.exampleCell2.textLabel.text isEqualToString:@""]) return 0;
		else if (indexPath.row == 2 && [self.exampleCell3.textLabel.text isEqualToString:@""]) return 0;
	}
    return 44;
}

- (void)refreshSliders {
	self.conditionFromCell.detailTextLabel.text = [[self replaceDate:[self.condition objectAtIndex:roundf(self.fromSlider.value)]] stringByAppendingString:@" ago"];
	self.conditionTermCell.detailTextLabel.text = [[self replaceDate:[self.condition objectAtIndex:roundf(self.termSlider.value)]] stringByAppendingString:@""];
	self.conditionFrom = [self.condition objectAtIndex:roundf(self.fromSlider.value)];
	self.conditionTerm = [self.condition objectAtIndex:roundf(self.termSlider.value)];
	[self.defaults setObject:self.conditionFrom forKey:@"auto_term_from"];
	[self.defaults setObject:self.conditionTerm forKey:@"auto_term_term"];
	BOOL successful = [self.defaults synchronize];
	if (successful) {
		[self checkCanGoToNextStep];
	}
}

- (void)showExample {
	NSArray *keys = [Tweet findAllSortedBy:@"idStr"
								 ascending:YES
							 withPredicate:[self createPredicateFromTermConditon:self.conditionFrom
																		 andTerm:self.conditionTerm
																		 isDummy:NO]];
	if (keys.count == 0) {
		self.exampleCell1.textLabel.text = @"Not found";
		self.exampleCell2.textLabel.text = @"";
		self.exampleCell3.textLabel.text = @"";
	} else if (keys.count == 1) {
		Tweet *oldest = keys[0];
		self.exampleCell1.textLabel.text = oldest.text;
		self.exampleCell2.textLabel.text = @"";
		self.exampleCell3.textLabel.text = @"";
	} else if (keys.count == 2) {
		Tweet *oldest = keys[0];
		Tweet *newest = keys[1];
		self.exampleCell1.textLabel.text = oldest.text;
		self.exampleCell2.textLabel.text = @"";
		self.exampleCell3.textLabel.text = newest.text;
	} else {
		Tweet *oldest = keys[0];
		Tweet *center = keys[(int)keys.count/2];
		Tweet *newest = keys[keys.count - 1];
		self.exampleCell1.textLabel.text = oldest.text;
		self.exampleCell2.textLabel.text = center.text;
		self.exampleCell3.textLabel.text = newest.text;
	}
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}

- (NSPredicate*)createPredicateFromTermConditon:(NSArray*)from andTerm:(NSArray*)term isDummy:(BOOL)isDummy {
	NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate date];
	
	if ([from[3] intValue] > 0) [dateComponents setDay:-[from[3] intValue]];
	else [dateComponents setHour:-12];
	[dateComponents setWeek:-[from[2] intValue]];
	[dateComponents setMonth:-[from[1] intValue]];
	[dateComponents setYear:-[from[0] intValue]];
	NSDate *startDate = [calendar dateByAddingComponents:dateComponents toDate:now options:0];
	
	if ([term[3] intValue] > 0) [dateComponents setDay:[term[3] intValue]];
	else [dateComponents setHour:12];
	[dateComponents setWeek:[term[2] intValue]];
	[dateComponents setMonth:[term[1] intValue]];
	[dateComponents setYear:[term[0] intValue]];
	NSDate *endDate = [calendar dateByAddingComponents:dateComponents toDate:startDate options:0];
	return [NSPredicate predicateWithFormat:
			(isDummy) ? @"(timeStamp < %@) OR (timeStamp > %@)" : @"(timeStamp >= %@) AND (timeStamp <= %@)", startDate, endDate];
}

- (void)checkCanGoToNextStep {
	if (self.conditionFrom && self.conditionTerm) {
		[self.nextButton setEnabled:YES];
	} else {
		[self.nextButton setEnabled:NO];
	};
}

- (NSString *)replaceDate:(NSArray *)input {//ラベル用の表記に変換
	if ([input[3] isEqualToNumber: @0.5]) return @"12 hours";
	NSString *day = ([input[3] isEqualToNumber: @0]) ? @"" : [NSString stringWithFormat:([input[3] isEqualToNumber: @1]) ? @"%@ day" : @"%@ days", input[3]];
	NSString *week = ([input[2] isEqualToNumber: @0]) ? @"" : [NSString stringWithFormat:([input[2] isEqualToNumber: @1]) ? @"%@ week" : @"%@ weeks", input[2]];
	NSString *month = ([input[1] isEqualToNumber: @0]) ? @"" : [NSString stringWithFormat:([input[1] isEqualToNumber: @1]) ? @"%@ month" : @"%@ months", input[1]];
	NSString *year = ([input[0] isEqualToNumber: @0]) ? @"" : [NSString stringWithFormat:([input[0] isEqualToNumber: @1]) ? @"%@ year" : @"%@ years", input[0]];
	return [NSString stringWithFormat:@"%@%@%@%@",year,month,week,day];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"goToEnterPINView"]) {
		EnterPINViewController *enterPINViewController = (EnterPINViewController*)[segue destinationViewController];
		[enterPINViewController setMaxPasscodeLength:4];
		[enterPINViewController setMode:@"auto_term"];
	}
}

#pragma mark - RSTwitterEngine Delegate Methods

- (void)twitterEngine:(RSTwitterEngine *)engine needsToOpenURL:(NSURL *)url {
	[self.navigationController popToRootViewControllerAnimated:YES];
	NSLog(@"%@", url);
}

- (void)twitterEngine:(RSTwitterEngine *)engine statusUpdate:(NSString *)message {
	NSLog(@"%@", message);
}

@end
