//
//  MySpotlightImporter.m
//  epubMDI
//
//  Created by Jake Pearce on 18/02/2012.
//  Copyright (c) 2012 Imperial College. All rights reserved.
//

#import "MySpotlightImporter.h"
#import "JTPepub.h"
#import "NSString+HTML.h"

@implementation MySpotlightImporter

- (BOOL)importFileAtPath:(NSString *)filePath attributes:(NSMutableDictionary *)spotlightData error:(NSError **)error
{
    JTPepub *epub = [[JTPepub alloc] initWithFile:filePath];

    NSString *title = [epub title];
    [spotlightData setObject:title forKey:(NSString *)kMDItemDisplayName];

    // authors          kMDItemAuthors (array of strings)
    NSArray *authors = [epub authors];
    [spotlightData setObject:authors forKey:(NSString *)kMDItemAuthors];

    // publisher        kMDItemPublishers (array of strings)
    NSString *publisher = [epub publisher];
    if ([publisher length] > 0)
        [spotlightData setObject:[NSArray arrayWithObject:publisher] forKey:(NSString *)kMDItemPublishers];

    // creators         kMDItemContributors ? (array of strings)
    NSArray *creators = [epub creators];
    if ([creators count] > 0)
        [spotlightData setObject:creators forKey:(NSString *)kMDItemContributors];

    // editors          kMDItemEditors (array of strings)
    NSArray *editors = [epub editors];
    if ([editors count] > 0)
        [spotlightData setObject:editors forKey:(NSString *)kMDItemEditors];

    // illustrators
    NSArray *illustrators = [epub illustrators];
    if ([illustrators count] > 0)
        [spotlightData setObject:illustrators forKey:@"org_idpf_epub_container_metadata_illustrators"];

    // translators
    NSArray *translators = [epub translators];
    if ([translators count] > 0)
        [spotlightData setObject:translators forKey:@"org_idpf_epub_container_metadata_translators"];

    // synopsis         kMDItemHeadline ?
    NSString *synopsis = [[epub synopsis] stringByStrippingHTML];
    if ([synopsis length] > 0)
        [spotlightData setObject:synopsis forKey:(NSString *)kMDItemHeadline];

    // ISBN             kMDItemIdentifier (string)
    NSString *isbn = [epub isbn];
    if ([isbn length] > 0)
        [spotlightData setObject:isbn forKey:(NSString *)kMDItemIdentifier];

    // publicationDate  not kMDItemContentCreationDate
    
    // expiryDate       kMDItemDueDate (date)
    NSDate *expiryDate = [epub expiryDate];
    if (expiryDate)
        [spotlightData setObject:expiryDate forKey:(NSString *)kMDItemDueDate];

    // drm              kMDItemSecurityMethod (string)
    NSString *drm = [epub drm];
    if ([drm isEqualToString:@""]) drm = @"None"; // PDF uses "None" explicitly
    [spotlightData setObject:drm forKey:(NSString *)kMDItemSecurityMethod];

    // Don't try to extract text if there's any DRM
    if ([drm isEqualToString:@"None"]) {
        NSMutableString *content = [[NSMutableString alloc] init];
        NSString *text;
        NSUInteger file = 0;
        do {
            text = [epub textFromManifestItem:file];
            file++;
            if (text)
                [content appendString:text];
        } while (text);
        //NSString *tmp = [NSString stringWithFormat:@"Indexed %lu", [content length]];
        //[spotlightData setObject:tmp forKey:(NSString *)kMDItemComment];
        [spotlightData setObject:content forKey:(NSString *)kMDItemTextContent];
        [content release];
    } else {
        //[spotlightData setObject:@"No indexed content" forKey:(NSString *)kMDItemComment];
    }

    [epub release];
    return YES;
}

@end
