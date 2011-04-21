//
//  BLLArrayController.m
//  TheNobleSage
//
//  Created by Alex Carter on 10-08-02.
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

#import "BLLArrayController.h"
#import "BLLPair.h"

@interface BLLArrayController ()
-(void) handleManagedObjectContextObjectsDidChangeNotification:(NSNotification*) note;
-(void) performUpdateCheck:(NSSet*) updatedObjects;
-(void) performUpdateNotificationWithObjects:(NSSet*) updatedObjects;
@end


@implementation BLLArrayController
@synthesize arrangedObjects=_arrangedObjects;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize delegate;

-(id) initWithArray:(NSArray*)anArray managedObjectContext:(NSManagedObjectContext*) aManagedObjectContext
{
	self = [super init];
	if (self != nil) {
		_arrangedObjects = [anArray retain];
		_managedObjectContext = [aManagedObjectContext retain];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleManagedObjectContextObjectsDidChangeNotification:) 
													 name:NSManagedObjectContextObjectsDidChangeNotification 
												   object:aManagedObjectContext];
		
	}
	return self;
}

-(void) handleManagedObjectContextObjectsDidChangeNotification:(NSNotification*) notification
{
	NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
	[self performSelectorInBackground:@selector(performUpdateCheck:) withObject:updatedObjects];
}

-(void) performUpdateCheck:(NSSet*) updatedObjects
{  
	NSMutableSet* updatedArrayObjects = [NSMutableSet set];
	
	NSUInteger index = 0;
	for (NSManagedObject* obj in self.arrangedObjects)
	{
		
		if([updatedObjects containsObject:obj])
		{
			[updatedArrayObjects addObject:[BLLPair pairWithFirstValue:obj secondValue:[NSNumber numberWithInteger:index]]];
		}
		index++;
	}	
	
	[self performSelectorOnMainThread:@selector(performUpdateNotificationWithObjects:) withObject:updatedArrayObjects waitUntilDone:NO];	
}


-(void) performUpdateNotificationWithObjects:(NSSet*) updatedObjects
{
	if([self.delegate respondsToSelector:@selector(controllerWillChangeContent:)])
	{
		[self.delegate controllerWillChangeContent:self];
	}
	if([self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndex:)])
	{
		for (BLLPair* pair in updatedObjects)
		{
			NSManagedObject* obj = [pair firstValue];
			NSUInteger index = [[pair secondValue] intValue];
			[self.delegate controller:self didChangeObject:obj atIndex:index];			
		}

	}

	if([self.delegate respondsToSelector:@selector(controllerDidChangeContent:)])
	{
		[self.delegate controllerDidChangeContent:self];
	}
}

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 											 
												 name:NSManagedObjectContextObjectsDidChangeNotification 
											   object:self.managedObjectContext];
	self.delegate = nil;
	
	[_arrangedObjects release];
	_arrangedObjects = nil;
	[_managedObjectContext release];
	_managedObjectContext = nil;
	
    [super dealloc];
}


@end
