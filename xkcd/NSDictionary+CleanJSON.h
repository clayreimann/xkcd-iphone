//
//  NSDictionary_NSDictionary_CleanJSON_m.h
//  xkcd
//
//  Created by Christopher Reimann on 2/24/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CleanJSON)

- (NSDictionary *)dictionaryWithoutNull;

@end
