//
//  UISHistoryViewController.m
//  UberImageSearch
//
//  Created by Kenneth Ballenegger on 5/4/14.
//  Copyright (c) 2014 Kenneth Ballenegger. All rights reserved.
//

#import "UISHistoryViewController.h"

const NSInteger kUISHistoryLimit = 30;
NSString *const kUISHistoryKey = @"UISHistoryKey";



@interface UISHistoryViewController () <UITableViewDataSource, UITableViewDelegate>

// TODO: I meant to keep track of the timestamp of each history entry, so that I could show it in the table view (eg. "2h ago"). Didn't get around to it.
@property (strong) NSMutableArray *history;
@property (strong) NSArray *filteredHistory;

@property (strong) UITableView *view;

@end


@implementation UISHistoryViewController

- (id)init {
    self = [super init];
    if (self) {
        
        // Load history from user defaults (or initialize a new history)
        self.history = [([[NSUserDefaults standardUserDefaults] arrayForKey:kUISHistoryKey] ?: @[])
                        mutableCopy];
        self.filteredHistory = self.history;

        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        // Subscribe to keyboard show / hide notifications.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];

    }
    return self;
}

- (void)applicationWillResignActive:(__unused NSNotification *)notification {
    // Save the  new history
    [[NSUserDefaults standardUserDefaults] setObject:self.history forKey:kUISHistoryKey];
}


#pragma mark Public API

- (void)recordSearch:(NSString *)queryString {
    [self.history addObject:queryString];
    
    if ([self.history count] > kUISHistoryLimit) {
        [self.history removeObjectAtIndex:0];
    }
    
    self.filteredHistory = self.history;
    [self.view reloadData];
}

- (void)filterHistory:(NSString *)prefix {
    // TODO: If I had more time, I would have implemented filtering here: as you type the history only shows prefix-matches entries.
    self.filteredHistory = self.history;
    [self.view reloadData];
}

#pragma mark UI

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set up main table view
    self.view = [[UITableView alloc] init];
    self.view.dataSource = self;
    self.view.delegate = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.filteredHistory count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = ([self.view dequeueReusableCellWithIdentifier:kUISHistoryKey] ?:
                             [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUISHistoryKey]);
    
    cell.textLabel.text = self.filteredHistory[[self.filteredHistory count] - 1 - indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *queryString = self.filteredHistory[[self.filteredHistory count] - 1 - indexPath.row];
    
    if (self.historicalQuerySelectedCallback) self.historicalQuerySelectedCallback(queryString);
}


#pragma mark Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animateViewSizeFromKeyboardNotification:notification];
    });
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self animateViewSizeFromKeyboardNotification:notification];
}

- (void)animateViewSizeFromKeyboardNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    CGRect keyboardStartFrame = ((NSValue *)userInfo[UIKeyboardFrameBeginUserInfoKey]).CGRectValue;
    CGRect keyboardEndFrame = ((NSValue *)userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    
    NSTimeInterval animationDuration = ((NSNumber *)userInfo[UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
    UIViewAnimationCurve animationCurve = ((NSNumber *)userInfo[UIKeyboardAnimationCurveUserInfoKey]).integerValue;
    
    // Before values
    self.view.frame = (CGRect){
        .origin = self.view.frame.origin,
        .size = CGSizeMake(self.view.frame.size.width, keyboardStartFrame.origin.y - self.view.frame.origin.y)
    };
    
    // After values
    void(^animations)() = ^{
        self.view.frame = (CGRect){
            .origin = self.view.frame.origin,
            .size = CGSizeMake(self.view.frame.size.width, keyboardEndFrame.origin.y - self.view.frame.origin.y)
        };
    };
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
}



@end
