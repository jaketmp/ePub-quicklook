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
    untitledFile = [[JTPepub alloc] initWithFile:untitled];
    metadataFile = [[JTPepub alloc] initWithFile:metadata];
}

- (void)tearDown
{
    [metadataFile release];
    [untitledFile release];

    [super tearDown];
}

- (void)testTitle
{
    NSString *actual = [untitledFile title];
    NSString *expected = @"Test Document";
    STAssertEqualObjects(actual, expected, @"Title should be %@ but is %@", actual, expected);
}

- (void)testAuthor
{
    NSString *actual = [untitledFile author];
    NSString *expected = @"";
    STAssertEqualObjects(actual, expected, @"Author should be %@ but is %@", actual, expected);
}

- (void)testISBN
{
    NSString *actual = [untitledFile isbn];
    NSString *expected = @"123456789";
    STAssertEqualObjects(actual, expected, @"ISBN should be %@ but is %@", actual, expected);
}

- (void)testDate
{
    NSString *actual = [[untitledFile publicationDate] descriptionWithCalendarFormat:@"%Y" 
                                                                            timeZone:nil 
                                                                              locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
    NSString *expected = @"2011";
    STAssertEqualObjects(actual, expected, @"Date should be %@ but is %@", actual, expected);
}

- (void)testTranslator
{
    NSArray *actual = [untitledFile translators];
    STAssertTrue([actual count] == 0, @"No translators expected");
}

- (void)testIllustrator
{
    NSArray *actual = [untitledFile illustrators];
    STAssertTrue([actual count] == 0, @"No illustrators expected");
}

- (void)testThreeAuthors
{
    NSString *actual = [metadataFile author];
    NSString *expected = @"Primary Author, Second Author, Third Author";
    STAssertEqualObjects(actual, expected, @"Should have 3 authors but have %@", actual);
}
@end
