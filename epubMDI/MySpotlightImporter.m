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
    // translators

    // synopsis         kMDItemHeadline ?
    NSString *str = [epub synopsis];
    // we manually remove any HTML tags
    NSScanner *s = [NSScanner scannerWithString:str];
    [s setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    NSCharacterSet *pre = [[NSCharacterSet characterSetWithCharactersInString:@"<"] invertedSet];
    NSCharacterSet *end = [NSCharacterSet characterSetWithCharactersInString:@">"];
    NSCharacterSet *tag = [end invertedSet];

    NSMutableString *synopsis = [NSMutableString string];
    while ([s isAtEnd] == NO) {
        NSString *p = nil;
        if ([s scanCharactersFromSet:pre intoString:&p] == YES)
            [synopsis appendString:p];
        [s scanCharactersFromSet:tag intoString:NULL];
        [s scanCharactersFromSet:end intoString:NULL];
    }
    if ([synopsis length] > 0)
        [spotlightData setObject:synopsis forKey:(NSString *)kMDItemHeadline];

    // ISBN             kMDItemIdentifier (string)
    // publicationDate  not kMDItemContentCreationDate

    // drm              kMDItemSecurityMethod (string)
    NSString *drm = [epub drm];
    if ([drm isEqualToString:@""]) drm = @"None"; // PDF uses "None" explicitly
    [spotlightData setObject:drm forKey:(NSString *)kMDItemSecurityMethod];

    // expiryDate       kMDItemDueDate (date)
    NSDate *expiryDate = [epub expiryDate];
    if (expiryDate)
        [spotlightData setObject:expiryDate forKey:(NSString *)kMDItemDueDate];

    [epub release];
    return YES;
}

@end
