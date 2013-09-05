//
//  AddNewUserViewController.h
//  Notifauth
//
//  Created by 高浪 悟 on 2013/09/04.
//  Copyright (c) 2013年 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddNewUserViewControllerDelegate;

@interface AddNewUserViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak)id <AddNewUserViewControllerDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
@property (retain,nonatomic)NSURL *authUrl;

- (IBAction)cancel:(id)sender;

@end

@protocol AddNewUserViewControllerDelegate <NSObject>
- (void)cancelAddNewUser;
- (void)handleURL:(NSURL *)url;
@end