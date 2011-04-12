//
//  AppDelegate_Shared.m
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

#import "AppDelegate_Shared.h"
#import "UnitTests.h"

@implementation AppDelegate_Shared

@synthesize window;

+(void) initialize
{
	[NSURLToNSDataTransformer registerValueTransformer];
	[NSDictionaryToNSDataTransformer registerValueTransformer];
}


-(BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Feed.sqlite"]];
	//[BLLCoreDataManager sharedInstanceWithStoreURL:storeUrl];	

	//[[TestModel sharedInstance] runTest];
	[[TestDownloadManager sharedInstance] runTest];
		
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
//    if ([BLLCoreDataManager sharedInstance] != nil) {
//        if ([[BLLCoreDataManager sharedInstance].managedObjectContext hasChanges] && ![[BLLCoreDataManager sharedInstance].managedObjectContext save:&error]) {
//			/*
//			 Replace this implementation with code to handle the error appropriately.
//			 
//			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
//			 */
//			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        } 
//    }
}


#pragma mark -

#pragma mark Application's Documents directory
- (NSString *)applicationDocumentsDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    
	[window release];
	[super dealloc];
}


@end

