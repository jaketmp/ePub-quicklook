//
//  JTPepub.h
//  epub
//
//  Created by Jake TM Pearce on 21/04/2011.
//  Copyright 2011 Imperial College. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "ZipArchive/ZipArchive.h"


@interface JTPepub : NSObject {
@private
    ZipArchive *epubFile;
    NSString *title;
    NSString *author;
    NSArray * creators;
    NSString *synopsis;
    NSString *rootFilePath;
    NSString *ISBN;
    NSXMLDocument *opfXML;
    NSImage *cover;
    NSDate *publicationDate;

}
- (id) initWithFile:(NSString *)fileName;
- (BOOL)openEPUBFile:(NSString*)fileName;

- (NSString *)title;
- (NSString *)author;
- (NSArray *)creators;
- (NSImage *)cover;
- (NSString *)synopsis;
- (NSDate *)publicationDate;
- (NSString *)isbn;

@end
