//
//  NSArray+HTML.m
//  epub
//
//  Created by Chris Ridd on 24/01/2012.
//  Copyright (c) 2012 Chris Ridd. All rights reserved.
//

#import "NSArray+HTML.h"
#import "NSString+HTML.h"

@implementation NSArray (HTML)

/* Like componentsJoinedByString:, except the components have HTML specials escaped. */
- (NSString *)escapedComponentsJoinedByString:(NSString *)separator
{
    NSMutableArray *escaped = [NSMutableArray array];
    for (NSString *s in self) {
        [escaped addObject:[s escapedString]];
    }
    return [escaped componentsJoinedByString:separator];
}
@end
