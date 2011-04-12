//
//  NSFetchRequest+Network.m
//  RemoteData
//
//  Created by Alex Carter on 10-06-12.
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

#import "NSFetchRequest+BLLNetwork.h"


@implementation NSFetchRequest (BLLNetwork)

-(BOOL) requiresNetworkRequest
{
	return [[[[self entity] userInfo] valueForKeyPath:@"isRemote"] boolValue];
}

-(NSURLRequest*) URLRequestWithBaseURL:(NSURL*) baseURL
{
	NSString* destination = [[[self entity] userInfo] valueForKeyPath:@"destination"];
	NSURL *URL = [NSURL URLWithString:destination relativeToURL:baseURL];
	NSMutableURLRequest* URLRequest = [[[NSMutableURLRequest alloc] initWithURL:URL] autorelease];
	[URLRequest setHTTPMethod:@"GET"];
	
	// TODO: Add perameters to the URL to affect filtering on the server
	// NOTE: Sorting is no required ascore data will deal with this localy.
	
	return URLRequest;
}

@end
