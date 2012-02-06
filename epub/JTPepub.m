//
//  JTPepub.m
//  epub
//
//  Created by Jake TM Pearce on 21/04/2011.
//  Copyright 2011 Imperial College. All rights reserved.
//

#import "JTPepub.h"

@interface JTPepub (Private)
@end

@implementation JTPepub

/*
 * A dictionary of XML namespaces
 */
static NSMutableDictionary *xmlns = nil;

+ (void)initialize
{
    if (self == [JTPepub class]) {
        xmlns = [[NSMutableDictionary alloc] init];
        [xmlns setValue:@"http://www.idpf.org/2007/opf" forKey:@"opf"];
        [xmlns setValue:@"http://www.idpf.org/2007/ops" forKey:@"ops"];
        [xmlns setValue:@"urn:oasis:names:tc:opendocument:xmlns:container" forKey:@"ocf"];
        // Dublin Core
        [xmlns setValue:@"http://purl.org/dc/elements/1.1/" forKey:@"dc"];
        // Adobe Adept (DRM)
        [xmlns setValue:@"http://ns.adobe.com/adept" forKey:@"adept"];
        // Apple Fairplay (DRM)
        [xmlns setValue:@"http://itunes.apple.com/ns/epub" forKey:@"fairplay"];
    }
}

- (id)init
{
    return [self initWithFile:nil];
}

- (id)initWithFile:(NSString *)fileName
{
    self = [super init];
    if (self) {
        [self openEPUBFile:fileName];
    }
    return self;
}

/*
 Open the named file and read the opf file into an GDataXMLDocument.
 */
- (BOOL)openEPUBFile:(NSString*)fileName {
    // We're not reusable, so if we've already opened an epub, return.
    if (epubFile) {
        return FALSE;
    }
    epubFile = [[ZipArchive alloc] initWithZipFile:(NSString*)fileName];
    
    
    // Check the mimetype to be sure it's an epub
    NSString *mimetype = [NSString stringWithUTF8String:[[epubFile dataForNamedFile:@"mimetype"] bytes]];
    NSRange mimeRange = [mimetype rangeOfString:@"application/epub+zip"];
    
    if(mimeRange.location != 0 && mimeRange.length != 20) {
        //[mimetype release];
        [epubFile release];
        return FALSE;
    }
   // [mimetype release];

    
    // Read the container.xml to find the root file.    
    NSData *container = [epubFile dataForNamedFile:@"META-INF/container.xml"];
    [container retain];
    
    NSError *xmlError;
    GDataXMLDocument *containerXML = [[GDataXMLDocument alloc] initWithData:container options:0 error:&xmlError];
    NSArray *rootFile = [containerXML nodesForXPath:@"//ocf:rootfile"
                                         namespaces:xmlns
                                              error:&xmlError];
    NSString *rootFileType = [[[rootFile objectAtIndex:0] attributeForName:@"media-type"] stringValue];
    
    
    // This code is all designed arround oebps+xml epubs, DTBook is unsuported.
    if([rootFileType caseInsensitiveCompare:@"application/oebps-package+xml"] == NSOrderedSame) {
        rootFilePath = [[[[rootFile objectAtIndex:0] attributeForName:@"full-path"] stringValue] retain];
    }else{
        [container release];
        [containerXML release];
        return FALSE;
    }
    // Tidy
    [container release];
    [containerXML release];

    
    /* 
     * Get the OEBPS/content.opf from the .epub
     * and identify the epub version.
     */
    NSData *content = [epubFile dataForNamedFile:rootFilePath];
    [content retain];
    opfXML = [[GDataXMLDocument alloc] initWithData:content options:0 error:&xmlError];
    [content release];
    
    //
    NSArray *metaElements = [opfXML nodesForXPath:@"//opf:package"
                                       namespaces:xmlns
                                            error:&xmlError];
    
    NSString *versionText = [[[metaElements lastObject] attributeForName:@"version"] stringValue];
    
    epubVersion = [versionText integerValue];
    
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
    NSArray *metaElements = [opfXML nodesForXPath:@"//dc:title"
                                       namespaces:xmlns
                                            error:&xmlError];
    
    // Check the array isn't empty.
    if ([metaElements count] == 0) {
        // No title found
        title = @"";
        return title;
    }
    // There should only be one <dc:title>, so take the last.
    title = [[metaElements lastObject] stringValue];
        
    [title retain];
    
    return title;
}

