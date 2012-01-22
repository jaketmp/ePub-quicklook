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
    }else{ // Delete image if we find no cover.
        [html replaceOccurrencesOfString:@"<img src=\"cid:icon.tiff\" alt=\"cover image\" />" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [html length])];
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
    [html replaceOccurrencesOfString:@"%title%" withString:[epubFile title] options:NSLiteralSearch range:NSMakeRange(0, [html length])];
    [html replaceOccurrencesOfString:@"%author%" withString:[epubFile author] options:NSLiteralSearch range:NSMakeRange(0, [html length])];

    /*
     * Other metadata goes into a table
     * TODO: localise labels
     * TODO: avoid such intimate knowledge of the HTML
     */
    NSMutableString *metadata = [NSMutableString string];
    if ([[epubFile editors] count] > 0) {
        [metadata appendFormat:@"<tr><th>editor%@:</th><td>%@</td></tr>\n",
         [[epubFile editors] count] > 1 ? @"s" : @"",
         [[epubFile editors] componentsJoinedByString:@"<br>\n"]];
    }
    if ([[epubFile illustrators] count] > 0) {
        [metadata appendFormat:@"<tr><th>illustrator%@:</th><td>%@</td></tr>\n",
         [[epubFile illustrators] count] > 1 ? @"s" : @"",
         [[epubFile illustrators] componentsJoinedByString:@"<br>\n"]];
    }
    if ([[epubFile translators] count] > 0) {
        [metadata appendFormat:@"<tr><th>translator%@:</th><td>%@</td></tr>\n",
         [[epubFile translators] count] > 1 ? @"s" : @"",
         [[epubFile translators] componentsJoinedByString:@"<br>\n"]];
    }
    if (![[epubFile isbn] isEqualToString:@""]) {
        [metadata appendFormat:@"<tr><th>isbn:</th><td>%@</td></tr>\n",
         [epubFile isbn]];
    }
    if (![[epubFile publisher] isEqualToString:@""]) {
        [metadata appendFormat:@"<tr><th>publisher:</th><td>%@</td></tr>\n",
         [epubFile publisher]];
    }
    if ([epubFile publicationDate]) {
        [metadata appendFormat:@"<tr><th>date:</th><td>%@</td></tr>\n",
         [[epubFile publicationDate] descriptionWithCalendarFormat:@"%Y" 
                                                          timeZone:nil 
                                                            locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
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
