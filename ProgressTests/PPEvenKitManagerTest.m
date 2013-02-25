//
//  PPEvenKitManagerTest.m
//  Progress
//
//  Created by Kyle Fang on 2/25/13.
//  Copyright (c) 2013 kylefang. All rights reserved.
//

#import "PPEvenKitManagerTest.h"
#import "PPEvenKitManager.h"

@implementation PPEvenKitManagerTest

- (void)setUp{
    [super setUp];
}

- (void)tearDown{
    [super tearDown];
}

- (void)testReminderAccessAsync{
    [[PPEvenKitManager sharedManager] setupEventManagerWithCompletionBlock:^(BOOL success) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (!success) {
                STFail(@"Don't have access to user's reminder");
            } else {
                STSuccess();
            }
        }];
    }];
}

- (void)testDefaultReminder{
    if (![[PPEvenKitManager sharedManager] defaultReminderListIdentifier] || [[[PPEvenKitManager sharedManager] defaultReminderListIdentifier] isEqualToString:@""] ) {
        STFail(@"No default reminder identifier");
    }
}

- (void)testReminderLists{
    NSArray *reminderLists = [[PPEvenKitManager sharedManager] reminderLists];
    if (reminderLists.count == 0) {
        STFail(@"0 Reminder lists");
    }
}

- (void)testGetReminderItemsAsync{
    [[PPEvenKitManager sharedManager] getReminderItemsInListWithIdentifier:[[PPEvenKitManager sharedManager] defaultReminderListIdentifier] includeCompleted:YES includeImcompleted:YES withCompletionBlock:^(NSArray *reminders) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (reminders == nil) {
                STFail(@"return nil reminder items");
            } else {
                STSuccess();
            }
        }];
    }];
}

@end
