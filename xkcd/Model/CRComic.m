//
//  CRComic.m
//  xkcd
//
//  Created by Christopher Reimann on 1/8/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

#import "CRComic.h"
#import "CRComicService.h"

static NSString *NUMBER_KEY = @"kCRComicNumber";
static NSString *TITLE_KEY = @"kCRComicTitle";
static NSString *ALTTEXT_KEY = @"kCRComicAltText";
static NSString *IMAGEURL_KEY = @"kCRComicURL";

@implementation CRComic {
    UIImage *_image;
    UIImage *_thumbnail;
    NSString *_imageFileName;
}

#pragma mark - constructors
- (instancetype)initWithNumber:(NSInteger)num title:(NSString*)title altText:(NSString*)altText url:(NSURL*)url {
    self = [super init];
    
    if (self) {
        self.number = num;
        self.title= title;
        self.altText = altText;
        self.imageURL = url;
    }
    
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)json {
    return [self initWithNumber:[json[@"num"] integerValue]
                          title:json[@"title"]
                        altText:json[@"altText"]
                            url:[NSURL URLWithString:json[@"url"]]];
}

#pragma mark NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithNumber:[aDecoder decodeIntegerForKey:NUMBER_KEY]
                          title:[aDecoder decodeObjectForKey:TITLE_KEY]
                        altText:[aDecoder decodeObjectForKey:ALTTEXT_KEY]
                            url:[aDecoder decodeObjectForKey:IMAGEURL_KEY]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.number forKey:NUMBER_KEY];
    [aCoder encodeObject:self.title forKey:TITLE_KEY];
    [aCoder encodeObject:self.altText forKey:ALTTEXT_KEY];
    [aCoder encodeObject:self.imageURL forKey:IMAGEURL_KEY];
}

#pragma mark -
- (UIImage*)getImageWithCompletion:(ImageFetchCompletion)completion {
    if (_image == nil) {
        _image = [CRComicService imageForComic:self completion:^(UIImage *image, UIImage *thumbnail) {
            _image = image;
            _thumbnail = thumbnail;
            
            if (completion) {
                completion(image, thumbnail);
            }
        }];
    }
    
    return _image;
}

- (UIImage *)getThumbnailWithCompletion:(ImageFetchCompletion)completion {
    if (_thumbnail == nil) {
        _thumbnail = [CRComicService thumbnailForComic:self completion:^(UIImage *image, UIImage *thumbnail) {
            _image = image;
            _thumbnail = thumbnail;
            
            if (completion) {
                completion(image, thumbnail);
            }
        }];
    }
    
    return _thumbnail;
}

- (NSString *)imageFileName {
    if (_imageFileName == nil) {
        _imageFileName = [NSString stringWithFormat:@"%ld.%@", (long)self.number, [self.imageURL pathExtension]];
    }
    
    return _imageFileName;
}

- (void)clearCachedImages {
    _image = nil;
    _thumbnail = nil;
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"<Comic %ld - %@>", _number, _title];
}

- (NSUInteger)hash {
    return @(_number).hash;
}

- (BOOL)isEqual:(id)object {
    return ((CRComic*)object).number == _number;
}

@end
