//
//  CRComicService.m
//  xkcd
//
//  Created by Christopher Reimann on 1/8/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

@import AVFoundation;

#import "CRComicService.h"
#import "CRComic.h"

#import "FSNConnection.h"

static CRComicService *_singleton = nil;

@implementation CRComicService {
    NSFileManager *_fm;
    NSString *_cacheDirectory;
    NSString *_thumbsDirectory;
    
    NSOperationQueue *_queue;
    
    NSMutableSet *_comicNumbers;
    NSMutableArray *_comics;
    NSInteger _mostRecentComicNumber;
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [CRComicService new];
    });
}

+ (UIImage *)imageForComic:(CRComic *)comic completion:(ImageFetchCompletion)completionBlock{
    return [_singleton _loadOrFetchImageForComic:comic withCompletion:completionBlock];
}

+ (UIImage *)thumbnailForComic:(CRComic *)comic completion:(ImageFetchCompletion)completionBlock {
    return [_singleton _loadOrFetchThumbnailForComic:comic withCompletion:completionBlock];
}

+ (void)updateComicListFromService {
    [_singleton _fetchComicDataFromService];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _fm = [NSFileManager new];
        _queue = [NSOperationQueue new];
        _queue.maxConcurrentOperationCount = 4;
        _cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        _thumbsDirectory = [_cacheDirectory stringByAppendingPathComponent:@"thumbs"];
        
        NSError *err;
        BOOL isDirectory;
        BOOL exists = [_fm fileExistsAtPath:_thumbsDirectory isDirectory:&isDirectory];
        
        if (!exists) {
            if (![_fm createDirectoryAtPath:_thumbsDirectory withIntermediateDirectories:YES attributes:nil error:&err]) {
                NSLog(@"Error creating thumbs directory: %@", err);
            }
        } else if (!isDirectory) {
            if (![_fm removeItemAtPath:_thumbsDirectory error:&err]) {
                NSLog(@"Error removing item at path: %@", _thumbsDirectory);
            }
            if (![_fm createDirectoryAtPath:_thumbsDirectory withIntermediateDirectories:YES attributes:nil error:&err]) {
                NSLog(@"Error creating thumbs directory: %@", err);
            }
        }
        
        // reload comics when they get fetched
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadComicData) name:@"kCRFetchComics" object:nil];
        
        // clear images under memory pressure
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_clearCachedImages:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [self _loadComicData];
    }
    
    return self;
}

- (void)_clearCachedImages:(NSNotification *)notification {
    for (CRComic *comic in _comics) {
        [comic clearCachedImages];
    }
}

- (NSString*)_pathForComicData {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsDirectory stringByAppendingPathComponent:@"comics.data"];
}

- (void)_loadComicData {
    NSString *comicDataPath = [self _pathForComicData];
    _comics = [[NSKeyedUnarchiver unarchiveObjectWithFile:comicDataPath] mutableCopy];
    _comicNumbers = [NSMutableSet new];
    
    if (_comics.count == 0) {
        _comics = [NSMutableArray new];
        [self _fetchComicDataFromService];
    } else {
        for (CRComic *comic in _comics) {
            [_comicNumbers addObject:@(comic.number)];
        }
    }
}

- (void)_saveComicData {
    NSString *comicDataPath = [self _pathForComicData];
    
    if (![NSKeyedArchiver archiveRootObject:_comics toFile:comicDataPath]) {
        NSLog(@"Failed to save comics to file");
    }
}

- (void)_fetchComicDataFromService {
    static BOOL isRunning;
    // no need to make more than one of these requests at a time
    @synchronized(self) {
        NSURL *serviceURL = [NSURL URLWithString:@"http://sudostudios.com/api/v2/comics"];
        
        if (!isRunning) {
            isRunning = YES;
            NSLog(@"Fetching comics from %@", serviceURL);
            NSNumber *last = [[[_comicNumbers allObjects] sortedArrayUsingSelector:@selector(compare:)] lastObject];
            if (last == nil) { last = @0; }
            FSNConnection *connection = [FSNConnection withUrl:serviceURL method:FSNRequestMethodGET headers:nil parameters:@{ @"fr": last } parseBlock:^id(FSNConnection *c, NSError **err) {
                return [NSJSONSerialization JSONObjectWithData:c.responseData options:NSJSONReadingMutableContainers error:err];
                
            } completionBlock:^(FSNConnection *c) {
                if (c.didSucceed) {
                    NSArray *comics = (NSArray*) c.parseResult[@"comics"];
                    for (NSMutableDictionary *json in comics) {
                        
                        NSDictionary *cleanJSON = [json dictionaryWithoutNull];
                        CRComic *comic = [[CRComic alloc] initWithJSON:cleanJSON];
                        if (![_comics containsObject:comic]) {
                            [_comics addObject:comic];
                        }
                    }
                    
                    [self _saveComicData];
                    _mostRecentComicNumber = ((CRComic*)[_comics lastObject]).number;
                    
                    // notify that we succeeded
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCRFetchComics" object:self];
                    isRunning = NO;
                }
            } progressBlock:nil];
            
            [connection start];
        }
    }
}

