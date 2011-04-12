//
//  TextDownloadManager.m
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

#import "TestDownloadManager.h"

#import "BLLNetwork.h"
 
@implementation TestDownloadManager

+(TestDownloadManager*) sharedInstance
{
	static TestDownloadManager* __sharedInstance = nil;
	if(__sharedInstance == nil)
	{
		__sharedInstance = [[TestDownloadManager alloc] init];
	}
	return __sharedInstance;
}

-(void) runTest
{
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleNetworkDidFinish:) 
												 name:kBLLNetworkOperationDidFinishNotification 
											   object:nil];
	
	
//	[self testDownloadManager];
	[self testNetworkOperationQueue];
}

#pragma mark Network Operation queue


-(void) downloadFileAtURL:(NSURL*) aURL
{
	NSArray* operationURLs = [[NSOperationQueue defaultNetworkOperationQueue] valueForKeyPath:@"operations.URLRequest.URL"];
	NSLog(@"Shoulfd download: %@",aURL);
	if(![operationURLs containsObject:aURL])
	{
		NSLog(@"queuing download: %@",aURL);
		NSURLRequest* request = [NSURLRequest requestWithURL:aURL 
												 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
											 timeoutInterval:2.0];
	
		BLLNetworkOperation* op = [BLLNetworkOperation networkOperationWithURLRequest:request];
		[[NSOperationQueue defaultNetworkOperationQueue] addOperation:op];

	}
}

-(void) testNetworkOperationQueue
{
	
	for (NSUInteger i = 0; i < 10; i++) {
		NSURL* url = [NSURL URLWithString:@"http://www.sandbox.blueneon.ca/items.json"];
		[self downloadFileAtURL:url];
		
	}
	
	
	
//	NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"google.html"];
//	op = [BLLNetworkOperation networkOperationWithURLRequest:[NSURLRequest requestWithURL:url]
//												  toFilePath:path];
//	op.context = @"filedownload";
//	[[NSOperationQueue defaultNetworkOperationQueue] addOperation:op];

}

-(void) handleNetworkDidFinish:(NSNotification*) anNotification
{
	NSLogDebug(@"Notification: %@", anNotification);
	
	BLLNetworkOperation* op = (BLLNetworkOperation*)anNotification.object;
	
	if ([@"filedownload" isEqualToString:op.context])
	{
		NSLog(@"File Path: %@",op.download);
	}
	else 
	{
		NSData* downloadedData = (NSData*)op.download;	
		NSString* downloadedString = [[[NSString alloc] initWithData:downloadedData encoding:NSISOLatin1StringEncoding] autorelease];
		NSLog(@"downloadedString: %@",downloadedString);
	}
}
#pragma mark -


@end
