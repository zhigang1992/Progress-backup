//
//  main.m
//  Progress
//
//  Created by Kyle Fang on 12/30/12.
//  Copyright (c) 2012 kylefang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PPAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [NUISettings init];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PPAppDelegate class]));
    }
}
