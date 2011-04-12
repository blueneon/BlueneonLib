//
//  NSString+md5.m
//  Feed
//
//  Created by Alex Carter on 10-05-22.
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

#import "NSString+md5.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSString (md5)

+(NSString*) md5HashOfStrings:(NSArray*) strings
{
	NSMutableString *string = [NSMutableString string];
	
	for(NSString* str in strings)
	{
		[string appendString:str];
	}
	return [string md5Hash];
}

-(NSString*) md5Hash
{
	NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char md5Hash[16];
	CC_MD5([data bytes],[data length],md5Hash);
	
	NSString *md5HashString = [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",	 
							   md5Hash[0], md5Hash[1], md5Hash[2], md5Hash[3],	 
							   md5Hash[4], md5Hash[5], md5Hash[6], md5Hash[7],	 
							   md5Hash[8], md5Hash[9], md5Hash[10], md5Hash[11],	 
							   md5Hash[12], md5Hash[13], md5Hash[14], md5Hash[15]	 ];
	
	
	return md5HashString;	
}

@end
