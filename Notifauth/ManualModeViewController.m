//
//  ManualModeViewController.m
//  Notifauth
//
//  Created by 高浪 悟 on 2013/10/07.
//  Copyright (c) 2013年 Satoru Takanami. All rights reserved.
//

#import "ManualModeViewController.h"

@interface ManualModeViewController ()

@end

@implementation ManualModeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.UIF = [[UIFunctions alloc] init];
	[self.UIF startLoading:self.navigationController];
	
	self.defaults = [NSUserDefaults standardUserDefaults];
	self.twitterDateFormatter = [[NSDateFormatter alloc] init];
	[self.twitterDateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
	[self.twitterDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	[self.twitterDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	
    self.twitterEngine = [[RSTwitterEngine alloc] initWithDelegate:self];
	[self.twitterEngine getMyTimeline:^(NSError *error, NSData *responseData){
		[self.UIF endLoading];
		if (responseData) {
			NSArray *tmp = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
			NSMutableArray *processed = [NSMutableArray array];
			for (int i = 0; i < tmp.count; i++) {
				processed[i] = @{@"id_str": [tmp[i] objectForKey:@"id_str"],
								 @"text": [tmp[i] objectForKey:@"text"]};
			}
			self.tweetList = [processed copy];
			if (!self.tweetList) return NSLog(@"no data");
			self.tweetTable.dataSource = self;
			[self.tweetTable reloadData];
		}
	} withCount:200 before:@""];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tweetTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tweetList count];
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *tweet = [self.tweetList objectAtIndex:indexPath.row];
	UILabel *tweetBodyLabel = (UILabel*)[cell viewWithTag:1];
	tweetBodyLabel.text = [[NSString alloc] initWithFormat:@"%@", [tweet objectForKey:@"text"]];
	tweetBodyLabel.frame = CGRectMake(tweetBodyLabel.frame.origin.x, tweetBodyLabel.frame.origin.y, 270, 5000);
	[tweetBodyLabel setLineBreakMode:NSLineBreakByWordWrapping];
	[tweetBodyLabel setNumberOfLines:0];
	[tweetBodyLabel setPreferredMaxLayoutWidth:270];
	[tweetBodyLabel sizeToFit];
}

- (void)updateCellChecked:(UITableViewCell *)cell {
	if ([cell isSelected]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}

- (void)updateVisibleCells {
    for (UITableViewCell *cell in [self.tableView visibleCells]){
		[self updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

- (void)updateVisibleCellsChecked {
    for (UITableViewCell *cell in [self.tableView visibleCells]){
		[self updateCellChecked:cell];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
	[self updateCell:cell atIndexPath:indexPath];
	[self updateCellChecked:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *tweet = [self.tweetList objectAtIndex:indexPath.row];
	CGSize size = [self getSizeOfLabel:[tweet objectForKey:@"text"] maxWidth:270.0];
	return size.height + 10;
}

- (CGSize)getSizeOfLabel:(NSString *)body maxWidth:(float)maxWidth {
	CGRect rect = [body boundingRectWithSize:CGSizeMake(maxWidth, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Hiragino Kaku Gothic ProN" size:14.0]} context:nil];
	return rect.size;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self updateVisibleCellsChecked];
	self.keyTweet = [self.tweetList objectAtIndex:indexPath.row];
	NSMutableArray *dummyTweetList = [NSMutableArray arrayWithArray:self.tweetList];
	for (int i = 0; i < dummyTweetList.count; i++) {
		NSDictionary *tweet = [dummyTweetList objectAtIndex:i];
		NSString *tweetId = [tweet valueForKey:@"id_str"];
		if ([tweetId isEqualToString:[self.keyTweet valueForKey:@"id_str"]]) {
			[dummyTweetList removeObjectAtIndex:i];
			break;
		}
	}
	[self.defaults setObject:dummyTweetList forKey:@"manual_dummy"];
	[self.defaults setObject:self.keyTweet forKey:@"manual_key"];
	BOOL successful = [self.defaults synchronize];
	if (successful) {
		[self.nextButton setEnabled:YES];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"goToEnterPINView"]) {
		EnterPINViewController *enterPINViewController = (EnterPINViewController*)[segue destinationViewController];
		[enterPINViewController setMaxPasscodeLength:4];
		[enterPINViewController setMode:@"manual"];
	}
}

#pragma mark - RSTwitterEngine Delegate Methods

- (void)twitterEngine:(RSTwitterEngine *)engine needsToOpenURL:(NSURL *)url {}

- (void)twitterEngine:(RSTwitterEngine *)engine statusUpdate:(NSString *)message
{
	NSLog(@"%@", message);
}

@end
