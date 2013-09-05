//
//  InfoViewController.m
//  Notifauth
//
//  Created by 高浪 悟 on 12/17/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendToDeveloper:(id)sender {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
	
	[picker setToRecipients:@[@"satorutakanami@gmail.com"]];
	[self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)sendToSuperviser:(id)sender {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
	
	[picker setToRecipients:@[@"takada@inf.uec.ac.jp"]];
	[self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result){
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)close:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
