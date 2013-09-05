//
//  AddNewUserViewController.m
//  Notifauth
//
//  Created by 高浪 悟 on 2013/09/04.
//  Copyright (c) 2013年 Satoru Takanami. All rights reserved.
//

#import "AddNewUserViewController.h"
#import "AppDelegate.h"

@interface AddNewUserViewController ()
@end

@implementation AddNewUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.delegate = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if (self.authUrl) {
		[self.webView loadRequest:[NSURLRequest requestWithURL:self.authUrl]];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIWebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"rstwitterengine"] && (self.delegate)) {
        [self.delegate handleURL:request.URL];
		[self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"Loading...");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"Finished");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)cancel:(id)sender {	
	[self.delegate cancelAddNewUser];
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end
