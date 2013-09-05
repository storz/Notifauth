//
//  UIFunctions.m
//  Notifauth
//
//  Created by 高浪 悟 on 12/17/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import "UIFunctions.h"

@implementation UIFunctions

- (void)startLoading:(UINavigationController*)nav {
	if (!self.loadingView) {
		self.loadingView = [[UIView alloc] initWithFrame:nav.view.bounds];
		self.loadingView.backgroundColor = [UIColor blackColor];
		self.loadingView.alpha = 0.5f;
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		[indicator setCenter:CGPointMake(self.loadingView.bounds.size.width / 2, self.loadingView.bounds.size.height / 2)];
		[self.loadingView addSubview:indicator];
		[indicator startAnimating];
		[nav.view addSubview:self.loadingView];
	}
	[self.loadingView setHidden:NO];
}

- (void)endLoading {
	[self.loadingView setHidden:YES];
}

- (void)showAlert:(NSString*)body {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:body delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
}

- (void)showAlert:(NSString*)body withTitle:(NSString*)title {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:body delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
}

- (void)setLocalNotification:(NSString*)body after:(int)days {
	if (days <= 0) return;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber *sendNotification = [defaults objectForKey:@"send_notification"];
	if ([sendNotification isEqualToNumber:@0]) return;
	
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.fireDate = [[NSDate date] dateByAddingDays:days];
	notification.alertBody = body;
	notification.timeZone = [NSTimeZone defaultTimeZone];
	notification.alertAction = @"Start test";
	notification.soundName = UILocalNotificationDefaultSoundName;
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)showActionSheet:(UIViewController*)vc title:(NSString*)title button:(NSString*)buttonTitle {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
	actionSheet.delegate = vc;
	actionSheet.title = title;
	[actionSheet addButtonWithTitle:buttonTitle];
	[actionSheet addButtonWithTitle:@"Cancel"];
	actionSheet.cancelButtonIndex = 1;
	actionSheet.destructiveButtonIndex = 0;
	[actionSheet showInView:vc.view];
}


@end
