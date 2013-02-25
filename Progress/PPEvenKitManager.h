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

@end
