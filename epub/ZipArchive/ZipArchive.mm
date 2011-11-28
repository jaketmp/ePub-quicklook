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
    self = [super init];
	if(self)
	{
		_zipFile = nil ;
	}
	return self;
}
-(id) initWithZipFile:(NSString *)fileName {
    self = [self init];
    
    _zipFile = unzOpen([fileName   UTF8String]);
    if(_zipFile) {
        return self;
    }else{
        [self dealloc];
        return nil;
    }
    
}
-(void) dealloc
{
    if( _zipFile != nil) {        
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
        return nil;
	}
    
	result = unzGetCurrentFileInfo( _zipFile, &info, NULL, 0, NULL, 0, NULL, 0 );
	if ( result != UNZ_OK ) {
        NSLog(@"FAIL2");
        return nil;
	}
    
	result = unzOpenCurrentFile( _zipFile );
	if ( result != UNZ_OK ) {
        // more error checking here
        NSLog(@"FAIL3");
        return nil;
	}
    
	buffer = (UInt8*)malloc(info.uncompressed_size);
	result = unzReadCurrentFile( _zipFile, buffer, (uint)info.uncompressed_size );
	if ( result != info.uncompressed_size ) {
		// Error checking	
        NSLog(@"FAIL5");
        return nil;
    }
    
    // Use the malloc'd buffer rather than copy the data.
    data = [NSData dataWithBytesNoCopy:buffer length:info.uncompressed_size freeWhenDone:YES];
    
	/* Clean up after ourselves */
	unzCloseCurrentFile(_zipFile);
    
    return data;
}

-(BOOL) openZipFile:(NSString *)fileName {
    
    // check if we have a file open already.
    if (_zipFile != nil) {
        return FALSE;
    }
    
    _zipFile = unzOpen([fileName   UTF8String]);

    if(_zipFile != nil) {
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


