//
//  NSOperationQueue+NetworkOperationQueue.m
//  Feed
//
//  Created by Alex Carter on 10-05-23.
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

#import "NSOperationQueue+NetworkOperationQueue.h"
#import "BLLNetworkOperation.h"

@implementation NSOperationQueue (NetworkOperationQueue)


+(NSOperationQueue*) defaultNetworkOperationQueue
{
	static NSOperationQueue* __defaultNetworkOperationQueue = nil;
	if(__defaultNetworkOperationQueue == nil)
	{
		__defaultNetworkOperationQueue = [[NSOperationQueue alloc] init];
		[__defaultNetworkOperationQueue setSuspended:NO];
	}
	return __defaultNetworkOperationQueue;
}

+(NSOperationQueue*) serialNetworkOperationQueue
{
	static NSOperationQueue* __serialNetworkOperationQueue = nil;
	if(__serialNetworkOperationQueue == nil)
	{
		__serialNetworkOperationQueue = [[NSOperationQueue alloc] init];
		[__serialNetworkOperationQueue setSuspended:NO];
		[__serialNetworkOperationQueue setMaxConcurrentOperationCount:1];
	}
	return __serialNetworkOperationQueue;
}

+(NSOperationQueue*) concurrentNetworkOperationQueue
{
	static NSOperationQueue* __concurrentNetworkOperationQueue = nil;
	if(__concurrentNetworkOperationQueue == nil)
	{
		__concurrentNetworkOperationQueue = [[NSOperationQueue alloc] init];
		[__concurrentNetworkOperationQueue setSuspended:NO];
	}
	return __concurrentNetworkOperationQueue;
}

-(void) cancelNetworkOperationsWithContext:(id) context
{
	for (BLLNetworkOperation* op in [self operations])
	{
		if([op respondsToSelector:@selector(context)] && [op.context isEqual:context])
		{
			[op cancel];
		}
	}
}

@end
