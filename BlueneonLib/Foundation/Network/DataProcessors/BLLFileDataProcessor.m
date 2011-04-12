//
//  BLLFileDataProcessor.m
//  Feed
//
//  Created by Alex Carter on 10-05-22.
//
//  Copyright 2011 Alex Carter. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of
//  conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list
//  of conditions and the following disclaimer in the documentation and/or other materials
//  provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Alex Carter.
//

#import "BLLFileDataProcessor.h"

NSString* const kBLLFileDataProcessorErrorDomain = @"com.blueneon.blueneonLib.fileDataProcessor.errorDomain";
NSUInteger const kErrorWritingData = 1001;

@interface BLLFileDataProcessor ()
@property (nonatomic, retain) NSString* filePath;
@property (nonatomic, retain) NSFileHandle* fileWriter;
-(BOOL) initializeFileForWritingWithPath:(NSString*) aFilePath error:(NSError**)error;
@end


@implementation BLLFileDataProcessor
@synthesize filePath;
@synthesize fileWriter;


+(BLLFileDataProcessor*) fileDataProcessorWithPath:(NSString*) path
{
	return [[[BLLFileDataProcessor alloc] initWithFilePath:path] autorelease];
}

- (id) initWithFilePath:(NSString*) aFilePath
{
	self = [super init];
	if (self != nil) 
	{
		self.filePath = aFilePath;
		self.fileWriter = nil;
	}
	return self;
}

- (void) dealloc
{
	self.filePath = nil;
	self.fileWriter = nil;
	[super dealloc];
}


-(BOOL) processData:(NSData*) data error:(NSError**) error
{
	BOOL success = NO;
	@try
	{
		[self.fileWriter writeData:data];		
		success = YES;
	}
	@catch (NSException * e) 
	{
		NSMutableDictionary* errorInfo = [NSMutableDictionary dictionary];
		[errorInfo setObject:[e name] forKey:NSLocalizedDescriptionKey];
		[errorInfo setObject:[e reason] forKey:NSLocalizedFailureReasonErrorKey];
		(*error) = [NSError errorWithDomain:kBLLFileDataProcessorErrorDomain code:kErrorWritingData userInfo:errorInfo];
	}
	return success;
}

-(id) result
{
	return filePath;
}

-(BOOL) initializeProcessingWithError:(NSError**) error
{	
	NSString* aFilePath = self.filePath;
	return [self initializeFileForWritingWithPath:aFilePath error:error];
}

-(BOOL) finalizeProcessingWithError:(NSError**) error
{
	[self.fileWriter closeFile];
	
	return YES;
}

-(BOOL) resetProcessingWithError:(NSError**) error
{
	NSString* aFilePath = self.filePath;
	return [self initializeFileForWritingWithPath:aFilePath error:error];
}

-(BOOL) initializeFileForWritingWithPath:(NSString*) aFilePath error:(NSError**)error
{	
	BOOL success = NO;
	
	// Create a file overwiting any existing file
	if ([[NSFileManager defaultManager] createFileAtPath:aFilePath contents:[NSData data] attributes:nil]) 
	{
		self.fileWriter = [NSFileHandle fileHandleForWritingAtPath:aFilePath];
		if(self.fileWriter)
		{
			success = YES;
		}
	}
	return success;
}

@end
