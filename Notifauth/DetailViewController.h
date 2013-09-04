//
//  DetailViewController.h
//  Notifauth
//
//  Created by 高浪 悟 on 2013/09/04.
//  Copyright (c) 2013年 Satoru Takanami. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
