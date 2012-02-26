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
- (NSString *)stringByEscapingHTML
{
    NSMutableString *e = [self mutableCopy];
    [e replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, [e length])];
    [e replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:NSMakeRange(0, [e length])];
    [e replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:NSMakeRange(0, [e length])];
    return [e autorelease];
}

/* Return an autoreleased version with HTML/XML tags removed. */
- (NSString *)stringByStrippingHTML
{
    NSScanner *s = [NSScanner scannerWithString:self];
    [s setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    NSCharacterSet *pre = [[NSCharacterSet characterSetWithCharactersInString:@"<"] invertedSet];
    NSCharacterSet *end = [NSCharacterSet characterSetWithCharactersInString:@">"];
    NSCharacterSet *tag = [end invertedSet];
    
    NSMutableString *result = [NSMutableString string];
    while ([s isAtEnd] == NO) {
        NSString *p = nil;
        if ([s scanCharactersFromSet:pre intoString:&p] == YES)
            [result appendString:p];
        [s scanCharactersFromSet:tag intoString:NULL];
        [s scanCharactersFromSet:end intoString:NULL];
    }
    return result;
}
@end
