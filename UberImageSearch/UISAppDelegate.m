//
//  UISAppDelegate.m
//  UberImageSearch
//
//  Created by Kenneth Ballenegger on 5/4/14.
//  Copyright (c) 2014 Kenneth Ballenegger. All rights reserved.
//

#import "UISAppDelegate.h"
#import "UISRootViewController.h"

@implementation UISAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor grayColor];
    self.window.rootViewController = [[UISRootViewController alloc] init];

    [self.window makeKeyAndVisible];
    return YES;
}

@end
