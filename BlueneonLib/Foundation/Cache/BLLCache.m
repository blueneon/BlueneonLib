//
//  BLLCache.m
//  Feed
//
//  Created by Alex Carter on 10-06-19.
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

#import "BLLCache.h"
#import "NSString+md5.h"
#import "BLLNetwork.h"
#import "BLLErrorHandler.h"

NSString* const kBLLCacheDidFetchItemNotification = @"com.blueneon.blueneonLib.cache.didFetchItemNotification";
NSString* const kBLLCacheFileURLKey = @"com.blueneon.blueneonLib.cache.fileURLKey";


@interface BLLCache ()

@property (retain) NSString* diskCachePath;
@property (retain) NSMutableDictionary* memoryCache;
@property (retain) NSOperationQueue* networkOperationQueue;

-(void) downloadFileAtURL:(NSURL*) aURL;
-(NSString*) filenameFromURL:(NSURL*)aURL;
-(id) objectWithURL:(NSURL *)aURL class:(Class) aClass;
-(void) handleDidRecieveMemoryWarning:(NSNotification*) aNotification;
-(void) handleNetworkOperationDidFinishNotification:(NSNotification*) aNotification;
@end


@implementation BLLCache
@synthesize diskCachePath;
@synthesize memoryCache;
@synthesize networkOperationQueue;
@synthesize name;


+(BLLCache*) defaultCache
{
	static BLLCache* __defaultCache = nil;
	if(__defaultCache == nil)
	{
		__defaultCache = [[BLLCache alloc] init];
	}
	return __defaultCache;
}

- (id) init
{
	self = [self initWithName:@"defaultCache"];
	if (self != nil) {
	}
	return self;
}

- (id) initWithName:(NSString*) aName
{
	self = [self initWithName:aName path:[NSTemporaryDirectory() stringByAppendingPathComponent:aName]];
	if (self != nil) {
	}
	return self;
}

- (id) initWithName:(NSString*) aName path:(NSString*) path
{
	self = [super init];
	if (self != nil) {
		self.diskCachePath = path;
		self.memoryCache = [NSMutableDictionary dictionary];
		self.networkOperationQueue = [[[NSOperationQueue alloc] init] autorelease];
		[self.networkOperationQueue setSuspended:NO];
		self.name = aName;
        
#if TARGET_OS_EMBEDDED   
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleDidRecieveMemoryWarning:) 
													 name:UIApplicationDidReceiveMemoryWarningNotification 
												   object:nil];
#endif
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleNetworkOperationDidFinishNotification:) 
													 name:kBLLNetworkOperationDidFinishNotification 
												   object:nil];
	}
	return self;
}

- (void) dealloc
{	
	[self.networkOperationQueue cancelNetworkOperationsWithContext:self.name];
#if TARGET_OS_EMBEDDED
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:UIApplicationDidReceiveMemoryWarningNotification 
												  object:nil];
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:kBLLNetworkOperationDidFinishNotification 
												  object:nil];
	
	self.diskCachePath = nil;
	self.memoryCache = nil;
	self.networkOperationQueue = nil;
	self.name = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark File Downloader  

