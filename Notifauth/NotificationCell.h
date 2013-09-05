//
//  NotificationCell.h
//  Notifauth
//
//  Created by 高浪 悟 on 12/23/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationViewController.h"

@interface NotificationCell : UITableViewCell

@property (nonatomic) NSIndexPath *touchIndexPath;
@property (nonatomic) CGPoint firstTouch;
@property double slideDistance;

@end
