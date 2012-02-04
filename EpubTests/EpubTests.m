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

- (void)testTitleWithAmpersand
{
    NSString *actual = [metadataFile title];
    NSString *expected = @"This & That";
    STAssertEqualObjects(actual, expected, @"Title should be %@ but is %@", actual, expected);
}

- (void)testAuthors
{
    NSArray *actual = [untitledFile authors];
    NSString *expected = @"Test Author";
    STAssertTrue([actual count] == 1, @"1 author expected");
    STAssertEqualObjects([actual lastObject], expected, @"Author should be %@ but is %@", [actual lastObject], expected);
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
    NSString *expected = @"Test Translator";
    STAssertTrue([actual count] == 1, @"1 translator expected");
    STAssertEqualObjects([actual lastObject], expected, @"Translator should be %@ but is %@", [actual lastObject], expected);
}

- (void)testIllustrator
{
    NSArray *actual = [untitledFile illustrators];
    NSString *expected = @"Test Illustrator";
    STAssertTrue([actual count] == 1, @"1 illustrator expected");
    STAssertEqualObjects([actual lastObject], expected, @"Illustrator should be %@ but is %@", [actual lastObject], expected);
}

- (void)testThreeAuthors
{
    NSArray *actual = [metadataFile authors];
    NSString *expected0 = @"Primary Author";
    NSString *expected1 = @"Second Author";
    NSString *expected2 = @"Third Author";
    STAssertTrue([actual count] == 3, @"3 authors expected");
    STAssertEqualObjects([actual objectAtIndex:0], expected0, @"First author should be %@ but is %@", [actual objectAtIndex:0], expected0);
    STAssertEqualObjects([actual objectAtIndex:1], expected1, @"Second author should be %@ but is %@", [actual objectAtIndex:1], expected1);
    STAssertEqualObjects([actual objectAtIndex:2], expected2, @"Third author should be %@ but is %@", [actual objectAtIndex:2], expected2);
}
@end
