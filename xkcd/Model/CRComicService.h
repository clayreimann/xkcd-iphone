//
//  CRComicService.h
//  xkcd
//
//  Created by Christopher Reimann on 1/8/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

@import UIKit;

typedef void (^ImageFetchCompletion)(UIImage* image);

@class CRComic;
@interface CRComicService : NSObject

+ (UIImage*)imageForComic:(CRComic*)comic completion:(ImageFetchCompletion)completionBlock;
- (void)downloadAllComics;


- (NSInteger)numberOfComics;
- (CRComic*)comicForItemAtIndexPath:(NSIndexPath*)indexPath;

@end
