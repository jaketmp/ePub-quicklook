#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import <AppKit/AppKit.h>
#import "JTPepub.h"
#import "NSArray+HTML.h"
#import "NSString+HTML.h"

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
        - The publication date. <dc:date>
        - The publisher. <dc:publisher>
        - Any synopsis information. <dc:description>
    */
    NSMutableString *html;
    
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    // Determine desired localisations and load strings
	NSBundle *pluginBundle = [NSBundle bundleWithIdentifier:@"org.idpf.epub.qlgenerator"];
	[pluginBundle retain];
    
    /*
     * Load the HTML template
	 */
	//Get the template path
	NSString *htmlPath = [[NSString alloc] initWithFormat:@"%@%@", [pluginBundle bundlePath], @"/Contents/Resources/index.html"];
    
    // Load data.
	NSError *htmlError;
    html = [[[NSMutableString alloc] initWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:&htmlError] autorelease];
    [htmlPath release];

    /*
     * Load the epub:
     */
    CFStringRef filePath = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
    JTPepub *epubFile = [[JTPepub alloc] initWithFile:(NSString *)filePath];
    
    
    /*
     * Set properties for the preview data
     */
	NSMutableDictionary *props = [[[NSMutableDictionary alloc] init] autorelease];
	
    // Title string
    [props setObject:@"UTF-8" forKey:(NSString *)kQLPreviewPropertyTextEncodingNameKey];
    [props setObject:@"text/html" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
	[props setObject:(NSString *)[epubFile title] forKey:(NSString *)kQLPreviewPropertyDisplayNameKey];

    
    /*
     * Cover image
     */
    if([epubFile cover]){
        NSData *iconData = [[[epubFile cover] TIFFRepresentation] retain];
        NSMutableDictionary *iconProps=[[[NSMutableDictionary alloc] init] autorelease];
        [iconProps setObject:@"image/tiff" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
        [iconProps setObject:iconData forKey:(NSString *)kQLPreviewPropertyAttachmentDataKey];
        [props setObject:[NSDictionary dictionaryWithObject:iconProps forKey:@"icon.tiff"] forKey:(NSString *)kQLPreviewPropertyAttachmentsKey];
        
        [iconData release];
    }else{ // Lacking a cover image, load the finder icon in case the user has pasted something custom.
        // Get file icon
        NSImage *theIcon = [[[NSWorkspace sharedWorkspace] iconForFile:(NSString*)filePath] retain];
        [theIcon setSize:NSMakeSize(128.0,128.0)];
        
        NSData *iconData = [[theIcon TIFFRepresentation] retain];
        NSMutableDictionary *iconProps=[[[NSMutableDictionary alloc] init] autorelease];
        [iconProps setObject:@"image/tiff" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
        [iconProps setObject:iconData forKey:(NSString *)kQLPreviewPropertyAttachmentDataKey];
        [props setObject:[NSDictionary dictionaryWithObject:iconProps forKey:@"icon.tiff"] forKey:(NSString *)kQLPreviewPropertyAttachmentsKey];
        
        [theIcon release];
        [iconData release];
    }
    
    
    /*
     * Determine OS version and add the appropriate CSS to the html.
     */
    NSString *cssPath, *css;
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        // 10.7
        cssPath = [[NSString alloc] initWithFormat:@"%@%@", [pluginBundle bundlePath], @"/Contents/Resources/lion.css"];
    } else {
        cssPath = [[NSString alloc] initWithFormat:@"%@%@", [pluginBundle bundlePath], @"/Contents/Resources/leopard.css"];

    }
    
    css = [[NSString alloc] initWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:NULL];
    [cssPath release];
    
    [html replaceOccurrencesOfString:@"%styledata%" withString:css options:NSLiteralSearch range:NSMakeRange(0, [html length])];
    [css release];
    
    
    /*
     * Localise and subsitute derived values into the template html
     */
    [html replaceOccurrencesOfString:@"%title%" withString:[[epubFile title] escapedString] options:NSLiteralSearch range:NSMakeRange(0, [html length])];
    [html replaceOccurrencesOfString:@"%author%" withString:[[epubFile authors] escapedComponentsJoinedByString:@", "] options:NSLiteralSearch range:NSMakeRange(0, [html length])];

    /*
     * Other metadata goes into a table
     * TODO: localise labels
     * TODO: avoid such intimate knowledge of the HTML
     */
    NSMutableString *metadata = [NSMutableString string];
    if ([[epubFile editors] count] > 0) {
        
        NSString *localST = [pluginBundle localizedStringForKey:@"editor" 
                                                          value:@"editor" 
                                                          table:nil];
        [metadata appendFormat:@"<tr><th>%@:</th><td>%@</td></tr>\n",
             [[epubFile editors] count] > 1 ? [pluginBundle localizedStringForKey:@"editors" 
                                                                            value:@"editors" 
                                                                            table:nil] : 
                                              [pluginBundle localizedStringForKey:@"editor" 
                                                                            value:@"editor" 
                                                                            table:nil],
             [[epubFile editors] escapedComponentsJoinedByString:@"<br>\n"]];
    }
    if ([[epubFile illustrators] count] > 0) {
        [metadata appendFormat:@"<tr><th>%@:</th><td>%@</td></tr>\n",
             [[epubFile illustrators] count] > 1 ? [pluginBundle localizedStringForKey:@"illustrators" 
                                                                                 value:@"illustrators" 
                                                                                 table:nil] : 
                                                   [pluginBundle localizedStringForKey:@"illustrator" 
                                                                                 value:@"illustrator" 
                                                                                 table:nil],
             [[epubFile illustrators] escapedComponentsJoinedByString:@"<br>\n"]];
    }
    if ([[epubFile translators] count] > 0) {
        [metadata appendFormat:@"<tr><th>%@:</th><td>%@</td></tr>\n",
             [[epubFile translators] count] > 1 ? [pluginBundle localizedStringForKey:@"translators" 
                                                                                value:@"translators" 
                                                                                table:nil] : 
                                                  [pluginBundle localizedStringForKey:@"translator" 
                                                                                value:@"translator" 
                                                                                table:nil],
             [[epubFile translators] escapedComponentsJoinedByString:@"<br>\n"]];        
    }
    if (![[epubFile isbn] isEqualToString:@""]) {
        [metadata appendFormat:@"<tr><th>%@:</th><td>%@</td></tr>\n",
             [pluginBundle localizedStringForKey:@"ISBN" 
                                           value:@"ISBN" 
                                           table:nil],
             [[epubFile isbn] escapedString]];
    }
    if (![[epubFile publisher] isEqualToString:@""]) {
        [metadata appendFormat:@"<tr><th>%@:</th><td>%@</td></tr>\n",
             [pluginBundle localizedStringForKey:@"publisher" 
                                           value:@"publisher" 
                                           table:nil],
             [[epubFile publisher] escapedString]];
    }
    if ([epubFile publicationDate]) {
        [metadata appendFormat:@"<tr><th>%@:</th><td>%@</td></tr>\n",
             [pluginBundle localizedStringForKey:@"pubDate" 
                                           value:@"publication date" 
                                           table:nil],
             [[epubFile publicationDate] descriptionWithCalendarFormat:@"%Y" 
                                                              timeZone:nil 
                                                                locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
    }
    if (![[epubFile drm] isEqualToString:@""]) {
        [metadata appendFormat:@"<tr><th>%@:</th><td>%@</td></tr>\n",
             [pluginBundle localizedStringForKey:@"drm" 
                                           value:@"DRM Scheme" 
                                           table:nil],
             [[epubFile drm] escapedString]];
    }
    if (![metadata isEqualToString:@""]) {
        [metadata insertString:@"<table>\n" atIndex:0];
        [metadata appendString:@"</table>\n"];
    }
    [html replaceOccurrencesOfString:@"%metadata%"
                          withString:metadata
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [html length])];

    [html replaceOccurrencesOfString:@"%synopsis%" withString:[epubFile synopsis] options:NSLiteralSearch range:NSMakeRange(0, [html length])];
    
    /*
     * Return the HTML to be rendered.
     */
    // Check for cancel
	if(QLPreviewRequestIsCancelled(preview)) {
        [epubFile release];
        [pluginBundle release];
        [pool release];
        CFRelease(filePath);
        
		return noErr;
	}
	QLPreviewRequestSetDataRepresentation(preview,(CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding],kUTTypeHTML,(CFDictionaryRef)props);
    
    /*
     * And done! Tidy up and return.
     */
    [epubFile release];
    [pluginBundle release];
    [pool release];
    CFRelease(filePath);
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
