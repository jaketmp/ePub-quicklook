//
//  EpubTests.m
//  EpubTests
//
//  Created by Chris Ridd on 01/02/2012.
//  Copyright (c) 2012 Chris Ridd. All rights reserved.
//

#import "EpubTests.h"
#import "JTPepub.h"
#import "NSDate+OPF.h"
#import "NSString+HTML.h"

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
    NSString *library = [thisBundle pathForResource:@"fake-library" ofType:@"epub"];
    untitledFile = [[JTPepub alloc] initWithFile:untitled];
    metadataFile = [[JTPepub alloc] initWithFile:metadata];
    badcontributorFile = [[JTPepub alloc] initWithFile:badcontributor];
    adeptFile = [[JTPepub alloc] initWithFile:adept];
    bnFile = [[JTPepub alloc] initWithFile:bn];
    fairplayFile = [[JTPepub alloc] initWithFile:fairplay];
    koboFile = [[JTPepub alloc] initWithFile:kobo];
    libraryFile = [[JTPepub alloc] initWithFile:library];
}

- (void)tearDown
{
    [libraryFile release];
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

#pragma mark Text Extraction
- (void)testExtractUntitled
{
    NSUInteger i = 0;
    NSString *text;
    do {
        text = [untitledFile textFromManifestItem:i];
        i++;
    } while (text);
    STAssertTrue(i == 4, @"wrong number of chapters");
}

#pragma mark Test HTML escaping/stripping
- (void)testEscapingPlain
{
    NSString *expected = @"This is plain text.";
    NSString *actual = [expected stringByEscapingHTML];
    STAssertEqualObjects(actual, expected, @"escaping went wrong");
}

- (void)testEscaping
{
    NSString *expected = @"This is &lt;escaped&gt; &amp; safe.";
    NSString *actual = [@"This is <escaped> & safe." stringByEscapingHTML];
    STAssertEqualObjects(actual, expected, @"escaping went wrong");
}

- (void)testStrippingPlain
{
    NSString *expected = @"This is plain text.";
    NSString *actual = [expected stringByStrippingHTML];
    STAssertEqualObjects(actual, expected, @"stripping went wrong");
}

- (void)testStripping
{
    NSString *expected = @"This is plain text.";
    NSString *actual = [@"This is <em>plain</em> text." stringByStrippingHTML];
    STAssertEqualObjects(actual, expected, @"stripping went wrong");
}

#pragma mark Test date parsing
- (void)testDateParsing
{
    NSDate *d;
    NSArray *goodDates = [NSArray arrayWithObjects:
                          @"2012", @"2012-02", @"2012-02-13",
                          @"2012-02-13T19:49Z",
                          @"2012-02-13T19:49+0100",
                          nil];
    for (id date in goodDates) {
        d = [NSDate dateFromOPFString:date];
        STAssertNotNil(d, @"%@ should parse", date);
    }
    
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

- (void)testUnexpiringAdobe
{
    NSDate *actual = [adeptFile expiryDate];
    STAssertNil(actual, @"fake-adept should not expire");
}

- (void)testUnexpiringApple
{
    NSDate *actual = [fairplayFile expiryDate];
    STAssertNil(actual, @"fake-fairplay should not expire");
}

- (void)testExpiringAdobe
{
    NSDate *actual = [libraryFile expiryDate];
    STAssertNotNil(actual, @"fake-library does not expire");
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

#pragma mark Test creators (for Spotlight)
- (void)testUntitledCreators
{
    NSArray *actual = [untitledFile creators];
    NSArray *expected = [NSArray arrayWithObjects:@"Test Author", @"Test Illustrator",
                         @"Test Editor", @"Test Translator", nil];
    STAssertTrue([actual count] == [expected count], @"Untitled file has wrong number of creators");
    for (id item in expected) {
        STAssertTrue([actual containsObject:item], @"Creator is missing");
    }
}

- (void)testMetadataCreators
{
    NSArray *actual = [metadataFile creators];
    NSArray *expected = [NSArray arrayWithObjects:@"Primary Author", @"Second Author", @"Third Author", nil];
    // metadata has one contributor for each known MARC role and then 3 authors
    // Just check the authors are present, and the total is right.
    STAssertTrue([actual count] == 228, @"metadata file has wrong number of creators");
    for (id item in expected) {
        STAssertTrue([actual containsObject:item], @"Creator is missing");
    }
}

#pragma mark Test language
- (void)testUntitledLanguage
{
    NSArray *actual = [untitledFile language];
    NSArray *expected = [NSArray arrayWithObject:@"en"];
    
    STAssertTrue([actual count] == [expected count], @"Untitled file has wrong number of languages");

    for (id item in expected) {
        STAssertTrue([actual containsObject:item], @"Language is missing");
    }

}


@end
