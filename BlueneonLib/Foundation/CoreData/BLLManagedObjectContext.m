//
//  BLLManagedObjectContext.m
//  RemoteData
//
//  Created by Alex Carter on 10-06-11.
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

#import "BLLManagedObjectContext.h"
#import "BLLCoreDataManager.h"
#import "NSFetchRequest+BLLNetwork.h"
#import "BLLRemoteManagedObjectProtocol.h"
#import "BLLNetwork.h"


NSString* const kBLLManagedObjectsContextBaseURLKey = @"kBLLManagedObjectsContextBaseURLKey"; 

@interface BLLManagedObjectContext ()
@property (retain, readonly) NSManagedObjectContext* backgroundManagedObjectContext;
@property (retain) id didSaveNotificationObserver;


-(void) performNetworkRequest:(NSFetchRequest*)aFetchRequest;
@end


@implementation BLLManagedObjectContext
@dynamic backgroundManagedObjectContext;
@synthesize didSaveNotificationObserver;
@synthesize baseURL;

- (id) init
{
	NSString* baseURLString = [[NSUserDefaults standardUserDefaults] stringForKey:kBLLManagedObjectsContextBaseURLKey];
	
	NSLogDebug(@"Defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
	
	NSURL* aBaseURL = nil;
	if (baseURLString)
		aBaseURL = [NSURL URLWithString:baseURLString];
	
	self = [self initWithBaseURL:aBaseURL];
	if (self != nil) {
		backgroundManagedObjectContext = nil;
	}
	return self;
}


- (id) initWithBaseURL:(NSURL*) aBaseURL
{
	self = [super init];
	if (self != nil) {
		backgroundManagedObjectContext = nil;
		self.baseURL = aBaseURL;
	}
	return self;
}


- (void) dealloc
{
	
	[[NSNotificationCenter defaultCenter] removeObserver:didSaveNotificationObserver 
													name:NSManagedObjectContextDidSaveNotification 
												  object:backgroundManagedObjectContext];
	self.didSaveNotificationObserver = nil;
	[backgroundManagedObjectContext release];
	backgroundManagedObjectContext = nil;
	
	[super dealloc];
}





- (NSArray *)executeFetchRequest:(NSFetchRequest *)request error:(NSError **)error
{

	if([request requiresNetworkRequest])
	{
		[self performNetworkRequest:request]; 
	}
	
	NSArray* result = [super executeFetchRequest:request error:error];
	return result;
}

#pragma mark -
#pragma mark Accessors
-(NSManagedObjectContext*) backgroundManagedObjectContext
{
	if(backgroundManagedObjectContext == nil)
	{
		NSPersistentStoreCoordinator *sharedPersistentStoreCoordinator = [self persistentStoreCoordinator];
		backgroundManagedObjectContext = [[NSManagedObjectContext alloc] init]; 
		[backgroundManagedObjectContext setPersistentStoreCoordinator:sharedPersistentStoreCoordinator]; 
	
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleManagedObjectContextDidSaveNotification:) 
													 name:NSManagedObjectContextDidSaveNotification 
												   object:backgroundManagedObjectContext];
	}
	return backgroundManagedObjectContext;
}

#pragma mark -
#pragma mark NetworkFetchReques

-(void) handleManagedObjectContextDidSaveNotification:(NSNotification*) aNotification
{
	if([NSThread isMainThread])
	{
		[self mergeChangesFromContextDidSaveNotification:aNotification];
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(handleManagedObjectContextDidSaveNotification:) 
							   withObject:aNotification 
							waitUntilDone:NO];
	}
}

-(void) performNetworkRequest:(NSFetchRequest*)aFetchRequest
{

	NSAssert(NO,@"Implement '-(void) performNetworkRequest:(NSFetchRequest*)aFetchRequest' in a subclass to initialize the network fetch");
	//	// TODO: get the URLRequest from a factory
//	NSURLRequest* URLrequest = [aFetchRequest URLRequestWithBaseURL:baseURL];
//	
//	// TODO: get the Processor from a factory
//	ItemProcessor* itemProcessor = [[ItemProcessor alloc] initWithManagedObjectContext:[self backgroundManagedObjectContext]
//																		  fetchRequest:aFetchRequest];
//	
//	BLLNetworkOperation* op = [[BLLNetworkOperation alloc] initWithURLRequest:URLrequest dataProcessor:itemProcessor];
//	[[NSOperationQueue serialNetworkOperationQueue] addOperation:op];
//	[itemProcessor release];
//	[op release];	
}
// TODO END


@end
