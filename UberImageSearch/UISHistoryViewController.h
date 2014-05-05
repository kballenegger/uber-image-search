//
//  UISHistoryViewController.h
//  UberImageSearch
//
//  Created by Kenneth Ballenegger on 5/4/14.
//  Copyright (c) 2014 Kenneth Ballenegger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISHistoryViewController : UIViewController

@property (strong) void(^historicalQuerySelectedCallback)(NSString *);

- (void)recordSearch:(NSString *)queryString;

- (void)filterHistory:(NSString *)prefix;

@end
