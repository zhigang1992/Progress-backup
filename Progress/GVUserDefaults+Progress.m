//
//  GVUserDefaults+Progress.m
//  Progress
//
//  Created by Kyle Fang on 2/25/13.
//  Copyright (c) 2013 kylefang. All rights reserved.
//

#import "GVUserDefaults+Progress.h"

@implementation GVUserDefaults (Progress)
@dynamic firstTimeLaunchApp;

- (NSDictionary *)setupDefaults{
    return @{@"firstTimeLaunchApp": @YES};
}

@end