-(void) downloadFileAtURL:(NSURL*) aURL
{
	NSArray* operationURLs = [self.networkOperationQueue valueForKeyPath:@"operations.URLRequest.URL"];
	
	if(![operationURLs containsObject:aURL])
	{
		if(![[NSFileManager defaultManager]fileExistsAtPath:self.diskCachePath])
		{
			NSError* error = nil;
			if (![[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath withIntermediateDirectories:YES attributes:nil error:&error])
			{
				NSLog(@"Error: %@ calling createDirectoryAtPath: %@ in downloadFileAtURL:",error,self.diskCachePath);
				return;
			}
		}
		
		NSURLRequest* request = [NSURLRequest requestWithURL:aURL];
		NSString* cachedImagePath = [self.diskCachePath stringByAppendingPathComponent:[self filenameFromURL:aURL]]; 
		cachedImagePath = [cachedImagePath stringByAppendingPathExtension:@"tmp"];
		BLLNetworkOperation* op = [BLLNetworkOperation networkOperationWithURLRequest:request toFilePath:cachedImagePath];
		op.context = self.name;
		[self.networkOperationQueue addOperation:op];
	}
}

-(void) handleNetworkOperationDidFinishNotification:(NSNotification*) aNotification
{
	BLLNetworkOperation* op = (BLLNetworkOperation*)[aNotification object];
	
	NSString* tmpFilePath = [op download];
	NSString* filePath = [tmpFilePath stringByDeletingPathExtension];
	
	NSError* error = nil;
	if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		if([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
		{
			[[BLLErrorHandler defaultErrorHandler] presentError:error];	
		}
	}
	
	error = nil;
	if(![[NSFileManager defaultManager] moveItemAtPath:tmpFilePath toPath:filePath error:&error])
	{
		[[BLLErrorHandler defaultErrorHandler] presentError:error];
	}
	else
	{
		NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  op.URLRequest.URL, kBLLCacheFileURLKey,
								  nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBLLCacheDidFetchItemNotification
															object:self 
														  userInfo:userInfo];
	}
}

#pragma mark -
#pragma mark Memory management

-(void) handleDidRecieveMemoryWarning:(NSNotification*) aNotification
{
	[self flush:NO];
}

#pragma mark -
#pragma mark Private implementation

-(NSString*) filenameFromURL:(NSURL*)aURL
{
	return [[aURL absoluteString] md5Hash];
}


-(id) objectWithURL:(NSURL *)aURL class:(Class) aClass
{
	id cachedObject = nil;
	
	if (aURL) {		
		@synchronized (self)
		{
			cachedObject = [memoryCache objectForKey:aURL];
			
			
			if(cachedObject == nil)
			{
				NSString* cachedDataPath = [self.diskCachePath stringByAppendingPathComponent:[self filenameFromURL:aURL]]; 
				if([[NSFileManager defaultManager] fileExistsAtPath:cachedDataPath])
				{
					cachedObject = [[[aClass alloc] initWithContentsOfFile:cachedDataPath] autorelease];
					if (cachedObject)
					{
						[memoryCache setObject:cachedObject forKey:aURL];
					}
				}
				
				if (cachedObject == nil)
				{
					NSError *error = nil;
					if(![[NSFileManager defaultManager]removeItemAtPath:cachedDataPath error:&error])
					{
						[[BLLErrorHandler defaultErrorHandler] presentError:error];
					}								
					[self downloadFileAtURL:(NSURL*) aURL];
				}
			}
		}
	}
	NSAssert (([cachedObject isKindOfClass:aClass] || cachedObject == nil),@"Cached object type missmatch.");
	return cachedObject;
}


#pragma mark -
#pragma mark Interface implementation
#if TARGET_OS_EMBEDDED
-(UIImage*) imageWithURL:(NSURL *)aURL
{
	UIImage* cachedImage = [self objectWithURL:aURL class:[UIImage class]];;
	return cachedImage;	
}
#endif

-(NSData*) dataWithURL:(NSURL *)aURL
{
	NSData* cachedData = [self objectWithURL:aURL class:[NSData class]];
	return cachedData;
}

-(void) evictObjectWithURL:(NSURL *)aURL
{
	@synchronized (self)
	{
		[memoryCache removeObjectForKey:aURL];
		NSString* cachedImagePath = [self.diskCachePath stringByAppendingPathComponent:[self filenameFromURL:aURL]]; 
		NSError* error = nil;
		if(![[NSFileManager defaultManager] removeItemAtPath:cachedImagePath error:&error])
		{
			NSLog(@"Error: %@ calling removeItemAtPath: %@ in evictImageWithURL:%@",error,self.diskCachePath,aURL);
		}
	}
}

-(void) flush:(BOOL) deepFlush
{
	@synchronized (self)
	{
		[self.memoryCache removeAllObjects];
		
		if(deepFlush)
		{
			NSError* error = nil;
			if(![[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:&error])
			{
				NSLog(@"Error: %@ calling removeItemAtPath: %@ in flush:",error,self.diskCachePath);
			}
			error = nil;
			if(![[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath withIntermediateDirectories:YES attributes:nil error:&error])
			{
				NSLog(@"Error: %@ calling createDirectoryAtPath: %@ in flush:",error,self.diskCachePath);
			}
		}
	}
}

@end
