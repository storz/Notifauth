//
//  NotificationViewController.m
//  Notifauth
//
//  Created by 高浪 悟 on 11/22/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
		self.navigationController.interactivePopGestureRecognizer.enabled = NO;
	}
	
}

- (void)viewDidAppear:(BOOL)animated {
	NSMutableArray *tweetList = [NSMutableArray arrayWithArray:self.dummy];
	if (![[self.key objectForKey:@"id_str"] isEqualToString:@"0"]) [tweetList addObject:self.key];
	self.tweetList = [[NSArray arrayWithArray:[self randomizedArray:tweetList]] arrayByAddingObject:@{@"text": @"No match", @"id_str": @"0"}];
	[self.tableView reloadData];
	self.startTime = [[NSDate date] timeIntervalSinceReferenceDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if (![[segue identifier] isEqualToString:@"goToPasscodeView"]) return;
	
	double measure = ([[NSDate date] timeIntervalSinceReferenceDate] - self.startTime);
	PasscodeViewController *passcodeViewController = (PasscodeViewController*)[segue destinationViewController];
	[passcodeViewController setMode:self.mode];
	[passcodeViewController setCondition:self.condition];
	[passcodeViewController setMeasure:measure];
	[passcodeViewController setSucceededOnNotificationView:self.succeeded];
	[passcodeViewController setPasscode:self.passcode];
	[passcodeViewController setKeyTweet:self.key];
	[passcodeViewController setSelectedTweet:self.selected];
	[passcodeViewController setDummyTweet:self.dummy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetList.count;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
	[self updateCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *tweet = [self.tweetList objectAtIndex:indexPath.row];
	CGSize size = [self getSizeOfLabel:[tweet objectForKey:@"text"] maxWidth:270.0];
	return size.height + 40;
}

- (CGSize)getSizeOfLabel:(NSString *)body maxWidth:(float)maxWidth {
	CGRect rect = [body boundingRectWithSize:CGSizeMake(maxWidth, 500)
									 options:NSStringDrawingUsesLineFragmentOrigin
								  attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Hiragino Kaku Gothic ProN"
																				   size:18.0]}
									 context:nil];
	return rect.size;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"tap");
	self.touchIndexPath = indexPath;
	self.selected = [self.tweetList objectAtIndex:indexPath.row];
	if ([[self.selected objectForKey:@"id_str"] isEqualToString:[self.key objectForKey:@"id_str"]]) {
		self.succeeded = YES;
	} else {
		self.succeeded = NO;
	}
	[self performSegueWithIdentifier:@"goToPasscodeView" sender:self];
}*/

- (void)selectCell:(UITableViewCell*)cell {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	self.selected = [self.tweetList objectAtIndex:indexPath.row];
	if ([[self.selected objectForKey:@"id_str"] isEqualToString:[self.key objectForKey:@"id_str"]]) {
		self.succeeded = YES;
	} else {
		self.succeeded = NO;
	}
	NSLog(@"%d",self.succeeded);
	[self performSegueWithIdentifier:@"goToPasscodeView" sender:self];
}

- (NSArray *)randomizedArray:(NSArray *)originalArray {
	NSMutableArray *results = [NSMutableArray arrayWithArray:originalArray];
	int i = [results count];
	
	while(--i) {
		int j = rand() % (i+1);
		[results exchangeObjectAtIndex:i withObjectAtIndex:j];
	}
	
	return [NSArray arrayWithArray:results];
}

@end
