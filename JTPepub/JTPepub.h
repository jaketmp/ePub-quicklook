//
//  JTPepub.h
//  epub
//
//  Created by Jake TM Pearce on 21/04/2011.
//  Copyright 2011 Imperial College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#include <AppKit/AppKit.h>
#include "ZipArchive/ZipArchive.h"

typedef NS_ENUM(NSInteger, JTPbookType) {
    jtpUnknownBook = 0,
    jtpEPUB2,
    jtpEPUB3,
    jtpiBooks
} ;

@interface JTPepub : NSObject {
@private
    ZipArchive *epubFile;
    JTPbookType bookType;
    NSInteger epubVersion;
    NSMutableArray *manifest;
    NSMutableString *capturing;
    NSDictionary *entities;
    NSString *title;
    NSArray *authors;
    NSString *publisher;
    NSMutableArray *creators;
    NSArray *editors;
    NSArray *illustrators;
    NSArray *translators;
    NSString *synopsis;
    NSString *rootFilePath;
    NSString *ISBN;
    GDataXMLDocument *opfXML;
    NSImage *cover;
    BOOL haveCheckedForCover;
    NSDate *publicationDate;
    NSMutableArray *language;
    NSString *drm;
    NSDate *expiryDate;
}
- (instancetype)initWithFile:(NSString *)fileName NS_DESIGNATED_INITIALIZER;
- (BOOL)openEPUBFile:(NSString*)fileName;

- (NSString *)textFromManifestItem:(NSUInteger)n;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *title;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *authors;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *publisher;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *creators;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *editors;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *illustrators;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *translators;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSImage *cover;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *synopsis;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDate *publicationDate;
- (NSString *)isbn;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *drm;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDate *expiryDate;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *language;

@end
