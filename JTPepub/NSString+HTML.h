//
//  NSString+HTML.h
//  epub
//
//  Created by Chris Ridd on 24/01/2012.
//  Copyright (c) 2012 Chris Ridd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringByEscapingHTML;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringByStrippingHTML;
@end
