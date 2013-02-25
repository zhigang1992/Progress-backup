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





@end
