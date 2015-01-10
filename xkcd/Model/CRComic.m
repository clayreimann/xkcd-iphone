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
}

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

- (UIImage*)getImageWithCompletion:(ImageFetchCompletion)completion {
    if (_image == nil) {
        _image = [CRComicService imageForComic:self completion:^(UIImage *image) {
            _image = image;
        }];
    }
    
    return _image;
}

@end
