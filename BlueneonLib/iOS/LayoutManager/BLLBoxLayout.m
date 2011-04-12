//
//  BLLHorizontalBoxLayout.m
//
//  Created by Alex Carter on 10-05-05.
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

#import "BLLBoxLayout.h"
#import "BLLLayoutManager.h"

@implementation BLLBoxLayout
@synthesize alignment;
@synthesize padding;
@synthesize layoutDirection;

-(id) init
{
	return [self initWithAlignment:UITextAlignmentLeft padding:0.0];
}


- (id) initWithAlignment:(UITextAlignment) anAlignement
{
	return [self initWithAlignment:anAlignement padding:0.0];
}

- (id) initWithAlignment:(UITextAlignment) anAlignement padding:(CGFloat) thePadding
{
	self = [super init];
	if (self != nil) {
		self.layoutDirection = BLLLayoutDirectionHorizontal;
		self.alignment = anAlignement;
		self.padding = thePadding;
	}
	return self;
}


-(CGRect) frameForViewIndex:(NSUInteger) index inLayoutManager:(BLLLayoutManager*) layoutManager
{	
	CGRect subviewRect = CGRectZero;
	CGRect rect = layoutManager.containerView.bounds;
	CGFloat offset = 0;
	
	NSUInteger i, count = [layoutManager viewCount];
	for (i = 0; i < count; i++) {
		UIView *aSubview = [layoutManager viewAtIndex:i];
	
		if(![aSubview isHidden])
		{
			switch (self.alignment) 
			{
				case UITextAlignmentRight:
					if (self.layoutDirection == BLLLayoutDirectionHorizontal)
					{
						subviewRect = CGRectMake(CGRectGetWidth(rect) - (offset + CGRectGetWidth(aSubview.bounds)),
												 (CGRectGetHeight(rect) - CGRectGetHeight(aSubview.bounds)) / 2,
												 CGRectGetWidth(aSubview.bounds),
												 CGRectGetHeight(aSubview.bounds));
					}
					else
					{
						subviewRect = CGRectMake((CGRectGetWidth(rect) - CGRectGetWidth(aSubview.bounds)) / 2,
												 CGRectGetHeight(rect) - (offset + CGRectGetHeight(aSubview.bounds)) ,
												 CGRectGetWidth(aSubview.bounds),
												 CGRectGetHeight(aSubview.bounds));
					}

					break;
				case UITextAlignmentLeft:
				default:
					if (self.layoutDirection == BLLLayoutDirectionHorizontal)
					{
						subviewRect = CGRectMake(offset,
												 (CGRectGetHeight(rect) - CGRectGetHeight(aSubview.bounds)) / 2,
												 CGRectGetWidth(aSubview.bounds),
												 CGRectGetHeight(aSubview.bounds));
					}
					else
					{
						subviewRect = CGRectMake((CGRectGetWidth(rect) - CGRectGetWidth(aSubview.bounds)) / 2,
												 offset,
												 CGRectGetWidth(aSubview.bounds),
												 CGRectGetHeight(aSubview.bounds));	
					}

					
					break;
			}
			if (self.layoutDirection == BLLLayoutDirectionHorizontal)
			{
				offset += CGRectGetWidth(aSubview.bounds) + self.padding;
			}
			else
			{
				offset += CGRectGetHeight(aSubview.bounds) + self.padding;	
			}
		}
			
		if (i == index)
		{
			break;
		}
	}
	return subviewRect;
}

@end