- (NSString *)publisher
{
    // If the publisher has been set, return it.
    if (publisher) {
        return publisher;
    }
    
    
    // Otherwise load it.
    NSError *xmlError = nil;
    
    // scan for a <dc:publisher> element    
    NSArray *metaElements = [opfXML nodesForXPath:@"//dc:publisher"
                                       namespaces:xmlns
                                            error:&xmlError];
    
    // Check the array isn't empty.
    if ([metaElements count] == 0) {
        // No publisher found
        publisher = @"";
        return publisher;
    }
    // There should only be one <dc:publisher>, so take the last.
    publisher = [[metaElements lastObject] stringValue];
    
    [publisher retain];
    
    return publisher;
}

- (NSArray *)creatorsWithOPFRole:(NSString *)role
{
    NSError *xmlError = nil;
    
    // scan for a <dc:contributor> element
    NSArray *metaElements = [opfXML nodesForXPath:@"//dc:creator"
                                       namespaces:xmlns
                                            error:&xmlError];
    
    // Check the array isn't empty.
    if ([metaElements count] == 0) {
        // No dc:contributor found
        return [NSArray array];
    }
    NSMutableArray *results = [NSMutableArray array];
    // Fast enumerate over meta elements
    for(id item in metaElements)
    {
        NSString *itemID = [[item attributeForName:@"role"] stringValue];
        
        if([itemID caseInsensitiveCompare:role] == NSOrderedSame) {
            // The name should be in the item contents.
            // If the element contents is empty, look in the file-as attribute
            // instead. If that's not there either, skip this item.
            if ([[item stringValue] isEqualToString:@""]) {
                NSString *fileAs = [[item attributeForName:@"file-as"] stringValue];
                if (![fileAs isEqualToString:@""])
                    [results addObject:fileAs];
            } else {
                [results addObject:[item stringValue]];
            }
        }
    }
    return results;
}

- (NSArray *)authors
{
    // If authors has been set, return it.
    if (authors) {
        return authors;
    }
    authors = [[self creatorsWithOPFRole:@"aut"] retain];
    return authors;
}

