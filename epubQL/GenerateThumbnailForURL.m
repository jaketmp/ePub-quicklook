#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#include <AppKit/AppKit.h>
#include "JTPepub.h"



/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    @autoreleasepool {

    
    /*
     * Load the epub:
     */
        NSString *filePath = CFBridgingRelease(CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle));
        JTPepub *epubFile = [[JTPepub alloc] initWithFile:filePath];
        
        // and cover image
        NSImage *cover = [epubFile cover];
        
        if(cover){ // Bail out if we have no cover data.
            /*
             * Resize the cover image - then convert to a CGimageref
             */
            // Setup the context
            NSSize imageSize = [cover size];

            if(imageSize.width > imageSize.height) { // Landscape
                double scale = imageSize.width / maxSize.width;
                [cover setSize:NSMakeSize(imageSize.width / scale, imageSize.height / scale)];
            }else if(imageSize.width < imageSize.height) { // Portrait
                double scale = imageSize.height / maxSize.height;
                [cover setSize:NSMakeSize(imageSize.width / scale, imageSize.height / scale)];
            }else { // Square image
                [cover setSize:NSSizeFromCGSize(maxSize)];
            }
            
            
            CGContextRef context = QLThumbnailRequestCreateContext(thumbnail, NSSizeToCGSize([cover size]), TRUE, nil);
            NSGraphicsContext *nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
            
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:nsGraphicsContext];
            
            [cover drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
            
            [NSGraphicsContext setCurrentContext:nsGraphicsContext];
            
            QLThumbnailRequestFlushContext(thumbnail, context);
            CFRelease(context);
        }

        /*
         * Tidy
         */
        return noErr;
    }
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
