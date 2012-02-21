//
//  GetMetadataForFile.m
//  epubMDI
//
//  Created by Jake Pearce on 18/02/2012.
//  Copyright (c) 2012 Imperial College. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#import <CoreData/CoreData.h>
#import "MySpotlightImporter.h"

Boolean GetMetadataForFile(void *thisInterface, CFMutableDictionaryRef attributes, CFStringRef contentTypeUTI, CFStringRef pathToFile);

//==============================================================================
//
//	Get metadata attributes from document files
//
//	The purpose of this function is to extract useful information from the
//	file formats for your document, and set the values into the attribute
//  dictionary for Spotlight to include.
//
//==============================================================================

Boolean GetMetadataForFile(void *thisInterface, CFMutableDictionaryRef attributes, CFStringRef contentTypeUTI, CFStringRef pathToFile)
{
    // Pull any available metadata from the file at the specified path
    // Return the attribute keys and attribute values in the dict
    // Return TRUE if successful, FALSE if there was no data provided
	// The path could point to either a Core Data store file in which
	// case we import the store's metadata, or it could point to a Core
	// Data external record file for a specific record instances

    Boolean ok = FALSE;
    @autoreleasepool {
        NSError *error = nil;
        
        if ([(__bridge NSString *)contentTypeUTI isEqualToString:@"org.idpf.epub-container"]) {
            // import from an external record file
            
            MySpotlightImporter *importer = [[[MySpotlightImporter alloc] init] autorelease];
            
            ok = [importer importFileAtPath:(__bridge NSString *)pathToFile attributes:(__bridge NSMutableDictionary *)attributes error:&error];
        }
    }
    
	// Return the status
    return ok;
}
