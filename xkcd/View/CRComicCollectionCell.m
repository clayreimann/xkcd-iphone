//
//  CRComicCollectionViewCell.m
//  xkcd
//
//  Created by Christopher Reimann on 1/8/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

#import "CRComicCollectionCell.h"

#import "CRComic.h"

@implementation CRComicCollectionCell

- (void)configureWithComic:(CRComic *)comic {
    UIImage *comicImage = [comic getThumbnailWithCompletion:^(UIImage *image, UIImage *thumbnail) {
        self.thumbnailView.image = thumbnail;
        [self.loadingView stopAnimating];
    }];
    
    if (comicImage != nil) {
        self.thumbnailView.image = comicImage;
        [self.loadingView stopAnimating];
    }
    
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", comic.number];
    self.titleLabel.text = comic.title;
}

@end
