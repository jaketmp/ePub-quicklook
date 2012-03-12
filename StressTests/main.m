//
//  main.m
//  StressTests
//
//  Created by Jake Pearce on 08/03/2012.
//  Copyright (c) 2012 Imperial College. All rights reserved.
//

#import "JTPepub.h"
#import "NSDate+OPF.h"
#import "NSString+HTML.h"


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        
        
        #pragma mark Stress Tests
        /*
         * Repeatedly init, a JTPepub object, and run it's methods for profiling purposes.
         */

        
        // Using 'NSASCIIStringEncoding' here is suspect...
        NSString *epubPath = [[NSString alloc] initWithCString:argv[1] encoding:NSASCIIStringEncoding];
        int innerLoop = 100;
        int outerLoop = 7;
        
        // Two loops so we can periodicly emplty the autorelease pool
        for (int i = 0; i < outerLoop; i++) {
            NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
            
            for (int j = 0; j < innerLoop; j++) {
                JTPepub *epub = [[JTPepub alloc] initWithFile:epubPath];
                
                NSString *title = [epub title];
                NSArray *authors = [epub authors];
                NSString *publisher = [epub publisher];
                NSArray *creators = [epub creators];
                NSArray *editors = [epub editors];
                NSArray *illustrators = [epub illustrators];
                NSArray *translators = [epub translators];
                NSImage *cover = [epub cover];
                NSString *synopsis = [epub synopsis];
                NSDate *publicationDate = [epub publicationDate];
                NSString *isbn = [epub isbn];
                NSString *drm = [epub drm];
                NSMutableArray *language = [epub language];
                
                
                [epub release];
                
            }
            
            [loopPool release];
            NSLog(@"outer iteration %i", i);

        }
        [epubPath release];
    }
    
    
    NSLog(@"done");
    return 0;
}

