#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#include <AppKit/AppKit.h>
#include "JTPepub.h"

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    /* We shall need:
        - The cover. 
        - The title. <dc:title>
        - The author.  <dc:creator opf:role="aut">
        - Any synopsis information. <dc:description>
    */
    NSMutableString *html;
    
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    // Determine desired localisations and load strings
	NSBundle *pluginBundle = [NSBundle bundleWithIdentifier:@"org.idpf.epub.qlgenerator"];
	[pluginBundle retain];
    
    /*
	   Load the HTML template
	 */
	//Get the template path
	NSString *htmlPath = [[[NSString alloc] initWithFormat:@"%@%@", [pluginBundle bundlePath], @"/Contents/Resources/index.html"] autorelease];
	NSError *htmlError;
    html = [[[NSMutableString alloc] initWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:&htmlError] autorelease];
    

    // Load the epub:
    CFStringRef filePath = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
    JTPepub *epubFile = [[JTPepub alloc] initWithFile:(NSString *)filePath];
    
    NSString *title = [epubFile title];
    NSString *author = [epubFile author];
    NSImage *cover = [epubFile cover];
    NSString *synopsis = [epubFile synopsis];
    
    

    
    
    [epubFile release];
    CFRelease(filePath);
    [pluginBundle release];
    [pool release];
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
