//
//  UIFunctions.h
//  Notifauth
//
//  Created by 高浪 悟 on 12/17/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate-Utilities.h"

@interface UIFunctions : NSObject

@property (nonatomic) UIView *loadingView;

- (void)startLoading:(UINavigationController*)nav;
- (void)endLoading;
- (void)showAlert:(NSString*)body;
- (void)showAlert:(NSString*)body withTitle:(NSString*)title;
- (void)setLocalNotification:(NSString*)body after:(int)days;
- (void)showActionSheet:(UIViewController*)vc title:(NSString*)title button:(NSString*)buttonTitle;

@end
