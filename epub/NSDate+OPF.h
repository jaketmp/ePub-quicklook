//
//  NSDate+OPF.h
//  epub
//
//  Created by Chris Ridd on 13/02/2012.
//  Copyright (c) 2012 Imperial College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (OPF)
+ (NSDate *)dateFromOPFString:(NSString *)s;
@end
