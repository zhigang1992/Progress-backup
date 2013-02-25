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
            }
            STSuccess();
        }];
    }];
}

@end
