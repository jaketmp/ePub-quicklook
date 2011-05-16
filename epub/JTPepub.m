//
//  JTPepub.m
//  epub
//
//  Created by Jake TM Pearce on 21/04/2011.
//  Copyright 2011 Imperial College. All rights reserved.
//

#import "JTPepub.h"


@implementation JTPepub

- (id)init
{
    self = [super init];
    if (self) {
        // nowt to do.
    }
    
    return self;
}
- (id)initWithFile:(NSString *)fileName
{
    [self init];
    if(self) {
        [self openEPUBFile:fileName];        

    }
    
    
    
    return self;
}

/*
 Open the named file and read the opf file into an NSXMLDocument.
 */
- (BOOL)openEPUBFile:(NSString*)fileName {
    // We're not reusable, so if we've already opened an epub, return.
    if (epubFile) {
        return FALSE;
    }
    epubFile = [[ZipArchive alloc] initWithZipFile:(NSString*)fileName];
    
    // Read the container.xml to find the root file.    
    NSData *container = [epubFile dataForNamedFile:@"META-INF/container.xml"];
    [container retain];
    
    NSError *xmlError;
    NSXMLDocument *containerXML = [[NSXMLDocument alloc] initWithData:container options:0 error:&xmlError];
    NSArray *rootFile = [containerXML nodesForXPath:@".//rootfile" error:&xmlError];
    NSString *rootFileType = [[[rootFile objectAtIndex:0] attributeForName:@"media-type"] stringValue];
    
    
    // This code is all designed arround oebps+xml epubs, DTBook is unsuported.
    if([rootFileType caseInsensitiveCompare:@"application/oebps-package+xml"] == NSOrderedSame) {
        rootFilePath = [[[rootFile objectAtIndex:0] attributeForName:@"full-path"] stringValue];
    }else{
        [container release];
        [containerXML release];
        return FALSE;
    }
    // Tidy
    [container release];
    [containerXML release];

    
    // Get the OEBPS/content.opf from the .epub
    NSData *content = [epubFile dataForNamedFile:rootFilePath];
    [content retain];
    opfXML = [[NSXMLDocument alloc] initWithData:content options:0 error:&xmlError];
    [content release];
    
    return TRUE;
}

- (NSString *)title
{
    // If the title has been set, return it.
    if (title) {
        return title;
    }
    
    
    // Otherwise load it.
    NSError *xmlError = nil;

    // scan for a <dc:title> element
    // //*[namespace-uri()='http://purl.org/dc/elements/1.1/' and local-name()='title']

    NSArray *metaElements = [opfXML nodesForXPath:@"//*[local-name()='title']" 
                                            error:&xmlError];
    
    // Check the array isn't empty.
    if ([metaElements count] == 0) {
        // No title found
        title = @"";
        return title;
    }
    // There should only be one <dc:title>, so take the last.
    title = [[metaElements lastObject] stringValue];
    
    NSString * str = [[metaElements lastObject] XPath];
    
    [title retain];
    
    return title;        
}
- (NSString *)author
{
    // If the author has been set, return it.
    if (author) {
        return author;
    }
    
    
    // Otherwise load it.
    NSError *xmlError = nil;
    
    // scan for a <dc:creator> element
    NSArray *metaElements = [opfXML nodesForXPath:@"//*[local-name()='creator']" 
                                            error:&xmlError];
    
    // Check the array isn't empty.
    if ([metaElements count] == 0) {
        // No title found
        author = @"";
        return author;
    }
    NSMutableString *mutableAuthors = [[NSMutableString alloc] init];
    // Fast enumerate over meta elements
    UInt16 count = 0;
    for(id item in metaElements)
    {
        NSString *itemID = [[item attributeForName:@"role"] stringValue];
        
        if([itemID caseInsensitiveCompare:@"aut"] == NSOrderedSame) {
            
            [mutableAuthors appendString:[item stringValue]];
            count++;
            
        } else if([itemID caseInsensitiveCompare:@"edt"] == NSOrderedSame) {
            
            [mutableAuthors appendString:[[item stringValue] stringByAppendingString:@" (Editor)"]];
            count++;
        }
        if (count >= 1) {
            [mutableAuthors appendString:@" "];
        }
    }
    
    author = [[NSString alloc] initWithString:mutableAuthors];
    [author retain];
    [mutableAuthors release];
    
    return author;

}
- (NSImage *)cover
{
    // If cover exists, return it.
    if (cover) {
        return cover;
    }
    // scan for a <meta> element with name="cover"
    NSError *xmlError = nil;
    NSArray *metaElements = [opfXML nodesForXPath:@".//meta" error:&xmlError];
    
    // Fast enumerate over meta elements
    NSString *coverID = nil;
    for(id item in metaElements)
    {
        NSString *metaName = [[item attributeForName:@"name"] stringValue];
        
        if([metaName caseInsensitiveCompare:@"cover"] == NSOrderedSame) {
            coverID = [[item attributeForName:@"content"] stringValue];
            break;
        }
    }
    if(coverID == nil) {
        cover = [[NSImage alloc] init];
        return cover; // No cover in this epub.
    }
    
    
    // Now iterate over the manifest to find the path.
    NSArray *itemElements = [opfXML nodesForXPath:@".//item" error:&xmlError];
    NSString *coverPath = nil;
    NSStream *coverMIME;
    // Fast enumerate over meta elements
    for(id item in itemElements)
    {
        NSString *itemID = [[item attributeForName:@"id"] stringValue];
        
        if([itemID caseInsensitiveCompare:coverID] == NSOrderedSame) {
            coverPath = [[item attributeForName:@"href"] stringValue];
            coverMIME = [[item attributeForName:@"media-type"] stringValue];
            break;
        }
    }
    if(coverPath == nil) {
        return nil; // No cover in this epub.
    }
    
    
    // The cover path is relative to the rootfile...
    NSString *contentRoot = [rootFilePath stringByDeletingLastPathComponent];
    NSArray *coverPathArray = [NSArray arrayWithObjects:contentRoot, coverPath, nil];
    NSString *fullCoverPath = [NSString pathWithComponents:coverPathArray];
    
    NSData *coverData  = [epubFile dataForNamedFile:fullCoverPath];
    [coverData retain];
    
    //Extract and resize image
    cover = [[NSImage alloc] initWithData:coverData];
    [cover retain];
    [coverData release];
    
    return cover;
}

- (void)dealloc
{
    if (epubFile) {
        [epubFile release];
    }
    if (title) {
        [title release];
    }
    if (author) {
        [author release];
    }
    if (opfXML) {
        [opfXML release];
    }
    if (cover) {
        [cover release];
    }
    if (rootFilePath) {
        [rootFilePath release];
    }
    
    [super dealloc];
}

@end
