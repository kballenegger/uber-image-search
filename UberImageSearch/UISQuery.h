//
//  UISQuery.h
//  UberImageSearch
//
//  Created by Kenneth Ballenegger on 5/5/14.
//  Copyright (c) 2014 Kenneth Ballenegger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UISQuery : NSObject

@property (readonly) NSArray *results;

// This callback is called whenever the results have changed,
// ie. after asynchronously loading data.
@property (strong) void(^reloadCallback)();

@property (readonly) BOOL isLoading;

- (id)initWithQuery:(NSString *)query;

- (void)loadMore;

@end
