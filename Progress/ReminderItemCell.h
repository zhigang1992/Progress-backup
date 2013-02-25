//
//  ReminderItemCell.h
//  Progress
//
//  Created by Kyle Fang on 2/26/13.
//  Copyright (c) 2013 kylefang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReminderItemCell;

@protocol ReminderItemCellDelegate <NSObject>

- (void)deletedByTheUser:(ReminderItemCell *)sender;
- (void)completedByTheUser:(ReminderItemCell *)sender;

@end

@interface ReminderItemCell : UITableViewCell
@property (nonatomic) id <ReminderItemCellDelegate> delegate;
@end
