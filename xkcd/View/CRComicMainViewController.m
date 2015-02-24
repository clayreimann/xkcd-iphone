//
//  ViewController.m
//  xkcd
//
//  Created by Christopher Reimann on 1/8/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

#import "CRComicMainViewController.h"

#import "CRComic.h"
#import "CRComicService.h"
#import "CRComicCollectionCell.h"
#import "CRComicHeader.h"

@interface CRComicMainViewController () <UICollectionViewDelegateFlowLayout> {
    NSInteger _numberOfColumns;
    CRComicService *_comicService;
}

@end

@implementation CRComicMainViewController

#pragma mark - lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    _comicService = [CRComicService new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetchComics:) name:@"kCRFetchComics" object:nil];
}

- (void)viewDidLoad {
    self.collectionView.contentInset = UIEdgeInsetsMake(8, 16, 0, 16);
    
    UICollectionViewFlowLayout *layout = (id)self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 8;
    layout.minimumInteritemSpacing = 8;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self _configureForMetrics:self.traitCollection];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    [self _configureForMetrics:newCollection];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self _configureForMetrics:self.traitCollection];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)_configureForMetrics:(UITraitCollection*)metrics {
    _numberOfColumns = 2;
    
    if (metrics.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        _numberOfColumns += 1;
    }
    
    if (metrics.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _numberOfColumns += 1;
    }
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_comicService numberOfComics];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CRComicCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comicCell" forIndexPath:indexPath];
    
    [cell configureWithComic:[_comicService comicForItemAtIndexPath:indexPath]];
    
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"search" forIndexPath:indexPath];
    return view;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CRComic *comic = [_comicService comicForItemAtIndexPath:indexPath];
    NSLog(@"Comic %ld %@", comic.number, comic.title);
}

#pragma mark - UICollectionViewFlowDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIEdgeInsets contentInsets = self.collectionView.contentInset;
    CGFloat width = (self.view.bounds.size.width - contentInsets.left - contentInsets.right);
    width = (width - 8 * (_numberOfColumns)) / _numberOfColumns;
    
    return CGSizeMake(width, 300);
}

#pragma mark - Notifications
- (void)didFetchComics:(NSNotification*)notification {
    [self.collectionView reloadData];
}

@end
