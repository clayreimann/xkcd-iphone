//
//  ViewController.m
//  xkcd
//
//  Created by Christopher Reimann on 1/8/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

#import "CRComicCollectionViewController.h"

#import "CRComicService.h"
#import "CRComicCollectionViewCell.h"

@interface CRComicCollectionViewController () {
    CRComicService *_comicService;
}

@end

@implementation CRComicCollectionViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _comicService = [CRComicService new];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(15, 10, 15, 10);
    
    CGFloat itemWidth = (self.view.bounds.size.width - 30) / 2;
    UICollectionViewFlowLayout *flow = (id) self.collectionViewLayout;
    flow.itemSize = CGSizeMake(itemWidth, 250);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetchComics:) name:@"kCRFetchComics" object:nil];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_comicService numberOfComics];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CRComicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comicCell" forIndexPath:indexPath];
    
    [cell configureWithComic:[_comicService comicForItemAtIndexPath:indexPath]];
    
    return cell;
}

#pragma mark - Notifications
- (void)didFetchComics:(NSNotification*)notification {
    [self.collectionView reloadData];
}

@end