#pragma mark - CollectionView
- (NSInteger)numberOfComics {
    return _comics.count;
}

- (CRComic*)comicForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _comics[(_comics.count - 1) - indexPath.item ];
}

#pragma mark - Images
- (UIImage *)_loadOrFetchImageForComic:(CRComic *)comic withCompletion:(ImageFetchCompletion)completion {
    UIImage *img;
    NSString *filePath = [self _imageFilePathForComic:comic];
    
    if ([_fm fileExistsAtPath:filePath]) {
        img = [UIImage imageWithContentsOfFile:filePath];
    } else {
        [self _addImageRequestForComicToQueue:comic completion:completion];
    }
    
    return img;
}

- (UIImage *)_loadOrFetchThumbnailForComic:(CRComic*)comic withCompletion:(ImageFetchCompletion)completion {
    UIImage *img;
    NSString *filePath = [self _thumbnailFilePathForComic:comic];
    
    if ([_fm fileExistsAtPath:filePath]) {
        img = [UIImage imageWithContentsOfFile:filePath];
    } else {
        [self _addImageRequestForComicToQueue:comic completion:completion];
    }
    
    return img;
}

- (void)_addImageRequestForComicToQueue:(CRComic*)comic completion:(ImageFetchCompletion)completion {
    NSBlockOperation *download = [NSBlockOperation blockOperationWithBlock:^{
//        NSLog(@"Fetching image for %@", comic);
        FSNConnection *connection = [FSNConnection withUrl:comic.imageURL method:FSNRequestMethodGET headers:nil parameters:nil parseBlock:nil completionBlock:^(FSNConnection *c) {
            if (c.didSucceed) {
//                NSLog(@"Got image for: %@", comic);
                UIImage *image = [UIImage imageWithData:c.responseData];
                if (image != nil) {
                    NSString *imagePath = [self _imageFilePathForComic:comic];
                    NSString *thumbnailPath = [self _thumbnailFilePathForComic:comic];
                    
                    if (![_fm createFileAtPath:imagePath contents:c.responseData attributes:nil]) {
                        NSLog(@"Something went wrong saving the image for comic %@", comic);
                    }
                    
                    UIImage *thumbnail = [self _thumbnailFromImage:image];
                    if (![_fm createFileAtPath:thumbnailPath contents:UIImagePNGRepresentation(thumbnail) attributes:nil]) {
                        NSLog(@"Something went wrong saving the thumbnail for comic %@", comic);
                    }
                    
                    if (completion) {
                        completion(image, thumbnail);
                    }
                }
            }
        } progressBlock:nil];
        
        [connection start];
    }];
    
    [_queue addOperation:download];
}

- (UIImage *)_thumbnailFromImage:(UIImage *)image {
    static CGFloat THUMBNAIL_WIDTH = 400;
    static CGFloat THUMBNAIL_HEIGHT = 300;
    
    // pad the area that we'll draw the thumbnail inside
    CGRect drawRect = AVMakeRectWithAspectRatioInsideRect(image.size, CGRectMake(10, 10, THUMBNAIL_WIDTH - 20, THUMBNAIL_HEIGHT - 20));
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT), NO, 0.0);
    
    // white background
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT));
    
    // top and bottom borders
    [[UIColor blackColor] set];
    UIBezierPath *borders = [UIBezierPath bezierPath];
    borders.lineWidth = 1.0;
    [borders moveToPoint:CGPointMake(0, 0)];
    [borders addLineToPoint:CGPointMake(THUMBNAIL_WIDTH, 0)];
    [borders moveToPoint:CGPointMake(0, THUMBNAIL_HEIGHT)];
    [borders addLineToPoint:CGPointMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];
    [borders stroke];
    
    // draw the image
    [image drawInRect:drawRect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return thumbnail;
}

- (NSString*)_imageFilePathForComic:(CRComic *)comic {
    return [_cacheDirectory stringByAppendingPathComponent:comic.imageFileName];
}

- (NSString*)_thumbnailFilePathForComic:(CRComic *)comic {
    return [_thumbsDirectory stringByAppendingPathComponent:comic.imageFileName];
}

@end
