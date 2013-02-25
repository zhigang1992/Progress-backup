//
//  ProgressTests.m
//  ProgressTests
//
//  Created by Kyle Fang on 12/30/12.
//  Copyright (c) 2012 kylefang. All rights reserved.
//

#import "ProgressTests.h"

#import "GVUserDefaults+Progress.h"

@implementation ProgressTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testUserDefaust{
    
    
    if (![GVUserDefaults standardUserDefaults].firstTimeLaunchApp) {
        STFail(@"Not first launch");
    }
        
}

@end
