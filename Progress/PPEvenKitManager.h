//
//  PPEvenKitManager.h
//  Progress
//
//  Created by Kyle Fang on 2/25/13.
//  Copyright (c) 2013 kylefang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface PPEvenKitManager : NSObject

+ (PPEvenKitManager *)sharedManager;

- (void)setupEventManagerWithCompletionBlock:(void (^)(BOOL success))completionBlock;


//Reminder methods

- (NSString *)defaultReminderListIdentifier;

- (NSArray *)reminderLists;

- (void)getReminderItemsInListWithIdentifier:(NSString *)listIdentifier includeCompleted:(BOOL)includeCompleted includeImcompleted:(BOOL)incluImcomple withCompletionBlock:(void (^)(NSArray *reminedrItems))completion;

- (BOOL)saveReminder:(EKReminder *)reminder;

- (BOOL)deleteReminder:(EKReminder *)reminder;

@end
