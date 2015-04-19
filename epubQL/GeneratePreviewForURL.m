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
    
    @autoreleasepool {
		NSMutableString *html;

    // Determine desired localisations and load strings
		NSBundle *pluginBundle = [NSBundle bundleWithIdentifier:@"org.idpf.epub.qlgenerator"];
    
    /*
     * Load the HTML template
		 */
		//Get the template path
		NSString *htmlPath = [pluginBundle pathForResource:@"index" ofType:@"html"];
    
    // Load data.
		NSError *htmlError;
    html = [[NSMutableString alloc] initWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:&htmlError];

    /*
     * Load the epub:
     */
    NSString *filePath = CFBridgingRelease(CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle));
    JTPepub *epubFile = [[JTPepub alloc] initWithFile:filePath];
    
    
    /*
     * Set properties for the preview data
     */
    NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
		
    // Title string
    props[(NSString *)kQLPreviewPropertyTextEncodingNameKey] = @"UTF-8";
    props[(NSString *)kQLPreviewPropertyMIMETypeKey] = @"text/html";
    props[(NSString *)kQLPreviewPropertyDisplayNameKey] = [epubFile title];

    
    /*
     * Cover image
     */
    NSData *iconData = nil;
    NSImage *theIcon = nil;
    if ([epubFile cover]) {
        iconData = [[epubFile cover] TIFFRepresentation];
    } else {
        // No cover - get the Finder icon in case the user has pasted something custom
        theIcon = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
        [theIcon setSize:NSMakeSize(128.0,128.0)];
        iconData = [theIcon TIFFRepresentation];
    }
#if ATTACHING_IMAGE
    NSMutableDictionary *iconProps=[[[NSMutableDictionary alloc] init] autorelease];
    iconProps[(NSString *)kQLPreviewPropertyMIMETypeKey] = @"image/tiff";
    iconProps[(NSString *)kQLPreviewPropertyAttachmentDataKey] = iconData;
    props[(NSString *)kQLPreviewPropertyAttachmentsKey] = @{ @"icon.tiff": iconProps };
    [theIcon release];
#else
    NSString *base64 = [[NSString alloc] initWithData:[iconData base64EncodedDataWithOptions:0]
                                             encoding:NSUTF8StringEncoding];
    NSString *image = [NSString stringWithFormat:@"data:image/tiff;base64,%@", base64];
    [html replaceOccurrencesOfString:@"%image%" withString:image options:NSLiteralSearch range:NSMakeRange(0, [html length])];
#endif

    /*
     * Determine OS version and add the appropriate CSS to the html.
     */
    NSString *cssPath, *css;
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        // 10.10
        cssPath = [[NSString alloc] initWithFormat:@"%@%@", [pluginBundle bundlePath], @"/Contents/Resources/yosemite.css"];
    } else if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        // 10.7
        cssPath = [[NSString alloc] initWithFormat:@"%@%@", [pluginBundle bundlePath], @"/Contents/Resources/lion.css"];
    } else {
        cssPath = [[NSString alloc] initWithFormat:@"%@%@", [pluginBundle bundlePath], @"/Contents/Resources/leopard.css"];
    }
    
    css = [[NSString alloc] initWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:NULL];
    
    [html replaceOccurrencesOfString:@"%styledata%" withString:css options:NSLiteralSearch range:NSMakeRange(0, [html length])];
    
    
    /*
     * Localise and subsitute derived values into the template html
     */
    [html replaceOccurrencesOfString:@"%title%" withString:[[epubFile title] stringByEscapingHTML] options:NSLiteralSearch range:NSMakeRange(0, [html length])];
    [html replaceOccurrencesOfString:@"%author%" withString:[[epubFile authors] escapedComponentsJoinedByString:@", "] options:NSLiteralSearch range:NSMakeRange(0, [html length])];

    /*
     * Other metadata goes into a table
     * TODO: avoid such intimate knowledge of the HTML
     */
    NSMutableString *metadata = [NSMutableString string];
    if ([[epubFile editors] count] > 0) {
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
             [[epubFile isbn] stringByEscapingHTML]];
    }
    if (![[epubFile publisher] isEqualToString:@""]) {
        [metadata appendFormat:@"<tr><th>%@:</th><td>%@</td></tr>\n",
             [pluginBundle localizedStringForKey:@"publisher" 
                                           value:@"publisher" 
                                           table:nil],
             [[epubFile publisher] stringByEscapingHTML]];
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
         [[epubFile drm] stringByEscapingHTML]];
    }
    if ([epubFile expiryDate]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];

        [metadata appendFormat:@"<tr><th>%@:</th><td>%@</td></tr>\n",
         [pluginBundle localizedStringForKey:@"expiryDate" 
                                       value:@"expiry date" 
                                       table:nil],
         [formatter stringFromDate:[epubFile expiryDate]]];
    }
    if ([[epubFile language] count] > 0) {
        NSMutableArray *langs = [NSMutableArray array];
        for (id l in [epubFile language]) {
            NSLocale *loc = [[NSLocale alloc] initWithLocaleIdentifier:l];
            [langs addObject:[loc displayNameForKey:NSLocaleIdentifier value:l]];
        }
        [metadata appendFormat:@"<tr><th>%@:</th><td>%@</td></tr>\n",
         [[epubFile language] count] > 1 ? [pluginBundle localizedStringForKey:@"languages" 
                                                                         value:@"languages" 
                                                                         table:nil] : 
         [pluginBundle localizedStringForKey:@"language" 
                                       value:@"language" 
                                       table:nil],
         [langs escapedComponentsJoinedByString:@", "]];
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
			
			return noErr;
		}
		QLPreviewRequestSetDataRepresentation(preview,(__bridge CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding],kUTTypeHTML,(__bridge CFDictionaryRef)props);
    
    /*
     * And done! Tidy up and return.
     */
    return noErr;
    }
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
