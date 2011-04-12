//
//  BLLDownloadOperation.m
//  Feed
//
//  Created by Alex Carter on 10-05-16.
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

#import "BLLNetworkOperation.h"
#import "BLLDataProcessor.h"
#import "BLLFileDataProcessor.h"
#import "BLLDefaultErrorHandler.h"


NSString* const kBLLNetworkOperationDidFinishNotification = @"com.blueneon.blueneonLib.networkOperation.didFinishNotification";
NSString* const kBLLNetworkOperationDidFailNotification = @"com.blueneon.blueneonLib.networkOperation.didFailNotification";
NSString* const kBLLNetworkOperationErrorDomain = @"com.blueneon.blueneonLib.networkOperation.errorDomain";
NSUInteger const kErrorCouldNotCreateConnnection = 1000;
NSUInteger const kErrorCouldNotInitializeDataProcessor = 1001;
NSUInteger const kErrorDataProcessingFailed = 1002;
NSUInteger const kErrorCouldNotFinalizeDataProcessing = 1003;
NSUInteger const kErrorCouldNotResetDataProcessor = 1004;

@interface BLLNetworkOperation ()
@property (nonatomic, retain) NSURLConnection* URLConnection;
@property (nonatomic, assign) BOOL executing;
@property (nonatomic, assign) BOOL finished;

-(void) startOperation;
-(void) finishOperation;
-(void) postDidFinishNotification;
-(void) handleErrors;

@end

@implementation BLLNetworkOperation
@synthesize executing;
@synthesize finished;
@synthesize URLConnection;
@synthesize URLRequest;
@synthesize URLResponse;
@synthesize downloadError;
@synthesize dataProcessor;
@synthesize errorHandler;
@synthesize context;
@dynamic download;

+(id) networkOperationWithURLRequest:(NSURLRequest*) aURLRequest
{
	return [[[BLLNetworkOperation alloc] initWithURLRequest:aURLRequest] autorelease];
}

+(id) networkOperationWithURLRequest:(NSURLRequest*) aURLRequest toFilePath:(NSString*) path
{
	BLLFileDataProcessor* processor = [[[BLLFileDataProcessor alloc] initWithFilePath:path] autorelease];
	BLLNetworkOperation* op = [[[BLLNetworkOperation alloc] initWithURLRequest:aURLRequest 
																   dataProcessor:processor] autorelease];
	return op;
}

+(id) networkOperationWithURLRequest:(NSURLRequest*) aURLRequest dataProcessor:(id <BLLDataProcessorProtocol>) aDataProcessor
{
	BLLNetworkOperation* op = [[[BLLNetworkOperation alloc] initWithURLRequest:aURLRequest 
																 dataProcessor:aDataProcessor] autorelease];
	return op;
}

-(id) initWithURLRequest:(NSURLRequest*) aURLRequest
{
	return [self initWithURLRequest:aURLRequest 
					  dataProcessor:[[[BLLDataProcessor alloc] init]autorelease]];
}

-(id) initWithURLRequest:(NSURLRequest *)aURLRequest dataProcessor:(id <BLLDataProcessorProtocol>) aDataProcessor
{
	self = [super init];
	if (self != nil) {
		executing = NO;
		finished = NO;
		
		self.URLConnection = nil;
		self.URLRequest = aURLRequest;
		self.URLResponse = nil;
		self.dataProcessor = aDataProcessor;
		self.downloadError = nil;
		self.errorHandler = [[[BLLDefaultErrorHandler alloc] init] autorelease];
		self.context = nil;
	}
	return self;
}

- (void) dealloc
{
	executing = NO;
	finished = NO;
	self.URLConnection = nil;
	self.URLRequest = nil;
	self.URLResponse = nil;
	self.dataProcessor = nil;
	self.downloadError = nil;
	self.errorHandler = nil;
	self.context = nil;
	[super dealloc];
}

#pragma mark Acessors

-(void) setExecuting:(BOOL) value
{
	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"executing"];
	executing = value;
	[self didChangeValueForKey:@"executing"];
	[self didChangeValueForKey:@"isExecuting"];
}
-(BOOL) isExecuting 
{
	return self.executing;
}

-(void) setFinished:(BOOL) value
{	
	[self willChangeValueForKey:@"isFinished"];	
	[self willChangeValueForKey:@"finished"];
	finished = value;
	[self didChangeValueForKey:@"finished"];
	[self didChangeValueForKey:@"isFinished"];

}

-(BOOL) isFinished
{
	return self.finished;
}

-(id) download 
{
	return [self.dataProcessor result];
}
#pragma mark -

