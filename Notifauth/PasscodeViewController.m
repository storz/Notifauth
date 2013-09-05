//
//  PasscodeViewController.m
//  Notifauth
//
//  Created by 高浪 悟 on 11/22/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import "PasscodeViewController.h"

@interface PasscodeViewController ()

@end

@implementation PasscodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
	self.passcodeLabel.text = @"";
	self.currentInput = @"";
	self.maxPasscodeLength = ([self.mode isEqualToString:@"pin"]) ? 5 : 4;
	if (!self.measure) self.measure = 0.0;
	if (!self.dummyTweet) self.dummyTweet = @[];
	if (!self.keyTweet) self.keyTweet = @{};
	if (!self.selectedTweet) self.selectedTweet = @{};
	if (!self.condition) self.condition = @{};
	self.startTime = [[NSDate date] timeIntervalSinceReferenceDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)input:(NSString *)string {
	self.currentInput = [self.currentInput stringByAppendingString:string];
	self.passcodeLabel.text = [self.passcodeLabel.text stringByAppendingString:@"*"];
	if (self.currentInput.length == self.maxPasscodeLength) {
		NSLog(@"%@", self.currentInput);
		[self performSegueWithIdentifier:@"goToResultView" sender:self];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if (![[segue identifier] isEqualToString:@"goToResultView"]) return;
	
	ResultViewController* resultViewController = (ResultViewController*)[segue destinationViewController];
	[resultViewController setMode:self.mode];
	[resultViewController setCondition:self.condition];
	if (![self.mode isEqualToString:@"pin"])
		[resultViewController setSucceededOnNotificationView:self.succeededOnNotificationView];
	[resultViewController setSucceededOnPasscodeView:[self.currentInput isEqualToString:self.passcode]];
	self.measure = self.measure + ([[NSDate date] timeIntervalSinceReferenceDate] - self.startTime);
	[resultViewController setMeasure:self.measure];
	[resultViewController setDummyTweet:self.dummyTweet];
	[resultViewController setKeyTweet:self.keyTweet];
	[resultViewController setSelectedTweet:self.selectedTweet];
	[resultViewController setPasscode:self.passcode];
	[resultViewController setPasscodeInput:self.currentInput];
}

- (IBAction)button1:(id)sender {
	[self input:@"1"];
}

- (IBAction)button2:(id)sender {
	[self input:@"2"];
}

- (IBAction)button3:(id)sender {
	[self input:@"3"];
}

- (IBAction)button4:(id)sender {
	[self input:@"4"];
}

- (IBAction)button5:(id)sender {
	[self input:@"5"];
}

- (IBAction)button6:(id)sender {
	[self input:@"6"];
}

- (IBAction)button7:(id)sender {
	[self input:@"7"];
}

- (IBAction)button8:(id)sender {
	[self input:@"8"];
}

- (IBAction)button9:(id)sender {
	[self input:@"9"];
}

- (IBAction)button0:(id)sender {
	[self input:@"0"];
}
- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}
@end
