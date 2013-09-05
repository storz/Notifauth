//
//  AutoModeTypeCycleViewController.m
//  Notifauth
//
//  Created by 高浪 悟 on 11/29/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import "AutoModeTypeCycleViewController.h"

@interface AutoModeTypeCycleViewController ()

@end

@implementation AutoModeTypeCycleViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.UIF = [[UIFunctions alloc] init];
	[self.UIF startLoading:self.navigationController];
	
		//init all
	self.defaults = [NSUserDefaults standardUserDefaults];
	self.context = [NSManagedObjectContext defaultContext];
	self.twitterDateFormatter = [[NSDateFormatter alloc] init];
	[self.twitterDateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
	[self.twitterDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	[self.twitterDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	
	self.weekdayTable = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
	
	self.weekday = [[self.defaults objectForKey:@"auto_cycle_weekday"] intValue];
	if (self.weekday >= 0) {
		[self.picker selectRow:self.weekday inComponent:0 animated:YES];
		[self didChangedWeekdaySelector:self.weekday];
	}
	self.time = [[self.defaults objectForKey:@"auto_cycle_time"] intValue];
	if (self.time >= 0) {
		[self.weekdaySelector setSelectedSegmentIndex:self.time];
		[self didChangedTimePicker:self.time];
	}
	[self initCondition];
	
    self.twitterEngine = [[RSTwitterEngine alloc] initWithDelegate:self];
	[self.twitterEngine getMyTimeline:^(NSError *error, NSData *responseData) {
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
	int maxFetchCount = 1000;
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
			[self.UIF showAlert:@"Error"];
			return;
		}
		if ([Tweet countOfEntities] < maxFetchCount && myTweets.count > 0) {
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
		} else {
			[self suggestCondition];
		}
	}];
}

- (void)initCondition {
	NSNumber *time = [self.defaults objectForKey:@"auto_cycle_time"];
	NSNumber *weekday = [self.defaults objectForKey:@"auto_cycle_weekday"];
	[self.picker selectRow:[time intValue] inComponent:0 animated:YES];
	[self didChangedTimePicker:(time != nil) ? [time intValue] : 0];
	[self.weekdaySelector setSelectedSegmentIndex:(weekday != nil) ? [weekday intValue] : -1];
	[self didChangedWeekdaySelector:(weekday != nil) ? [weekday intValue] : -1];
}

- (void)suggestCondition {
	NSArray *storedTweets = [Tweet findAllSortedBy:@"timeStamp" ascending:YES];
	NSMutableArray *table = [NSMutableArray arrayWithCapacity:167];
	for (int i = 0; i < 168; i++) {
		[table addObject:@{@"value":@0}];
	}
	for (Tweet *tweet in storedTweets) {
		int weekday = [tweet.weekday intValue];
		int hour = [tweet.hour intValue];
		int index = weekday * 24 + hour;
		
		table[index] = @{@"weekday": [NSNumber numberWithInt:weekday],
						 @"hour":    [NSNumber numberWithInt:hour],
						 @"value":   @([[table[index] objectForKey:@"value"] intValue] + 1)};
	}
	NSSortDescriptor *sortValue = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:NO];
	NSArray *sortDescArray = [NSArray arrayWithObjects:sortValue, nil];
	NSArray *rank = [table sortedArrayUsingDescriptors:sortDescArray];
	if (rank.count == 1) {
		self.suggestionCell1.textLabel.text = [self convertToLabel:[rank[0] objectForKey:@"weekday"] hour:[rank[0] objectForKey:@"hour"]];
		self.suggestionCell1.detailTextLabel.text = [NSString stringWithFormat:@"%@ tweets", [rank[0] objectForKey:@"value"]];
		self.suggestionCell2.textLabel.text = @"";
		self.suggestionCell2.detailTextLabel.text = @"";
		self.suggestionCell3.textLabel.text = @"";
		self.suggestionCell3.detailTextLabel.text = @"";
	} else if (rank.count == 2) {
		self.suggestionCell1.textLabel.text = [self convertToLabel:[rank[0] objectForKey:@"weekday"] hour:[rank[0] objectForKey:@"hour"]];
		self.suggestionCell1.detailTextLabel.text = [NSString stringWithFormat:@"%@ tweets", [rank[0] objectForKey:@"value"]];
		self.suggestionCell2.textLabel.text = [self convertToLabel:[rank[1] objectForKey:@"weekday"] hour:[rank[1] objectForKey:@"hour"]];
		self.suggestionCell2.detailTextLabel.text = [NSString stringWithFormat:@"%@ tweets", [rank[1] objectForKey:@"value"]];
		self.suggestionCell3.textLabel.text = @"";
		self.suggestionCell3.detailTextLabel.text = @"";
	} else if (rank.count > 2) {
		self.suggestionCell1.textLabel.text = [self convertToLabel:[rank[0] objectForKey:@"weekday"] hour:[rank[0] objectForKey:@"hour"]];
		self.suggestionCell1.detailTextLabel.text = [NSString stringWithFormat:@"%@ tweets", [rank[0] objectForKey:@"value"]];
		self.suggestionCell2.textLabel.text = [self convertToLabel:[rank[1] objectForKey:@"weekday"] hour:[rank[1] objectForKey:@"hour"]];
		self.suggestionCell2.detailTextLabel.text = [NSString stringWithFormat:@"%@ tweets", [rank[1] objectForKey:@"value"]];
		self.suggestionCell3.textLabel.text = [self convertToLabel:[rank[2] objectForKey:@"weekday"] hour:[rank[2] objectForKey:@"hour"]];
		self.suggestionCell3.detailTextLabel.text = [NSString stringWithFormat:@"%@ tweets", [rank[2] objectForKey:@"value"]];
	}
	self.frequencyRank = [rank subarrayWithRange:NSMakeRange(0, 3)];
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
	[self.UIF endLoading];
}

