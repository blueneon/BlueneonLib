//
//  BLLColumnTextView.m
//  TheNobleSage
//
//  Created by Alex Carter on 10-07-31.
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

#import "BLLColumnTextView.h"





#pragma mark -
@interface BLLColumnTextView ()
@property (assign) CTFramesetterRef frameSetter;
@property (retain) NSArray* frameInfoObjects;

-(void) initFrameSetter;
-(void) calculateLayout;
@end

@implementation BLLColumnTextView
@synthesize frameInfoObjects=_frameInfoObjects;
@dynamic frameSetter;


- (id)initWithFrame:(CGRect)aFrame {
    if ((self = [super initWithFrame:aFrame])) {
        
		self.columnWidth = CGRectGetWidth(aFrame);
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
	self.columnWidth = 0;
	self.attributedString = nil;
	self.frameInfoObjects = nil;
	self.frameSetter = NULL;
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

-(void) setFrameSetter:(CTFramesetterRef) aFrameSetter
{
	if(aFrameSetter != _frameSetter)
	{
		[self willChangeValueForKey:@"frameSetter"];
		if(_frameSetter)
		{
			CFRelease(_frameSetter);
			_frameSetter = NULL;
		}
		
		if(aFrameSetter != NULL)
		{
			_frameSetter = CFRetain(aFrameSetter);
		}
		[self didChangeValueForKey:@"frameSetter"];
	}
}

-(CTFramesetterRef) frameSetter
{
	return _frameSetter;
}

-(void) setAttributedString:(NSAttributedString *) aValue
{
	[self willChangeValueForKey:@"attributedString"];
	[_attributedString autorelease];
	_attributedString = [aValue retain];	
	[self didChangeValueForKey:@"attributedString"];
	
	[self initFrameSetter];	
}

-(NSAttributedString*) attributedString
{
	return _attributedString;
}

-(void) setColumnWidth:(NSUInteger) aValue
{
	[self willChangeValueForKey:@"columnWidth"];
	_columnWidth = aValue;
	[self didChangeValueForKey:@"columnWidth"];
}

-(NSUInteger) columnWidth
{
	return _columnWidth;
}

#pragma mark -
#pragma mark Layout

-(void) initFrameSetter
{		
	CTFramesetterRef aFrameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
	self.frameSetter = aFrameSetter;
	if (aFrameSetter) {
		CFRelease(aFrameSetter);
	}

}

-(void) calculateLayout
{
	NSMutableArray* newFrameInfoObjects = [NSMutableArray array];
	NSUInteger startIndex = 0;
	
	CGRect frameRect = self.bounds;
	frameRect.size.width = self.columnWidth;
	
	if (CGRectGetWidth(frameRect) > 0 && CGRectGetHeight(frameRect) > 0)
	{
		NSUInteger offset = 0;
		while (startIndex < [self.attributedString length])
		{
			CGMutablePathRef path = CGPathCreateMutable();
			CGRect pathRect;
			if (offset == 0)
			{
				pathRect = CGRectOffset(frameRect, offset, 0);
				pathRect = CGRectInset(pathRect,20,10);
			}
			else 
			{
				pathRect = CGRectOffset(frameRect, offset, 0);
				pathRect = CGRectInset(pathRect,20,10);
			}
			CGPathAddRect(path, NULL,pathRect);
			
			offset += CGRectGetWidth(frameRect);
			
			CTFrameRef frame = CTFramesetterCreateFrame(self.frameSetter,
														CFRangeMake(startIndex, 0), path, NULL);
			
			if(frame != NULL)
			{
				CFRange frameRange = CTFrameGetVisibleStringRange(frame);
				if( frameRange.length == 0)
				{
					// looks like we can never exit the loop because the frame is probably too small
					break;
				}
				
				TNSFrameInfo* frameInfo = [[TNSFrameInfo alloc] initWithFrame:frame textRange:frameRange];
				[newFrameInfoObjects addObject:frameInfo];
				[frameInfo release];
				
				startIndex += frameRange.length;
				
				CFRelease(frame);
			}
			else {
				break;
			}

			CFRelease(path);
		}
		
		self.frameInfoObjects = newFrameInfoObjects;
	}

	//	[super setFrame:[self frameToFitLayout]];
}

-(CGRect) frameToFitLayout
{
	CGRect newFrame = self.frame;
	newFrame.size.width = self.columnWidth * [self.frameInfoObjects count];
	return newFrame;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
	CGContextTranslateCTM(ctx,0, CGRectGetHeight(self.bounds));
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	for (TNSFrameInfo* frameInfo in self.frameInfoObjects) {
		
        CTFrameDraw(frameInfo.frame, ctx);
	}	
}

@end


#pragma mark -
#pragma mark TSNFrameInfo
@implementation TNSFrameInfo
@dynamic frame;
@synthesize textRange=_textRange;

- (id) initWithFrame:(CTFrameRef) aFrame textRange:(CFRange) aRange
{
	self = [super init];
	if (self != nil) {
		self.frame = aFrame;
		self.textRange = aRange;
	}
	return self;
}

-(void) setFrame:(CTFrameRef) aFrame
{
	if(aFrame != _frame)
	{
		[self willChangeValueForKey:@"frame"];
		if(_frame)
		{
			CFRelease(_frame);
			_frame = NULL;
		}
		if(aFrame != NULL)
		{
			_frame = CFRetain(aFrame);
		}
		[self didChangeValueForKey:@"frame"];
	}
}

-(CTFrameRef) frame
{
	return _frame;
}

- (void) dealloc
{
	self.frame = NULL;
	[super dealloc];
}



@end
#pragma mark -
