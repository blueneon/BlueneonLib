//
//  CoreDataManager.m
//  Feed
//
//  Created by Alex Carter on 10-05-11.
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

#import "BLLCoreDataManager.h"
#import "BLLManagedObjectContext.h"


@implementation BLLCoreDataManager
@synthesize storeURL;
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;

+(BLLCoreDataManager*) sharedInstanceWithStoreURL:(NSURL*) aURL
{
	BLLCoreDataManager* coreDataManager = [BLLCoreDataManager sharedInstance];
	NSAssert(coreDataManager.storeURL == nil,@"The singleton core data manager can only be initialized once with a store URL");
	coreDataManager.storeURL = aURL;
	return coreDataManager;
}

+(BLLCoreDataManager*) sharedInstance
{
	static BLLCoreDataManager* __sharedInstance = nil;
	if(__sharedInstance == nil)
	{
		__sharedInstance = [[BLLCoreDataManager alloc] init];
	}
	return __sharedInstance;
}

+(NSMutableDictionary*) idMapForEntityName:(NSString*) entityName IDKeyPath:(NSString*) idKeyPath context:(NSManagedObjectContext*) context
{
	NSError* anError = nil;
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
	request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	
	NSArray* existingObjects = [context executeFetchRequest:request error:&anError]; 
	
	for (id object in existingObjects)
	{
		[result setObject:[object objectID] forKey:[object valueForKeyPath:idKeyPath]];
	}
	
	return result;
}


- (id) init
{
	self = [super init];
	if (self != nil) {
		managedObjectContext = nil;
		managedObjectModel = nil;
		persistentStoreCoordinator = nil;

	}
	return self;
}

- (void) dealloc
{
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	[super dealloc];
}


#pragma mark Core Data stack


- (NSManagedObjectContext *) backgroundManagedObjectContext
{
	NSPersistentStoreCoordinator *sharedPersistentStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
	NSManagedObjectContext *backgroundManagedObjectContext = [[[BLLManagedObjectContext alloc] init] autorelease]; 
	[backgroundManagedObjectContext setPersistentStoreCoordinator:sharedPersistentStoreCoordinator]; 
	return backgroundManagedObjectContext;
}

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[BLLManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:nil error:&error]) {
			
		NSLog(@"Store could note be loaded. Nukeing it.");
		
		[[NSFileManager defaultManager] removeItemAtPath:[self.storeURL path] error:nil];		
		// Try aggain
		persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:nil error:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}
			
    }    
	
    return persistentStoreCoordinator;
}

#pragma mark -

-(id) newManagedObjectWithClass:(Class) aClass
{
	NSAssert([NSThread isMainThread], @"newManagedObjectWithClass must be called on the main thread.");
	return [self newManagedObjectWithClass:aClass context:self.managedObjectContext];
}

-(id) newManagedObjectWithClass:(Class) aClass context:(NSManagedObjectContext*) aContext;
{
	return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(aClass) 
										 inManagedObjectContext:aContext];

}

-(NSArray*) objectsWithClass:(Class) aClass 
{
	NSAssert([NSThread isMainThread], @"objectsWithClass must be called on the main thread.");
	return [self objectsWithClass:aClass context:self.managedObjectContext];
}

-(NSArray*) objectsWithClass:(Class) aClass context:(NSManagedObjectContext*) aContext
{
	NSArray* result = nil;
	NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity: [NSEntityDescription entityForName:NSStringFromClass(aClass) 
									inManagedObjectContext:aContext]];
	
	NSError* error = nil;
	result = [aContext executeFetchRequest:request error:&error];	
	if (!result) 
	{
		NSLog(@"Fetch error %@, %@", error, [error userInfo]);
	}
	return result;
}


@end
