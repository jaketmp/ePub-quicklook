//
//  MySpotlightImporter.m
//  epubMDI
//
//  Created by Jake Pearce on 18/02/2012.
//  Copyright (c) 2012 Imperial College. All rights reserved.
//

#import "MySpotlightImporter.h"
#import "JTPepub.h"

@implementation MySpotlightImporter

- (BOOL)importFileAtPath:(NSString *)filePath attributes:(NSMutableDictionary *)spotlightData error:(NSError **)error
{
    JTPepub *epub = [[JTPepub alloc] initWithFile:filePath];

    NSString *title = [epub title];
    [spotlightData setObject:title forKey:(NSString *)kMDItemDisplayName];

    NSArray *authors = [epub authors];
    [spotlightData setObject:authors forKey:(NSString *)kMDItemAuthors];

    NSString *publisher = [epub publisher];
    if ([publisher length] > 0)
        [spotlightData setObject:publisher forKey:(NSString *)kMDItemPublishers];

    NSArray *creators = [epub creators];
    if ([creators count] > 0)
        [spotlightData setObject:creators forKey:(NSString *)kMDItemContributors];

    // editors
    // illustrators
    // translators
    // synopsis         kMDItemHeadline ?
    // ISBN             kMDItemIdentifier
    // publicationDate  kMDItemContentCreationDate
    // drm              kMDItemSecurityMethod ?

    NSDate *expiryDate = [epub expiryDate];
    if (expiryDate)
        [spotlightData setObject:expiryDate forKey:(NSString *)kMDItemDueDate];

    return YES;
}

@end
