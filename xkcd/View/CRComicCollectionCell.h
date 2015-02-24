//
//  CRComicCollectionViewCell.h
//  xkcd
//
//  Created by Christopher Reimann on 1/8/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

@import UIKit;

@class CRComic;
@interface CRComicCollectionCell : UICollectionViewCell

@property (nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) IBOutlet UIImageView *thumbnailView;
@property (nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

- (void)configureWithComic:(CRComic*)comic;

@end
