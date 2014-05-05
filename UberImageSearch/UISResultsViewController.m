//
//  UISResultsViewController.m
//  UberImageSearch
//
//  Created by Kenneth Ballenegger on 5/4/14.
//  Copyright (c) 2014 Kenneth Ballenegger. All rights reserved.
//

#import "UISResultsViewController.h"

NSString *const kUISResultsCellKey = @"UISResultsCellKey";


@interface UISResultsViewController ()

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
    
}

#pragma mark Collection view stuff

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 100;
    } else {
        return 0;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUISResultsCellKey forIndexPath:indexPath];
    
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    [cell.contentView addSubview:label];
    cell.contentView.backgroundColor = [UIColor redColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell #%ld was selected", (long)indexPath.row);
}


@end
