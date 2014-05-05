//
//  UISResultsViewController.m
//  UberImageSearch
//
//  Created by Kenneth Ballenegger on 5/4/14.
//  Copyright (c) 2014 Kenneth Ballenegger. All rights reserved.
//

#import "UISResultsViewController.h"

#import "UISQuery.h"

#import <AFNetworking/UIImageView+AFNetworking.h>


NSString *const kUISResultsCellKey = @"UISResultsCellKey";


@interface UISResultsViewController ()

@property (strong) UISQuery *currentQuery;

@end


@implementation UISResultsViewController


+ (instancetype)laidOutViewController {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    UISResultsViewController *viewController = [[UISResultsViewController alloc] initWithCollectionViewLayout:layout];

    layout.itemSize = CGSizeMake(106, 106);
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    return viewController;
}


- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kUISResultsCellKey];
}


- (void)performSearch:(NSString *)queryString {
    
    UISQuery *query = [[UISQuery alloc] initWithQuery:queryString];
    self.currentQuery = query;
    query.reloadCallback = ^{
        [self.collectionView reloadData];
    };
    
    [self.collectionView reloadData];
}


#pragma mark Collection view stuff

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.currentQuery.results count] + ([self.currentQuery isLoading] ? 1 : 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // if we're seeing one of the last 5 items, load more
    if (indexPath.row >= [self.currentQuery.results count] - 5) {
        [self.currentQuery loadMore];
    }
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUISResultsCellKey forIndexPath:indexPath];
    
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    
    // if this is the loading view... the one after the last loaded image
    if (indexPath.row >= [self.currentQuery.results count]) {
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = cell.center;
        
    } else {
        // otherwise, it's a regular cell
        
//        UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.text = self.currentQuery.results[indexPath.row][@"title"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        [imageView setImageWithURL:[NSURL URLWithString:self.currentQuery.results[indexPath.row][@"tbUrl"]]];
        [cell.contentView addSubview:imageView];
        cell.contentView.backgroundColor = [UIColor redColor];

    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell #%ld was selected", (long)indexPath.row);
}


@end
