//
//  CRComic.h
//  xkcd
//
//  Created by Christopher Reimann on 1/8/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

@import UIKit;
#import "CRComicService.h"

@interface CRComic : NSObject <NSCoding>

@property (nonatomic) NSInteger number;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *altText;
@property (nonatomic) NSURL *imageURL;

/**
 *  Create a new comic based on the JSON received from the backend
 *
 *  @param json - the JSON received
 *
 *  @return a new CRComic
 */
- (instancetype)initWithJSON:(NSDictionary*)json;

/**
 *  Gets the image associated with a particular comic
 *
 *  @param completion - the completion block to be called if the image has not been
 *                      downloaded previously
 *
 *  @return the comic's image
 */
- (UIImage*)getImageWithCompletion:(ImageFetchCompletion)completion;

@end
