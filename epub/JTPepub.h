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
    NSString *rootFilePath;
    NSXMLDocument *opfXML;
    NSImage *cover;

}
- (id) initWithFile:(NSString *)fileName;
- (BOOL)openEPUBFile:(NSString*)fileName;

- (NSString *)title;
- (NSString *)author;
- (NSImage *)cover;

@end
