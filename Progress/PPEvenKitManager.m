//
//  PPEvenKitManager.m
//  Progress
//
//  Created by Kyle Fang on 2/25/13.
//  Copyright (c) 2013 kylefang. All rights reserved.
//

#import "PPEvenKitManager.h"


@interface PPEvenKitManager()

@property (nonatomic, strong) EKEventStore *defaultStore;
@property (nonatomic, strong) EKCalendar *currentCalendar;

@end

@implementation PPEvenKitManager

#pragma mark -
#pragma mark - Set up the evenKitManager

static PPEvenKitManager *_sharedManager;

+ (PPEvenKitManager *)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (id)init{
    self = [super init];
    if (self) {
        self.defaultStore = [[EKEventStore alloc] init];
    }
    return self;
}

- (EKCalendar *)currentCalendar{
    if (!_currentCalendar) {
        _currentCalendar = [self.defaultStore defaultCalendarForNewReminders];
    }
    return _currentCalendar;
}

- (void)setupEventManagerWithCompletionBlock:(void (^)(BOOL))completionBlock{
    if ([self haveAccessToReminder]) {
        completionBlock(YES);
    } else {
        [self.defaultStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
            if (granted) {
                completionBlock(YES);
            } else {
                completionBlock(NO);
            }
        }];
    }
}

- (BOOL)haveAccessToReminder{
    return [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder] == EKAuthorizationStatusAuthorized;
}

#pragma mark - Reminder methods

- (NSString *)defaultReminderListIdentifier{
    if ([self haveAccessToReminder]){
        EKCalendar *defaultReminderList = [self.defaultStore defaultCalendarForNewReminders];
        return defaultReminderList.calendarIdentifier;
    } else {
        return nil;
    }
}


- (NSArray *)reminderLists{
    if ([self haveAccessToReminder]){
        NSArray *reminderLists = [self.defaultStore calendarsForEntityType:EKEntityTypeReminder];
        return [reminderLists copy];
    } else {
        return nil;
    }
}

- (void)getReminderItemsInListWithIdentifier:(NSString *)listIdentifier includeCompleted:(BOOL)includeCompleted includeImcompleted:(BOOL)incluImcomple withCompletionBlock:(void (^)(NSArray *reminedrItems))completion{
    if ([self haveAccessToReminder]){
        if (!incluImcomple && !includeCompleted) {
            completion(nil);
        } else {
            NSPredicate *reminderPredicate = nil;
            EKCalendar *calendar = [self.defaultStore calendarWithIdentifier:listIdentifier];
            if (includeCompleted && incluImcomple) {
                reminderPredicate = [self.defaultStore predicateForRemindersInCalendars:@[calendar]];
            } else if (incluImcomple && !includeCompleted) {
                reminderPredicate = [self.defaultStore predicateForIncompleteRemindersWithDueDateStarting:nil ending:nil calendars:@[calendar]];
            } else if (includeCompleted && !incluImcomple) {
                reminderPredicate = [self.defaultStore predicateForCompletedRemindersWithCompletionDateStarting:nil ending:nil calendars:@[calendar]];
            }
            [self.defaultStore fetchRemindersMatchingPredicate:reminderPredicate completion:^(NSArray *reminders) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completion([reminders copy]);
                }];
            }];
        }
    } else {
        completion(nil);
    }
}


- (BOOL)saveReminder:(EKReminder *)reminder{
    return [self.defaultStore saveReminder:reminder commit:YES error:nil];
}

- (BOOL)deleteReminder:(EKReminder *)reminder{
    return [self.defaultStore removeReminder:reminder commit:YES error:nil];
}

- (EKReminder *)createReminderWithTitle:(NSString *)reminderTitle{
    EKReminder *newReminder = [EKReminder reminderWithEventStore:self.defaultStore];
    newReminder.title = reminderTitle;
    newReminder.calendar = self.currentCalendar;
    if ([self saveReminder:newReminder]) {
        return newReminder;
    } else {
        return nil;
    }
}

@end
