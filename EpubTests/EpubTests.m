//
//  EpubTests.m
//  EpubTests
//
//  Created by Chris Ridd on 01/02/2012.
//  Copyright (c) 2012 Chris Ridd. All rights reserved.
//

#import "EpubTests.h"
#import "JTPepub.h"

@implementation EpubTests

- (void)setUp
{
    [super setUp];
    
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *untitled = [thisBundle pathForResource:@"Untitled" ofType:@"epub"];
    NSString *metadata = [thisBundle pathForResource:@"metadata" ofType:@"epub"];
    NSString *badcontributor = [thisBundle pathForResource:@"badcontributor" ofType:@"epub"];
    NSString *adept = [thisBundle pathForResource:@"fake-adept" ofType:@"epub"];
    NSString *bn = [thisBundle pathForResource:@"fake-bn" ofType:@"epub"];
    NSString *fairplay = [thisBundle pathForResource:@"fake-fairplay" ofType:@"epub"];
    NSString *kobo = [thisBundle pathForResource:@"fake-kobo" ofType:@"epub"];
    untitledFile = [[JTPepub alloc] initWithFile:untitled];
    metadataFile = [[JTPepub alloc] initWithFile:metadata];
    badcontributorFile = [[JTPepub alloc] initWithFile:badcontributor];
    adeptFile = [[JTPepub alloc] initWithFile:adept];
    bnFile = [[JTPepub alloc] initWithFile:bn];
    fairplayFile = [[JTPepub alloc] initWithFile:fairplay];
    koboFile = [[JTPepub alloc] initWithFile:kobo];
}

- (void)tearDown
{
    [koboFile release];
    [fairplayFile release];
    [bnFile release];
    [adeptFile release];
    [badcontributorFile release];
    [metadataFile release];
    [untitledFile release];

    [super tearDown];
}

- (void)testTitle
{
    NSString *actual = [untitledFile title];
    NSString *expected = @"Test Document";
    STAssertEqualObjects(actual, expected, @"title is wrong");
}

- (void)testTitleWithAmpersand
{
    NSString *actual = [metadataFile title];
    NSString *expected = @"This & That";
    STAssertEqualObjects(actual, expected, @"title is wrong");
}

- (void)testAuthors
{
    NSArray *actual = [untitledFile authors];
    NSString *expected = @"Test Author";
    STAssertTrue([actual count] == 1, @"1 author expected");
    STAssertEqualObjects([actual lastObject], expected, @"author is wrong");
}

- (void)testISBN
{
    NSString *actual = [untitledFile isbn];
    NSString *expected = @"123456789";
    STAssertEqualObjects(actual, expected, @"ISBN is wrong");
}

- (void)testDate
{
    NSString *actual = [[untitledFile publicationDate] descriptionWithCalendarFormat:@"%Y" 
                                                                            timeZone:nil 
                                                                              locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
    NSString *expected = @"2011";
    STAssertEqualObjects(actual, expected, @"date is wrong");
}

- (void)testTranslator
{
    NSArray *actual = [untitledFile translators];
    NSString *expected = @"Test Translator";
    STAssertTrue([actual count] == 1, @"1 translator expected");
    STAssertEqualObjects([actual lastObject], expected, @"translator is wrong");
}

- (void)testIllustrator
{
    NSArray *actual = [untitledFile illustrators];
    NSString *expected = @"Test Illustrator";
    STAssertTrue([actual count] == 1, @"1 illustrator expected");
    STAssertEqualObjects([actual lastObject], expected, @"illustrator is wrong");
}

- (void)testThreeAuthors
{
    NSArray *actual = [metadataFile authors];
    NSString *expected0 = @"Primary Author";
    NSString *expected1 = @"Second Author";
    NSString *expected2 = @"Third Author";
    STAssertTrue([actual count] == 3, @"3 authors expected");
    STAssertEqualObjects([actual objectAtIndex:0], expected0, @"First author is wrong");
    STAssertEqualObjects([actual objectAtIndex:1], expected1, @"Second author is wrong");
    STAssertEqualObjects([actual objectAtIndex:2], expected2, @"Third author is wrong");
}

#pragma mark Test lack of opf:role
- (void)testBadContributor
{
    NSArray *actual = [badcontributorFile translators];
    STAssertTrue([actual count] == 0, @"No translators expected");
}

- (void)testBadAuthor
{
    NSArray *actual = [badcontributorFile authors];
    STAssertTrue([actual count] == 1, @"1 author expected");
}

#pragma mark Test DRM
- (void)testNoDRM
{
    NSString *actual = [untitledFile drm];
    NSString *expected = @"";
    STAssertEqualObjects(actual, expected, @"Untitled file has wrong DRM");
}

- (void)testAdobeDRM
{
    NSString *actual = [adeptFile drm];
    NSString *expected = @"Adobe";
    STAssertEqualObjects(actual, expected, @"fake-adept file has wrong DRM");
}

- (void)testBarnesAndNobleDRM
{
    NSString *actual = [bnFile drm];
    NSString *expected = @"Barnes & Noble";
    STAssertEqualObjects(actual, expected, @"fake-bn file has wrong DRM");
}

- (void)testAppleDRM
{
    NSString *actual = [fairplayFile drm];
    NSString *expected = @"Apple";
    STAssertEqualObjects(actual, expected, @"fake-fairplay file has wrong DRM");
}

- (void)testKoboDRM
{
    NSString *actual = [koboFile drm];
    NSString *expected = @"Kobo";
    STAssertEqualObjects(actual, expected, @"fake-kobo file has wrong DRM");
}

#pragma mark Test covers
- (void)testUntitledCover
{
    NSImage *actual = [untitledFile cover];
    STAssertNotNil(actual, @"Cover not found");
}

- (void)testMissingCover
{
    NSImage *actual = [metadataFile cover];
    STAssertNil(actual, @"Cover not missing");
}
@end
