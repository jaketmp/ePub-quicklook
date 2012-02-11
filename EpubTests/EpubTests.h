//
//  EpubTests.h
//  EpubTests
//
//  Created by Chris Ridd on 01/02/2012.
//  Copyright (c) 2012 Chris Ridd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class JTPepub;

@interface EpubTests : SenTestCase {
    JTPepub *untitledFile;
    JTPepub *metadataFile;
    JTPepub *badcontributorFile;
    JTPepub *adeptFile;
    JTPepub *fairplayFile;
    JTPepub *koboFile;
}
@end
