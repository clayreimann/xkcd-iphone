//
//  CRComicService.m
//  xkcd
//
//  Created by Christopher Reimann on 1/8/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

#import "CRComicService.h"
#import "CRComic.h"

#import "FSNConnection.h"

static CRComicService *_singleton = nil;

@implementation CRComicService {
    NSString *_cacheDirectory;
    NSFileManager *_fm;
    NSOperationQueue *_queue;
    
    NSInteger _mostRecentComicNumber;
    NSMutableArray *_comics;
}

+ (void)initialize {
    _singleton = [CRComicService new];
}

+ (UIImage *)imageForComic:(CRComic *)comic completion:(ImageFetchCompletion)completionBlock{
    return [_singleton _loadOrFetchImageForComic:comic withCompletion:completionBlock];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _fm = [NSFileManager new];
        _queue = [NSOperationQueue new];
        _queue.maxConcurrentOperationCount = 4;
        _cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        
        [self _loadComicData];
    }
    
    return self;
}

- (void)_loadComicData {
    if (_comics.count == 0) {
        _comics = [NSMutableArray new];
        [self _fetchComicData];
    }
}

- (void)_fetchComicData {
    NSURL *serviceURL = [NSURL URLWithString:@"http://sudostudios.com/api/v2/comics"];
    FSNConnection *connection = [FSNConnection withUrl:serviceURL method:FSNRequestMethodGET headers:nil parameters:@{ @"fr": @(_mostRecentComicNumber) } parseBlock:^id(FSNConnection *c, NSError **err) {
        return [NSJSONSerialization JSONObjectWithData:c.responseData options:NSJSONReadingMutableContainers error:err];
        
    } completionBlock:^(FSNConnection *c) {
        if (c.didSucceed) {
            NSArray *comics = (NSArray*) c.parseResult[@"comics"];
            for (NSMutableDictionary *json in comics) {
                NSMutableDictionary *cleanJSON = [NSMutableDictionary new];
                for (NSString *key in json) {
                    if ([json[key] isKindOfClass:[NSNull class]]) {
                        cleanJSON[key] = @"";
                    } else {
                        cleanJSON[key] = json[key];
                    }
                }
                CRComic *comic = [[CRComic alloc] initWithJSON:cleanJSON];
                [_comics addObject:comic];
            }
            _mostRecentComicNumber = ((CRComic*)[_comics lastObject]).number;
            NSLog(@"Now we have %ld comics", _mostRecentComicNumber);
            
            // notify that we succeeded
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCRFetchComics" object:self];
        }
    } progressBlock:nil];
    
    [connection start];
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

- (void)_addImageRequestForComicToQueue:(CRComic*)comic completion:(ImageFetchCompletion)completion {
    NSBlockOperation *download = [NSBlockOperation blockOperationWithBlock:^{
        FSNConnection *connection = [FSNConnection withUrl:comic.imageURL method:FSNRequestMethodGET headers:nil parameters:nil parseBlock:nil completionBlock:^(FSNConnection *c) {
            if (c.didSucceed) {
                UIImage *image = [UIImage imageWithData:c.responseData];
                if (image != nil) {
                    NSString *imagePath = [self _imageFilePathForComic:comic];
                    if (![_fm createFileAtPath:imagePath contents:c.responseData attributes:nil]) {
                        NSLog(@"Something went wrong saving the image for comic %@", comic);
                    }
                    if (completion) {
                        completion(image);
                    }
                }
            }
        } progressBlock:nil];
        
        [connection start];
    }];
    
    [_queue addOperation:download];
}

- (NSString*)_imageFilePathForComic:(CRComic *)comic {
    return [_cacheDirectory stringByAppendingPathComponent:
            [NSString stringWithFormat:@"%ld.%@", (long)comic.number, [comic.imageURL pathExtension]]];
}

@end