-(BOOL) isConcurrent
{
	return YES;
}

-(void) start
{
	[self setExecuting:YES];
	[self performSelectorInBackground:@selector(startOperation) withObject:nil];
}

-(void) cancel
{
	[super cancel];
	[self.URLConnection cancel];
	self.URLConnection = nil;
	self.URLResponse = nil;
	[self finishOperation];
}


#pragma mark NSURLConnection control

-(void) startOperation
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	if ([self.dataProcessor respondsToSelector:@selector(initializeProcessingWithError:)])
	{
		NSError* error = nil;
		if (![self.dataProcessor initializeProcessingWithError:&error])
		{
			NSMutableDictionary* errorInfo = [NSMutableDictionary dictionary];
			if(error != nil)
				[errorInfo setObject:error forKey:NSUnderlyingErrorKey];
			
			self.downloadError = [NSError errorWithDomain:kBLLNetworkOperationErrorDomain code:kErrorCouldNotInitializeDataProcessor userInfo:errorInfo];		
			[self finishOperation];
			[pool release];
			return;
		}
	}
	
	NSURLConnection* aURLConnection = [[[NSURLConnection alloc] initWithRequest:self.URLRequest delegate:self] autorelease];
	if(aURLConnection)
	{
		self.URLConnection = aURLConnection;
	}
	else 
	{
		self.downloadError = [NSError errorWithDomain:kBLLNetworkOperationErrorDomain code:kErrorCouldNotCreateConnnection userInfo:nil];
		[self finishOperation];
	}	
	
	while (!self.finished) 
	{
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[pool release];
}

-(void) finishOperation
{
	if (self.downloadError != nil && self.errorHandler != nil)
	{
		[self performSelectorOnMainThread:@selector(handleErrors) withObject:nil waitUntilDone:YES];
	}
	
	self.executing = NO;
	self.finished = YES;	
	
	[self performSelectorOnMainThread:@selector(postDidFinishNotification) withObject:nil waitUntilDone:YES];
}

-(void) handleErrors
{
	[self.errorHandler handleError:self.downloadError];
}

-(void) postDidFinishNotification
{
	if(self.downloadError == nil)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBLLNetworkOperationDidFinishNotification object:self];	
	}
	else 
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBLLNetworkOperationDidFailNotification object:self];	
	}
}

#pragma mark NSURLConnectionDelegate
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLogDebug(@"Main thread: %d", [NSThread isMainThread]);
	
	self.URLResponse = response;
	
	if ([self.dataProcessor respondsToSelector:@selector(resetProcessingWithError:)])
	{
		NSError* error = nil; 
		if(![self.dataProcessor resetProcessingWithError:&error])
		{
			NSMutableDictionary* errorInfo = [NSMutableDictionary dictionary];
			if(error != nil)
				[errorInfo setObject:error forKey:NSUnderlyingErrorKey];
			
			self.downloadError = [NSError errorWithDomain:kBLLNetworkOperationErrorDomain code:kErrorCouldNotResetDataProcessor userInfo:errorInfo];
			
			[self.URLConnection cancel];
			self.URLConnection = nil;
			self.URLResponse = nil;
			[self finishOperation];	
		}
	}
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
	NSError* error = nil;
	if(![self.dataProcessor processData:data error:&error])
	{
		NSMutableDictionary* errorInfo = [NSMutableDictionary dictionary];
		if(error != nil)
			[errorInfo setObject:error forKey:NSUnderlyingErrorKey];
		
		self.downloadError = [NSError errorWithDomain:kBLLNetworkOperationErrorDomain code:kErrorDataProcessingFailed userInfo:errorInfo];

		[self.URLConnection cancel];
		self.URLConnection = nil;
		self.URLResponse = nil;
		[self finishOperation];
		
	}
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([self.dataProcessor respondsToSelector:@selector(finalizeProcessingWithError:)])
	{
		NSError* error = nil;
		if (![self.dataProcessor finalizeProcessingWithError:&error])
		{
			NSMutableDictionary* errorInfo = [NSMutableDictionary dictionary];
			if(error != nil)
				[errorInfo setObject:error forKey:NSUnderlyingErrorKey];
			
			self.downloadError = [NSError errorWithDomain:kBLLNetworkOperationErrorDomain code:kErrorCouldNotFinalizeDataProcessing userInfo:errorInfo];
		}
	}
	
	self.URLConnection = nil;
	[self finishOperation];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.downloadError = error;
	self.URLConnection = nil;
	self.URLResponse = nil;
	[self finishOperation];
}

@end























