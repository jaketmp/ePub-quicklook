//
//  NSDate+OPF.m
//  epub
//
//  Created by Chris Ridd on 13/02/2012.
//  Copyright (c) 2012 Chris Ridd. All rights reserved.
//

#import "NSDate+OPF.h"

@implementation NSDate (OPF)

// Dates in OPF can be in a variety of formats.
// The formats are described in http://www.w3.org/TR/NOTE-datetime
// The format strings used by Cocoa are described in http://www.unicode.org/reports/tr35/#Date_Format_Patterns
+ (NSDate *)dateFromOPFString:(NSString *)s
{
    NSDate *date = nil;
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    NSArray *formats = @[@"yyyy",
                        @"yyyy-MM",
                        @"yyyy-MM-dd",
                        @"yyyy-MM-dd'T'HH:mm'Z'",
                        @"yyyy-MM-dd'T'HH:mmZ",
                        @"yyyy-MM-dd'T'HH:mm:ss'Z'",
                        @"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    for (id format in formats) {
        [formatter setDateFormat:format];
        date = [formatter dateFromString:s];
        if (date)
            return date;
    }
    return nil;
}


@end
