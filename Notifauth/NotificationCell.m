//
//  NotificationCell.m
//  Notifauth
//
//  Created by 高浪 悟 on 12/23/13.
//  Copyright (c) 2013 Satoru Takanami. All rights reserved.
//

#import "NotificationCell.h"
#define kDragDistance 135.0

@implementation NotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.firstTouch = [touch locationInView:self];
	[self toggleTableScrolling:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
	
    CGRect frame = [self viewWithTag:1].frame;
	self.slideDistance = touchPoint.x - self.firstTouch.x;
	if (touchPoint.x > self.firstTouch.x) {
        if (self.slideDistance > kDragDistance) {
            self.slideDistance = kDragDistance;
        }
    } else {
        self.slideDistance = 0;
    }
    frame.origin = CGPointMake(self.slideDistance + 39, frame.origin.y);
	[self viewWithTag:1].frame = frame;
	[self layoutIfNeeded];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.slideDistance == kDragDistance) {
		UITouch *touch = [touches anyObject];
		self.firstTouch = [touch locationInView:self];
		id view = [self superview];
		while ([view isKindOfClass:[UITableView class]] == NO) {
			view = [view superview];
		}
		UITableView *tableView = (UITableView *)view;
        [(NotificationViewController*)tableView.delegate selectCell:self];
		return;
    }
    
    [self springBack];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    [self springBack];
}


-(void)springBack {
    CGRect frame = [self viewWithTag:1].frame;
    frame.origin = CGPointMake(39, 28);
    
    [UIView animateWithDuration:0.1
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self viewWithTag:1].frame = frame;
                     }
                     completion:^(BOOL finished){
						 [self toggleTableScrolling:YES];
                     }];
}

-(void)toggleTableScrolling:(BOOL)canScroll {
	id view = [self superview];
	while ([view isKindOfClass:[UITableView class]] == NO) {
		view = [view superview];
	}
    UITableView *tableView = (UITableView *)view;
	tableView.scrollEnabled = canScroll;
}

@end