- (NSArray *)contributorsWithOPFRole:(NSString *)role
{
    NSError *xmlError = nil;
    
    // scan for a <dc:contributor> element
    NSArray *metaElements = [opfXML nodesForXPath:@"//dc:contributor"
                                       namespaces:xmlns
                                            error:&xmlError];
    
    // Check the array isn't empty.
    if ([metaElements count] == 0) {
        // No dc:contributor found
        return [NSArray array];
    }
    NSMutableArray *results = [NSMutableArray array];
    // Fast enumerate over meta elements
    for(id item in metaElements)
    {
        NSString *itemID = [[item attributeForName:@"role"] stringValue];
        
        if([itemID caseInsensitiveCompare:role] == NSOrderedSame) {
            // The name should be in the item contents.
            // If the element contents is empty, look in the file-as attribute
            // instead. If that's not there either, skip this item.
            if ([[item stringValue] isEqualToString:@""]) {
                NSString *fileAs = [[item attributeForName:@"file-as"] stringValue];
                if (![fileAs isEqualToString:@""])
                    [results addObject:fileAs];
            } else {
                [results addObject:[item stringValue]];
            }
        }
    }
    return results;
}
- (NSArray *)editors
{
    // If editors has been set, return it.
    if (editors) {
        return editors;
    }
    editors = [[self contributorsWithOPFRole:@"edt"] retain];
    return editors;
}
- (NSArray *)illustrators
{
    // If illustrators has been set, return it.
    if (illustrators) {
        return illustrators;
    }
    illustrators = [[self contributorsWithOPFRole:@"ill"] retain];
    return illustrators;
}
- (NSArray *)translators
{
    // If translators has been set, return it.
    if (translators) {
        return translators;
    }
    translators = [[self contributorsWithOPFRole:@"trl"] retain];
    return translators;
}
- (NSArray *)creators
{
    // If creators has been set, return it.
    if (creators) {
        return creators;
    }
    
    // Otherwise load it.
    NSMutableArray *creatorsMutable = [[NSMutableArray alloc] init];
    NSError *xmlError = nil;
    
    // scan for a <dc:creator> element
    NSArray *metaElements = [opfXML nodesForXPath:@"//dc:creator"
                                       namespaces:xmlns
                                            error:&xmlError];
    
    // Check the array isn't empty.
    if ([metaElements count] == 0) {
        
        // No title found return an empty array
        
        creators = [[NSArray alloc] initWithObjects:@"", nil];
        [creators retain];
        [creatorsMutable release];
        
        return creators;
    }
    
    // Fast enumerate over meta elements
    for(id item in metaElements)
    {
        NSString *itemID = [[item attributeForName:@"role"] stringValue];
                    
        [creatorsMutable addObject:[item stringValue]];
        [creatorsMutable addObject:itemID];

    }
    
    creators = [[NSArray alloc] initWithArray:creatorsMutable];
    [creators retain];
         
    [creatorsMutable release];
    
    return creators;
    
}

