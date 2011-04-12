//
//  NSURLFromNSDataTransformer.m
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

#import "NSURLToNSDataTransformer.h"


@implementation NSURLToNSDataTransformer

+(void) registerValueTransformer
{
	[NSValueTransformer setValueTransformer:[[[NSURLToNSDataTransformer alloc] init] autorelease] 
									forName:NSStringFromClass([NSURLToNSDataTransformer class])];
}

+(BOOL) allowsReverseTransformation
{
	return YES;
}

+(Class) transformedValueClass
{
	return [NSData class];
}

-(id) transformedValue:(id)value
{
	NSAssert([value isKindOfClass:[NSURL class]],@"Input must be of class NSURL");
	NSData* result = [[(NSURL*)value absoluteString] dataUsingEncoding:NSUTF8StringEncoding];
	return result;
}

-(id) reverseTransformedValue:(id)value
{
	
	NSAssert([value isKindOfClass:[NSData class]],@"Input must be of class NSData");
	NSURL *result = nil;	
	NSString* urlString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
	if(urlString != nil)
	{
		result = [NSURL URLWithString:urlString];
	}
	[urlString release];
	return result;
}

@end
