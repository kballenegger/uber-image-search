//
//  UISRootViewController.m
//  UberImageSearch
//
//  Created by Kenneth Ballenegger on 5/4/14.
//  Copyright (c) 2014 Kenneth Ballenegger. All rights reserved.
//

#import "UISRootViewController.h"

#import "UISResultsViewController.h"
#import "UISHistoryViewController.h"


// Constants
const CGSize kUISHomeScreenLogoViewSize = {.width = 280.0, .height = 40.0};
const CGFloat kUISSearchBoxHeight = 30.0;

const CGFloat kUISAnimationDuration = 0.25;


@interface UISRootViewController () <UITextFieldDelegate>

@property (strong) UIImageView *logoView;
@property (strong) UITextField *searchField;

@property (strong) UIViewController *subViewController;

// TODO: change these's type
@property (strong) UISHistoryViewController *historyViewController;
@property (strong) UISResultsViewController *resultsViewController;

@end


@implementation UISRootViewController

// We don't use initWithNibName because we don't use nibs.
- (id)init {
    self = [super init];
    if (self) {
        
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure self's view

    // This needs to happen in the next run loop cycle, otherwise it'll be overriden.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.frame = CGRectMake(0.0, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width,
                                     self.view.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height);
    });
    
    // Draw the logo
    UIImage *logoImage = [UIImage imageNamed:@"uber-logo"];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logoImage];
    logoView.frame = (CGRect){.origin = CGPointZero, .size = kUISHomeScreenLogoViewSize};
    logoView.opaque = NO;
    [self.view addSubview:logoView];
    self.logoView = logoView;
    
    // Create the search bar
    UITextField *searchField = [[UITextField alloc] initWithFrame:
                                CGRectMake(5.0, 5.0, self.view.bounds.size.width - 10, kUISSearchBoxHeight)];
    searchField.layer.cornerRadius = 5.0;
    searchField.backgroundColor = [UIColor whiteColor];
    searchField.returnKeyType = UIReturnKeySearch;
    searchField.placeholder = @"Search Images";
    searchField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)]; // hack to add 5pt of left padding
    searchField.leftViewMode = UITextFieldViewModeAlways;
    searchField.delegate = self;
    
    [self.view addSubview:searchField];
    self.searchField = searchField;
    
    self.resultsViewController = [[UISResultsViewController alloc] init];
    self.historyViewController = [[UISHistoryViewController alloc] init];
    
    __weak UISRootViewController *weakSelf = self;
    self.historyViewController.historicalQuerySelectedCallback = ^(NSString *queryString) {
        [weakSelf performSearch:queryString];
    };
    
    [self relayoutViews];
}

- (void)switchToSubViewController:(UIViewController *)viewController {
    
    [self.subViewController.view removeFromSuperview];
    
    // Animate from the bottom, when there isn't yet one
    if (!self.subViewController) {
        viewController.view.frame = CGRectMake(0.0, self.view.bounds.size.height - 300, self.view.bounds.size.width, 0.0 + 20);
    }
    
    self.subViewController = viewController;
    
    [self.view addSubview:viewController.view];
    // TODO: animations are broken right now. I'll fix it later.
//    [UIView animateWithDuration:kUISAnimationDuration animations:^{
        [self relayoutViews];
//    }];

}

- (void)relayoutViews {
    
    // We only show the expanded main screen if there isn't a subViewController (aka a bottom view)
    if (self.subViewController) {

        self.logoView.alpha = 0.0;
        self.logoView.center = CGPointMake(self.view.center.x, self.logoView.bounds.size.height / 2);
        self.searchField.center = CGPointMake(self.view.center.x, self.searchField.bounds.size.height / 2 + self.searchField.frame.origin.x);

        CGRect subViewControllerFrame;
        subViewControllerFrame.origin = CGPointMake(0.0, self.searchField.bounds.size.height + 2 * self.searchField.frame.origin.x);
        subViewControllerFrame.size = CGSizeMake(self.view.bounds.size.width,
                                                 self.view.bounds.size.height - subViewControllerFrame.origin.y);
        self.subViewController.view.frame = subViewControllerFrame;
        
    } else {
        self.logoView.alpha = 1.0;
        self.logoView.center = CGPointMake(self.view.center.x, self.view.center.y - 5 - self.logoView.bounds.size.height / 2 - 20);
        self.searchField.center = CGPointMake(self.view.center.x, self.view.center.y + 5 + self.searchField.bounds.size.height / 2 - 20);
    }
    
}

#pragma mark Search

- (void)performSearch:(NSString *)queryString {
    if (self.searchField.isFirstResponder) {
        [self.searchField resignFirstResponder];
    }
    self.searchField.text = queryString; // in case it came from the history

    if ([queryString isEqualToString:@""]) {
        [self switchToSubViewController:nil];
        return;
    }
    
    NSLog(@"Searching: %@", queryString);
    
    [self.historyViewController recordSearch:queryString];
    
    [self.resultsViewController performSearch:queryString];
    [self switchToSubViewController:self.resultsViewController];
}

#pragma mark Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField != self.searchField) return NO;
    
    [self.searchField resignFirstResponder];

    // Perform search
    [self performSearch:self.searchField.text];
    
    return YES;
}


#pragma mark Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    [self switchToSubViewController:self.historyViewController];
    [self animateViewSizeFromKeyboardNotification:notification];
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





// didReceiveMemoryWarning not implemented for the sake of brevity


@end
