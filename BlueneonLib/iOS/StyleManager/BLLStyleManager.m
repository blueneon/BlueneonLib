//
//  BLLStyleManager.m
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

#import "BLLStyleManager.h"
#import "UIColor+String.h"

@interface BLLStyleManager ()
@property (retain) NSDictionary* styleInfo;
-(UIColor*) _colorWithStyleID:(BLLStyleColorID) styleID;
-(NSDictionary*) _fontInfoWithStyleID:(BLLStyleFontID) styleID;

@end


@implementation BLLStyleManager
@synthesize styleInfo=_styleInfo;


+(BLLStyleManager*) defaultStyleManager
{
	static BLLStyleManager* __sharedInstance = nil;
	
	if(__sharedInstance == nil)
	{
		__sharedInstance = [[BLLStyleManager alloc] init];
	}
	
	return __sharedInstance;
}

+(UIColor*) colorWithStyleID:(BLLStyleColorID) styleID
{
	return [[BLLStyleManager defaultStyleManager] _colorWithStyleID:styleID];
}

+(UIFont*) fontWithStyleID:(BLLStyleFontID) styleID
{	
	NSDictionary* fontInfo = [[BLLStyleManager defaultStyleManager] _fontInfoWithStyleID:styleID];
	return [UIFont fontWithName:[fontInfo valueForKey:@"name"] size:[[fontInfo valueForKey:@"size"] floatValue]];
}

+(CTFontRef) createCTFontWithStyleID:(BLLStyleFontID) styleID
{
	NSDictionary* fontInfo = [[BLLStyleManager defaultStyleManager] _fontInfoWithStyleID:styleID];
	CTFontRef font = CTFontCreateWithName((CFStringRef)[fontInfo valueForKey:@"name"], 
										  [[fontInfo valueForKey:@"size"] floatValue], NULL);
	return font;
}

#pragma mark -
#pragma mark Insrtance Methids
- (id) init
{
	self = [super init];
	if (self != nil) {
		NSString* stylePlistPath = [[NSBundle mainBundle] pathForResource:@"Style" ofType:@"plist"]; 
		self.styleInfo = [NSDictionary dictionaryWithContentsOfFile:stylePlistPath];
	}
	return self;
}

- (void) dealloc
{
	
	[super dealloc];
}

-(UIColor*) _colorWithStyleID:(BLLStyleColorID) styleID
{
	NSArray* colors = [self.styleInfo valueForKey:@"colors"];
	if([colors count] > styleID)
	{
		return [UIColor colorWithString:[colors objectAtIndex:styleID]];
	}
	
	return [UIColor redColor];
}

-(NSDictionary*) _fontInfoWithStyleID:(BLLStyleFontID) styleID
{
	NSDictionary* info = nil;
	NSArray* fonts = [self.styleInfo valueForKey:@"fonts"];
	if([fonts count] > styleID)
	{
		info = [fonts objectAtIndex:styleID];
	}
	
	if(info == nil)
	{
		info = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Helvetica", @"name",
			[NSNumber numberWithInt:14], @"size", nil];
	}
	return info;
}

@end
