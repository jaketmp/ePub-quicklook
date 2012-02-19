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

/*
 * All I/O in unzip is performed using a number of custom functions which can
 * be overridden. The default functions use stdio.
 * This implementation uses NSData to mmap the data into memory.
 *
 * The "stream" is the NSData object.
 * The "opaque" value is a pointer to the current file offset.
 */
void *mmap_zopen(void *, const char *, int);
int mmap_zclose(void *, void *);
long mmap_ztell(void *, void *);
long mmap_zseek(void *, void *, unsigned long, int);
int mmap_zerror(void *, void *);
unsigned long mmap_zread(void *, void *, void *, unsigned long);

// NB this ignores the mode flag and opens the file read-only.
void *mmap_zopen(void *opaque, const char *filename, int mode)
{
    NSInteger *pos = (NSInteger *)opaque;
    NSError *error;
    NSData *d = [[NSData alloc] initWithContentsOfFile:[NSString stringWithUTF8String:filename]
                                               options:NSDataReadingMapped
                                                 error:&error];
    *pos = 0;
    return (void *)d;
}

int mmap_zclose(void *opaque, void *stream)
{
    NSInteger *pos = (NSInteger *)opaque;
    NSData *d = (NSData *)stream;
    *pos = 0;
    [d release];
    return Z_OK;
}

long mmap_ztell(void *opaque, void *stream)
{
    NSInteger *pos = (NSInteger *)opaque;
    long ret = (long)*pos;
    return ret;
}

long mmap_zseek(void *opaque, void *stream, unsigned long offset, int origin)
{
    NSInteger *pos = (NSInteger *)opaque;
    NSData *d = (NSData *)stream;
    NSInteger newpos;
    switch (origin) {
        case ZLIB_FILEFUNC_SEEK_CUR:
            newpos = *pos + offset;
            break;
        case ZLIB_FILEFUNC_SEEK_END:
            newpos = [d length] - offset;
            break;
        case ZLIB_FILEFUNC_SEEK_SET:
            newpos = offset;
            break;
        default:
            return -1;
    }
    *pos = newpos;
    return 0;
}

int mmap_zerror(void *opaque, void *stream)
{
    NSInteger *pos = (NSInteger *)opaque;
    NSData *d = (NSData *)stream;
    if (*pos < 0 || *pos > [d length])
        return -1;
    return 0;
}

unsigned long mmap_zread(void *opaque, void *stream, void *buf, unsigned long size)
{
    NSInteger *pos = (NSInteger *)opaque;
    NSData *d = (NSData *)stream;
    const unsigned char *bytes = (const unsigned char *)[d bytes] + *pos;
    memcpy(buf, bytes, size);
    *pos += size;
    return size;
}

@implementation ZipArchive

-(id) init
{
    self = [super init];
	if(self)
	{
		_zipFile = nil ;
        archiveName = nil;
        mmap_defs.zopen_file = mmap_zopen;
        mmap_defs.zread_file = mmap_zread;
        mmap_defs.zwrite_file = NULL; // no writing!
        mmap_defs.ztell_file = mmap_ztell;
        mmap_defs.zseek_file = mmap_zseek;
        mmap_defs.zclose_file = mmap_zclose;
        mmap_defs.zerror_file = mmap_zerror;
        mmap_defs.opaque = &(self->pos);
	}
	return self;
}

-(id) initWithZipFile:(NSString *)fileName {
    self = [self init];
    
    archiveName = fileName;
    
    [fileName retain];
    
    _zipFile = unzOpen2([fileName fileSystemRepresentation], &(self->mmap_defs));
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
    if (archiveName != nil) {
        [archiveName release];
    }
	[super dealloc];
}
/*
 * Test for the existance of fileName in the archive.
 * Returns true if found.
 */
-(BOOL) testForNamedFile:(NSString *)fileName
{
    int             result;
    
    result = unzLocateFile( _zipFile, [fileName UTF8String], 0 );
    
    return result == UNZ_OK;
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
        NSLog(@"Unable to locate %@ in %@", fileName, archiveName);
        return nil;
	}
    
	result = unzGetCurrentFileInfo( _zipFile, &info, NULL, 0, NULL, 0, NULL, 0 );
	if ( result != UNZ_OK ) {
        NSLog(@"Unable to extract file info for: %@", fileName);
        return nil;
	}
    
	result = unzOpenCurrentFile( _zipFile );
	if ( result != UNZ_OK ) {
        // more error checking here
        NSLog(@"Unable to open file %@ for extration from archive", fileName);
        return nil;
	}
    
	buffer = (UInt8*)malloc(info.uncompressed_size);
	result = unzReadCurrentFile( _zipFile, buffer, (uint)info.uncompressed_size );
	if ( result != info.uncompressed_size ) {
		// Error checking	
        NSLog(@"Failed to read %@ from archive", fileName);
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


