//
//  Tweet.h
//  Notifauth
//
//  Created by 高浪 悟 on 12/4/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * idStr;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * weekday;
@property (nonatomic, retain) NSNumber * hour;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * screenName;

@end
