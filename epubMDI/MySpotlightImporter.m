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
    spotlightData[(NSString *)kMDItemDisplayName] = title;

    // authors          kMDItemAuthors (array of strings)
    NSArray *authors = [epub authors];
    spotlightData[(NSString *)kMDItemAuthors] = authors;

    // publisher        kMDItemPublishers (array of strings)
    NSString *publisher = [epub publisher];
    if ([publisher length] > 0)
        spotlightData[(NSString *)kMDItemPublishers] = @[publisher];

    // creators         kMDItemContributors ? (array of strings)
    NSArray *creators = [epub creators];
    if ([creators count] > 0)
        spotlightData[(NSString *)kMDItemContributors] = creators;

    // editors          kMDItemEditors (array of strings)
    NSArray *editors = [epub editors];
    if ([editors count] > 0)
        spotlightData[(NSString *)kMDItemEditors] = editors;

    // illustrators
    NSArray *illustrators = [epub illustrators];
    if ([illustrators count] > 0)
        spotlightData[@"org_idpf_epub_container_metadata_illustrators"] = illustrators;

    // translators
    NSArray *translators = [epub translators];
    if ([translators count] > 0)
        spotlightData[@"org_idpf_epub_container_metadata_translators"] = translators;

    // synopsis         kMDItemHeadline ?
    NSString *synopsis = [[epub synopsis] stringByStrippingHTML];
    if ([synopsis length] > 0)
        spotlightData[(NSString *)kMDItemHeadline] = synopsis;

    // ISBN             kMDItemIdentifier (string)
    NSString *isbn = [epub isbn];
    if ([isbn length] > 0)
        spotlightData[(NSString *)kMDItemIdentifier] = isbn;

    // publicationDate  not kMDItemContentCreationDate
    
    // expiryDate       kMDItemDueDate (date)
    NSDate *expiryDate = [epub expiryDate];
    if (expiryDate)
        spotlightData[(NSString *)kMDItemDueDate] = expiryDate;

    // drm              kMDItemSecurityMethod (string)
    NSString *drm = [epub drm];
    if ([drm isEqualToString:@""]) drm = @"None"; // PDF uses "None" explicitly
    spotlightData[(NSString *)kMDItemSecurityMethod] = drm;

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
        spotlightData[(NSString *)kMDItemTextContent] = content;
        [content release];
    } else {
        //[spotlightData setObject:@"No indexed content" forKey:(NSString *)kMDItemComment];
    }
    
    // language     kMDItemLanguages (string)
    NSArray *language = [epub language];
    if ([language count] > 0)
        spotlightData[(NSString *)kMDItemLanguages] = language;
    
    
    [epub release];
    return YES;
}

@end
