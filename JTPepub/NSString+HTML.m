//
//  NSString+HTML.m
//  epub
//
//  Created by Chris Ridd on 24/01/2012.
//  Copyright (c) 2012 Chris Ridd. All rights reserved.
//

#import "NSString+HTML.h"

@implementation NSString (HTML)

/* Return an autoreleased version with HTML specials escaped. */
- (NSString *)escapedString
{
    NSMutableString *e = [self mutableCopy];
    [e replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, [e length])];
    [e replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:NSMakeRange(0, [e length])];
    [e replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:NSMakeRange(0, [e length])];
    return [e autorelease];
}
@end
