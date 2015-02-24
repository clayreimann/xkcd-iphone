//
//  NSDictionary+CleanJSON.h
//  xkcd
//
//  Created by Christopher Reimann on 2/24/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

#import "NSDictionary+CleanJSON.h"


@implementation NSDictionary (CleanJSON)

- (NSDictionary *)dictionaryWithoutNull {
    NSMutableDictionary *clean = [NSMutableDictionary new];
    for (id key in self) {
        if (![self[key] isKindOfClass:[NSNull class]]) {
            clean[key] = self[key];
        }
    }
    
    return clean;
}

@end
