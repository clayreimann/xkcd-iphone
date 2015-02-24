//
//  CRComicService.h
//  xkcd
//
//  Created by Christopher Reimann on 1/8/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

@import UIKit;
#import "NSDictionary+CleanJSON.h"

typedef void (^ImageFetchCompletion)(UIImage* image, UIImage *thumbnail);

@class CRComic;
@interface CRComicService : NSObject

+ (void)updateComicListFromService;
+ (UIImage*)imageForComic:(CRComic*)comic completion:(ImageFetchCompletion)completionBlock;
+ (UIImage*)thumbnailForComic:(CRComic*)comic completion:(ImageFetchCompletion)completionBlock;

- (void)downloadAllComics;
- (NSInteger)numberOfComics;
- (CRComic*)comicForItemAtIndexPath:(NSIndexPath*)indexPath;

@end
