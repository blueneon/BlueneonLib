//
//  UIColor+Styles.m
//  TheNobleSage
//
//  Created by Alex Carter on 10-07-27.
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

#import "UIColor+String.h"


@implementation UIColor (Hex)

+ (UIColor*) colorWithHexString:(NSString*) string
{
	UIColor* color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	if(string)
	{
		NSScanner* scanner = [NSScanner scannerWithString:string];
		[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
		
		unsigned value = 0;
		
		if( [scanner scanHexInt:&value] )
		{
			if(value <= 0xFFFFFF)
			{
				int red = (value >> 16) & 0xFF;
				int green = (value >> 8) & 0xFF;
				int blue = value & 0xFF;
				
				color = [UIColor colorWithRed: red/256.0 green: green/256.0 blue: blue/256.0 alpha:1.0];
			}
			else
			{
				int red = (value >> 24) & 0xFF;
				int green = (value >> 16) & 0xFF;
				int blue = (value >> 8) & 0xFF;
				int alpha = value & 0xFF;				
				color = [UIColor colorWithRed: red/256.0 green: green/256.0 blue: blue/256.0 alpha:alpha/255];
			}
			
		}
	}
	
	return color;
}

+ (UIColor*) colorWithString:(NSString*) string
{
	UIColor* color = nil;
	if(string)
	{
		NSScanner* scanner = [NSScanner scannerWithString:string];
		[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"{,}"]];
		
		NSString* type = nil;
		[scanner scanUpToString:@":" intoString:&type];
		[scanner scanString:@":" intoString:nil];
		if([type isEqualToString:@"texture"])
		{
			NSString* resourceName = nil;
			[scanner scanCharactersFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet] intoString:&resourceName];
			
			if(resourceName)
			{
				color = [UIColor colorWithPatternImage:[UIImage imageNamed:resourceName]];
			}
		}
		else
		{
			float red = 0.0;
			float green = 0.0;
			float blue = 0.0;
			float alpha = 0.0;
			
			[scanner scanFloat:&red];
			[scanner scanFloat:&green];
			[scanner scanFloat:&blue];
			
			if(![scanner scanFloat:&alpha])
				alpha = 1.0;
			
			color = [UIColor colorWithRed: red green: green blue: blue alpha:alpha];	
		}
	}
	if(color == nil)
	{
		color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	}
	
	return color;
}

@end
