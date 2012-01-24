//
//  NSArray+HTML.h
//  epub
//
//  Created by Chris Ridd on 24/01/2012.
//  Copyright (c) 2012 Chris Ridd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (HTML)
- (NSString *)escapedComponentsJoinedByString:(NSString *)separator;
@end