- (NSString*)convertToLabel:(NSNumber*)weekday hour:(NSNumber*)hour {
	NSString *weekdayStr = [self.weekdayTable objectAtIndex:[weekday intValue]];
	return [NSString stringWithFormat:@"%@ %@:00 ~ %@:59", weekdayStr, hour, hour];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
		if (indexPath.row == 1) return 100;
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0 && [self.exampleCell1.textLabel.text isEqualToString:@""]) return 0;
		else if (indexPath.row == 1 && [self.exampleCell2.textLabel.text isEqualToString:@""]) return 0;
		else if (indexPath.row == 2 && [self.exampleCell3.textLabel.text isEqualToString:@""]) return 0;
	} else if (indexPath.section == 2) {
		if (indexPath.row == 0 && [self.suggestionCell1.textLabel.text isEqualToString:@""]) return 0;
		else if (indexPath.row == 1 && [self.suggestionCell2.textLabel.text isEqualToString:@""]) return 0;
		else if (indexPath.row == 2 && [self.suggestionCell3.textLabel.text isEqualToString:@""]) return 0;
	}
	return 44;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	self.lastIndexPath = indexPath;
	if (indexPath.section == 2) {
		NSDictionary *selected = self.frequencyRank[indexPath.row];
		[self.picker selectRow:[[selected objectForKey:@"hour"] intValue] inComponent:0 animated:YES];
		[self didChangedTimePicker:[[selected objectForKey:@"hour"] intValue]];
		[self.weekdaySelector setSelectedSegmentIndex:[[selected objectForKey:@"weekday"] intValue]];
		[self didChangedWeekdaySelector:[[selected objectForKey:@"weekday"] intValue]];
	}
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
	return 1;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 24;
}

-(NSString*)pickerView:(UIPickerView*)pickerView
		   titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	return [NSString stringWithFormat:@"%d", row];
}

- (void)pickerView:(UIPickerView *)correspondPickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[self didChangedTimePicker:[correspondPickerView selectedRowInComponent:0]];
}

- (void)didChangedTimePicker:(int)index {
	self.time = index;
	self.timeCell.detailTextLabel.text = [NSString stringWithFormat:@"%d:00 ~ %d:59", self.time, self.time];
	[self.defaults setObject:[NSNumber numberWithInteger:self.time] forKey:@"auto_cycle_time"];
	BOOL successful = [self.defaults synchronize];
	if (successful) {
		NSLog(@"%@", @"Save successful.");
		[self checkCanGoToNextStep];
	}
}

- (IBAction)selectWeekday:(id)sender {
	[self didChangedWeekdaySelector:self.weekdaySelector.selectedSegmentIndex];
}

- (void)didChangedWeekdaySelector:(int)index {
	if (index < 0) return;
	self.weekday = index;
	NSString *weekdayStr = [self.weekdayTable objectAtIndex:self.weekday];
	self.weekdayCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", weekdayStr];
	[self.defaults setObject:[NSNumber numberWithInteger:self.weekday] forKey:@"auto_cycle_weekday"];
	BOOL successful = [self.defaults synchronize];
	if (successful) {
		NSLog(@"%@", @"Save successful.");
		[self checkCanGoToNextStep];
	}
}

- (void)showExample {
	NSArray *keys = [Tweet findAllSortedBy:@"idStr"
								 ascending:YES
							 withPredicate:[self createPredicateFromCycleCondition:[NSNumber numberWithInt:self.time]
																		andWeekday:[NSNumber numberWithInt:self.weekday]
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

- (NSPredicate*)createPredicateFromCycleCondition:(NSNumber*)time andWeekday:(NSNumber*)weekday isDummy:(BOOL)isDummy {
	return [NSPredicate predicateWithFormat:
			(isDummy) ? @"not((hour = %@) AND (weekday = %@))" : @"(hour = %@) AND (weekday = %@)", [time stringValue], [weekday stringValue]];
}

- (void)checkCanGoToNextStep {
	NSLog(@"%d, %d", self.weekday, self.time);
	if (self.time >=0 && self.weekday >= 0) {
		[self.nextButton setEnabled:YES];
		[self showExample];
	} else {
		[self.nextButton setEnabled:NO];
	};
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"goToEnterPINView"]) {
		EnterPINViewController *enterPINViewController = (EnterPINViewController*)[segue destinationViewController];
		[enterPINViewController setMaxPasscodeLength:4];
		[enterPINViewController setMode:@"auto_cycle"];
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
