//
//  UISQuery.m
//  UberImageSearch
//
//  Created by Kenneth Ballenegger on 5/5/14.
//  Copyright (c) 2014 Kenneth Ballenegger. All rights reserved.
//

#import "UISQuery.h"

#import <AFNetworking/AFNetworking.h>

#import <ATValidations/ATValidations.h>

NSString *const kUISGoogleImageSearchURL = @"https://ajax.googleapis.com/ajax/services/search/images";


@interface UISQuery ()

@property (strong, readwrite) NSMutableArray *results;

@property (strong) NSDictionary *lastResponse;

@property (strong) NSString *query;

@property (readwrite) BOOL isLoading;

@end



ATVPredicate *UISGoogleImageSearchResponseValidation(void);
ATVPredicate *UISGoogleImageSearchResponseValidation() {
    static ATVPredicate *instance = nil;
    if (!instance) {
        // The first argument is a key-predicate mapping of what we expect the data to look like.
        // The second argument (BOOL) specifies whether extra non-specified keys in the data is considered an error. Here, we allow it.
        // Essentially, we're only validating the parts of the response that we're using. If Google were to add a new response key, it would not break this client.
        instance = ATVDictionary(
                    @{
                      @"responseData": ATVDictionary(
                        @{
                          @"cursor": ATVDictionary(
                            @{
                              @"currentPageIndex": ATVNumber(),
                              @"pages": ATVArrayOf(ATVDictionary(@{@"start": ATVString()}, YES))
                              }, YES),
                          @"results": ATVArrayOf(ATVDictionary(
                            @{
                              @"tbUrl": ATVMatchesBlock(^BOOL(id object, NSError *__autoreleasing *error) {
                                    // Test that this is a valid URL by testing whether we can successfully create a NSURL
                                    if (!ATVAssert([object isKindOfClass:[NSString class]], @"must be a String representation of a URL", error)) return NO;
                                    NSURL *url = [NSURL URLWithString:object];
                                    return ATVAssert(url && url.scheme && url.host, @"must be a String representation of a URL", error);
                                })
                              }, YES))
                          }, YES)
                      }, YES);
    }
    return instance;
}



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
    
    NSInteger nextStart = ((NSString *)pages[nextPage][@"start"]).integerValue;

    [self performSearchStart:nextStart forQuery:self.query];
}



- (void)performSearchStart:(NSInteger)start forQuery:(NSString *)queryString {
    
    self.isLoading = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:kUISGoogleImageSearchURL
      parameters:@{@"v": @"1.0", @"rsz": @8, @"q": queryString, @"start": @(start)}
         success:^(__unused AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
             
             NSError *error;
             if ([responseObject matchesATVPredicate:UISGoogleImageSearchResponseValidation() error:&error]) {
                 [self handleSearchResponse:(NSDictionary *)responseObject];
             } else {
                 NSLog(@"API response did not match expected pattern: %@", error);
                 self.isLoading = NO;
             }
             
             
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
