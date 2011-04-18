#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#include <AppKit/AppKit.h>
#include "ZipArchive/ZipArchive.h"



/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    ZipArchive *epubFile;
    NSData *content;
    NSXMLDocument *contentXML;
    NSError *xmlError;
    NSString *rootFilePath;
    NSString *coverPath = NULL;
    NSString *coverMIME;
    NSData *coverData;

    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    CFStringRef fullPath = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
    epubFile = [[ZipArchive alloc] initWithZipFile:(NSString*)fullPath];
    
    // Read the container.xml to find the root file.    
    NSData *container = [epubFile dataForNamedFile:@"META-INF/container.xml"];
    [container retain];
    NSXMLDocument *containerXML = [[NSXMLDocument alloc] initWithData:container options:0 error:&xmlError];
    NSArray *rootFile = [containerXML nodesForXPath:@".//rootfile" error:&xmlError];
    NSString *rootFileType = [[[rootFile objectAtIndex:0] attributeForName:@"media-type"] stringValue];
    
    if([rootFileType caseInsensitiveCompare:@"application/oebps-package+xml"] == NSOrderedSame) {
        rootFilePath = [[[rootFile objectAtIndex:0] attributeForName:@"full-path"] stringValue];
    }else{
        [container release];
        [containerXML release];
        [epubFile release];
		CFRelease(fullPath);
		[pool release];
		return -1;
    }
    // Tidy
//    [container release];
    [containerXML release];
    
    
    // Get the OEBPS/content.opf from the .epub
    content = [epubFile dataForNamedFile:rootFilePath];
    [content retain];
    contentXML = [[NSXMLDocument alloc] initWithData:content options:0 error:&xmlError];
    
    // scan for a <meta> element with name="cover"
    NSArray *metaElements = [contentXML nodesForXPath:@".//meta" error:&xmlError];
    
    // Fast enumerate over meta elements
    NSString *coverID = NULL;
    for(id item in metaElements)
    {
        NSString *metaName = [[item attributeForName:@"name"] stringValue];
        
        if([metaName caseInsensitiveCompare:@"cover"] == NSOrderedSame) {
            coverID = [[item attributeForName:@"content"] stringValue];
            break;
        }
    }
    if(coverID == NULL) {
        CFRelease(fullPath);
        [contentXML release];
//        [content release];
        [epubFile release];
        return -1;
    }
    // Now iterate over the manifest to find the path.
    NSArray *itemElements = [contentXML nodesForXPath:@".//item" error:&xmlError];
    
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
//    [content release];
    [contentXML release];
    if(coverPath == NULL) {
        CFRelease(fullPath);
        [epubFile release];
        return -1;
    }
    // If previewing is canceled, don't bother loading data.
	if(QLThumbnailRequestIsCancelled(thumbnail)) {
        [epubFile release];
		CFRelease(fullPath);
		[pool release];
		return noErr;
	}
    // The cover path is relative to the rootfile...
    NSString *contentRoot = [rootFilePath stringByDeletingLastPathComponent];
    NSArray *coverPathArray = [NSArray arrayWithObjects:contentRoot, coverPath, nil];
    NSString *fullCoverPath = [NSString pathWithComponents:coverPathArray];
    
    coverData  = [epubFile dataForNamedFile:fullCoverPath];
    [coverData retain];

    //Extract and resize image
    CGImageRef thumbnailImage;
    CGDataProviderRef imageData = CGDataProviderCreateWithCFData((CFDataRef)coverData);
    [coverData release];

    // can only use jpg or png...
    if([coverMIME caseInsensitiveCompare:@"image/jpeg"] == NSOrderedSame) {
        thumbnailImage = CGImageCreateWithJPEGDataProvider(imageData, NULL, TRUE, kCGRenderingIntentDefault);
        
    }else if([coverMIME caseInsensitiveCompare:@"image/png"] == NSOrderedSame) {
        thumbnailImage = CGImageCreateWithPNGDataProvider(imageData, NULL, TRUE, kCGRenderingIntentDefault);

    }else {
        CGDataProviderRelease(imageData);
        [epubFile release];
        CFRelease(fullPath);
        [pool release];
        return -1;
    }
    QLThumbnailRequestSetImage(thumbnail, thumbnailImage, NULL);

    // Tidy
    [epubFile release];
    CFRelease(fullPath);
//    CGImageRelease(thumbnailImage);
    CGDataProviderRelease(imageData);

    [pool release];
    
    return noErr;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