- (NSImage *)cover
{
    // If cover exists, return it.
    if (cover) {
        return cover;
    }
    // scan for a <meta> element with name="cover"
    NSError *xmlError = nil;
    NSArray *metaElements = [opfXML nodesForXPath:@"//opf:meta"
                                       namespaces:xmlns
                                            error:&xmlError];
    
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
    NSArray *itemElements = [opfXML nodesForXPath:@"//opf:item"
                                       namespaces:xmlns
                                            error:&xmlError];
    NSString *coverPath = nil;
    NSString *coverMIME;
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
- (NSString *)synopsis
{
    // If the synopsis has been set, return it.
    if (synopsis) {
        return synopsis;
    }
    
    
    // Otherwise load it.
    NSError *xmlError = nil;
    
    NSArray *metaElements = [opfXML nodesForXPath:@"//dc:description"
                                       namespaces:xmlns
                                            error:&xmlError];
    
    // Check the array isn't empty.
    if ([metaElements count] == 0) {
        // No title found
        synopsis = @"";
        return synopsis;
    }
    // There should only be one <dc:description>, so take the last.
    synopsis = [[metaElements lastObject] stringValue];
    
    [synopsis retain];
    
    return synopsis;    
}
- (NSDate *)publicationDate
{
    if (publicationDate) {
        return publicationDate;
    }
    
    // Otherwise load it.
    NSError *xmlError = nil;
    
    // scan for a <dc:date> element   
    NSArray *metaElements = [opfXML nodesForXPath:@"//dc:date"
                                       namespaces:xmlns
                                            error:&xmlError];
    
    // Check the array isn't empty.
    if ([metaElements count] == 0) {
        // No date found
        return nil;
    }
    // Find the date of publication.
    // Fast enumerate over meta elements
    for(id item in metaElements)
    {
        if([[[item attributeForName:@"event"] stringValue] caseInsensitiveCompare:@"publication"] == NSOrderedSame) {
            publicationDate = [NSDate dateWithNaturalLanguageString:[item stringValue]];
            [publicationDate retain];
        }        
    }
        
    return publicationDate;
}
- (NSString *)isbn
{
    // If the ISBN has been set, return it.
    if (ISBN) {
        return ISBN;
    }
    
    
    // Otherwise load it.
    NSError *xmlError = nil;
    
    // scan for a <dc:title> element    
    NSArray *metaElements = [opfXML nodesForXPath:@"//dc:identifier"
                                       namespaces:xmlns
                                            error:&xmlError];
    
    // Fast enumerate over meta elements
    for(id item in metaElements)
    {
        NSString *metaName = [[item attributeForName:@"scheme"] stringValue];
        
        if([metaName caseInsensitiveCompare:@"ISBN"] == NSOrderedSame) {
            // Remove any leading urn:isbn: and whitespace.
            NSMutableString *val = [[item stringValue] mutableCopy];
            [val replaceOccurrencesOfString:@"urn:isbn:" withString:@"" options:NSCaseInsensitiveSearch
                                      range:NSMakeRange(0, [val length])];
            [val replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, [val length])];
            if (![val isEqualToString:@""]) {
                ISBN = [val retain];
                return ISBN;
            }
        }
    }
    ISBN = @"";
    return ISBN;    
}
- (NSString *)drm
{
    // If the DRM scheme has been set, return it.
    if (drm) {
        return drm;
    }
    // Adobe Adept DRM has "META-INF/rights.xml", containing <licenseURL> with an adobe.com URL.
    if ([epubFile testForNamedFile:@"META-INF/rights.xml"]) {
        NSData *adept = [epubFile dataForNamedFile:@"META-INF/rights.xml"];
        NSError *xmlError;
        GDataXMLDocument *adeptXML = [[GDataXMLDocument alloc] initWithData:adept options:0 error:&xmlError];
        NSArray *urls = [adeptXML nodesForXPath:@"//adept:licenseURL"
                                     namespaces:xmlns
                                          error:&xmlError];
        [adeptXML release];
        if ([urls count] > 0) {
            // should probably check for adobe.com here...
            drm = @"Adobe";
            return drm;
        }
    }
    // Apple Fairplay DRM has "META-INF/sinf.xml" containing <fairplay:sinf>.
    if ([epubFile testForNamedFile:@"META-INF/sinf.xml"]) {
        NSData *fairplay = [epubFile dataForNamedFile:@"META-INF/sinf.xml"];
        NSError *xmlError;
        GDataXMLDocument *fairplayXML = [[GDataXMLDocument alloc] initWithData:fairplay options:0 error:&xmlError];
        NSArray *sinf = [fairplayXML nodesForXPath:@"//fairplay:sinf"
                                        namespaces:xmlns
                                             error:&xmlError];
        [fairplayXML release];
        if ([sinf count] > 0) {
            drm = @"Apple";
            return drm;
        }
    }
    // Kobo DRM has "rights.xml" containing <kdrm> (no namespace)
    if ([epubFile testForNamedFile:@"rights.xml"]) {
        NSData *kobo = [epubFile dataForNamedFile:@"rights.xml"];
        NSError *xmlError;
        GDataXMLDocument *koboXML = [[GDataXMLDocument alloc] initWithData:kobo options:0 error:&xmlError];
        NSArray *kdrm = [koboXML nodesForXPath:@"/kdrm" error:&xmlError];
        [koboXML release];
        if ([kdrm count] > 0) {
            drm = @"Kobo";
            return drm;
        }
    }
    drm = @"";
    return drm;
}
- (void)dealloc
{
    if (epubFile) {
        [epubFile release];
    }
    if (title) {
        [title release];
    }
    if (publisher) {
        [publisher release];
    }
    [authors release];
    if (creators) {
        [creators release];
    }
    [editors release];
    [illustrators release];
    [translators release];
    if (opfXML) {
        [opfXML release];
    }
    if (cover) {
        [cover release];
    }
    if (synopsis) {
        [synopsis release];
    }
    if (ISBN) {
        [ISBN release];
    }
    [drm release];
    if (rootFilePath) {
        [rootFilePath release];
    }
    if (publicationDate) {
        [publicationDate release];
    }
    
    [super dealloc];
}

@end
