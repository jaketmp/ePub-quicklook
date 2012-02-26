//
//  NSString+HTML.h
//  epub
//
//  Created by Chris Ridd on 24/01/2012.
//  Copyright (c) 2012 Chris Ridd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)
- (NSString *)escapedString;
- (NSString *)stringByStrippingHTML;
@end
