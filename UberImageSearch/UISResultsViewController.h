//
//  UISResultsViewController.h
//  UberImageSearch
//
//  Created by Kenneth Ballenegger on 5/4/14.
//  Copyright (c) 2014 Kenneth Ballenegger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISResultsViewController : UICollectionViewController

+ (instancetype)laidOutViewController;

- (void)performSearch:(NSString *)queryString;

@end
