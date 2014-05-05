//
//  UISQuery.m
//  UberImageSearch
//
//  Created by Kenneth Ballenegger on 5/5/14.
//  Copyright (c) 2014 Kenneth Ballenegger. All rights reserved.
//

#import "UISQuery.h"

#import <AFNetworking/AFNetworking.h>

NSString *const kUISGoogleImageSearchURL = @"https://ajax.googleapis.com/ajax/services/search/images";


@interface UISQuery ()

@property (strong, readwrite) NSMutableArray *results;

@property (strong) NSDictionary *lastResponse;

@property (strong) NSString *query;

@property (readwrite) BOOL isLoading;

@end


@implementation UISQuery

- (id)initWithQuery:(NSString *)query {
    if (self = [self init]) {
        
        self.query = query;
        self.results = [[NSMutableArray alloc] init];
        
        [self performSearchStart:0 forQuery:query];

    }
    return self;
}

- (void)loadMore {
    
    if (self.isLoading) return;
    
    NSInteger nextPage = ((NSNumber *)self.lastResponse[@"cursor"][@"currentPageIndex"]).integerValue + 1;
    NSArray *pages = self.lastResponse[@"cursor"][@"pages"];
    
    // note sure what is up here; api will not return enough pages?
    if ([pages count] <= nextPage) return;
    
    NSInteger nextStart = ((NSNumber *)pages[nextPage][@"start"]).integerValue;

    [self performSearchStart:nextStart forQuery:self.query];
}



- (void)performSearchStart:(NSInteger)start forQuery:(NSString *)queryString {
    
    self.isLoading = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:kUISGoogleImageSearchURL
      parameters:@{@"v": @"1.0", @"rsz": @8, @"q": queryString, @"start": @(start)}
         success:^(__unused AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
             [self handleSearchResponse:(NSDictionary *)responseObject];
         } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error loading google image search: %@", error);
             // TODO: show a real alert view, or something
             self.isLoading = NO;
         }];
    
}


- (void)handleSearchResponse:(NSDictionary *)response {
    
    self.isLoading = NO;

    self.lastResponse = response[@"responseData"];
    
    // not sure why it's forcing me to cast here... wtf
    [(NSMutableArray *)self.results addObjectsFromArray:self.lastResponse[@"results"]];
    
    if (self.reloadCallback) self.reloadCallback();
}

@end
