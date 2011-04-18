//
//  ZipArchive.mm
//  
//
//  Created by aish on 08-9-11.
//  acsolu@gmail.com
//  Copyright 2008  Inc. All rights reserved.
//

#import "ZipArchive.h"
#import "zlib.h"
#import "zconf.h"
#include <stdint.h>



@interface ZipArchive (Private)


@end



@implementation ZipArchive

-(id) init
{
	if( (self=[super init]) )
	{
		_zipFile = NULL ;
	}
	return self;
}
-(id) initWithZipFile:(NSString *)fileName {
    [self init];
    
    _zipFile = unzOpen([fileName   UTF8String]);
    
    return self;
}
-(void) dealloc
{
    if( _zipFile != NULL) {        
        [self closeZipFile];
    }
	[super dealloc];
}
-(NSData *) dataForNamedFile:(NSString *)fileName {
    NSData *data;
    
    // useful things from zlib/unzip.h
	unz_file_info	info;
	UInt8			*buffer;
	int             result;
    
    
	result = unzLocateFile( _zipFile, [fileName UTF8String], 0 );
	if ( result != UNZ_OK ) {
        // raise an error here
        NSLog(@"FAIL");
	}
    
	result = unzGetCurrentFileInfo( _zipFile, &info, NULL, 0, NULL, 0, NULL, 0 );
	if ( result != UNZ_OK ) {
        NSLog(@"FAIL2");

	}
    
	result = unzOpenCurrentFile( _zipFile );
	if ( result != UNZ_OK ) {
        // more error checking here
        NSLog(@"FAIL3");

	}
    
	buffer = (UInt8*)malloc(info.uncompressed_size);
	result = unzReadCurrentFile( _zipFile, buffer, info.uncompressed_size );
	if ( result != info.uncompressed_size ) {
		// Error checking	
        NSLog(@"FAIL5");

    }
    
    // Use the malloc'd buffer rather than copy the data.
    data = [NSData dataWithBytesNoCopy:buffer length:info.uncompressed_size freeWhenDone:YES];
    
	/* Clean up after ourselves */
	unzCloseCurrentFile(_zipFile);
    
    [data autorelease];
    return data;
}

-(BOOL) openZipFile:(NSString *)fileName {
    
    // should check if we have a file open already.
    
    _zipFile = unzOpen([fileName   UTF8String]);

    if(_zipFile != NULL) {
        return TRUE;
    }else{
        return FALSE;
    }
    
}

-(BOOL) closeZipFile {
    
    BOOL ret =  unzClose(_zipFile)==Z_OK?YES:NO;
    
    if (ret == TRUE) {
        _zipFile = NULL;
    }
        
    return ret;
}


@end


