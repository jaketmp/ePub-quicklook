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
    NSInteger epubVersion;
    NSString *title;
    NSString *author;
    NSString *publisher;
    NSArray * creators;
    NSArray *editors;
    NSArray *illustrators;
    NSArray *translators;
    NSString *synopsis;
    NSString *rootFilePath;
    NSString *ISBN;
    NSXMLDocument *opfXML;
    NSImage *cover;
    NSDate *publicationDate;
    NSString *drm;

}
- (id) initWithFile:(NSString *)fileName;
- (BOOL)openEPUBFile:(NSString*)fileName;

- (NSString *)title;
- (NSString *)author;
- (NSString *)publisher;
- (NSArray *)creators;
- (NSArray *)editors;
- (NSArray *)illustrators;
- (NSArray *)translators;
- (NSImage *)cover;
- (NSString *)synopsis;
- (NSDate *)publicationDate;
- (NSString *)isbn;
- (NSString *)drm;

@end
