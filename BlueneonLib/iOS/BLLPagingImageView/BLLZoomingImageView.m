//
//  BllZoomingImageView.m
//  TheNobleSage
//
//  Created by Alex Carter on 10-07-08.
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
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	1. Redistributions of source code must retain the above copyright notice, this list of
//	conditions and the following disclaimer.
//
//	2. Redistributions in binary form must reproduce the above copyright notice, this list
//	of conditions and the following disclaimer in the documentation and/or other materials
//	provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY Alex Carter ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Alex Carter OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//						   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//																			 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of Alex Carter.

#import "BLLZoomingImageView.h"
#import "BLLGeometry.h"

@interface BLLZoomingImageView ()
@property (retain) UIImageView* imageView;
@property (retain) UITouch* firstTouch;
@end

@implementation BLLZoomingImageView
@synthesize imageView=_imageView;
@synthesize firstTouch=_firstTouch;
@dynamic image;

- (id) init
{
	return [self initWithFrame:CGRectZero];
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		self.delegate = self;		
		self.imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:self.imageView];
		
		self.maximumZoomScale = 4.0;
		self.minimumZoomScale = 0.5;
		self.clipsToBounds = YES;
		self.bouncesZoom = YES;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		
		self.delegate = self;
		self.imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:self.imageView];
		
		
		self.maximumZoomScale = 4.0;
		self.minimumZoomScale = 0.5;
		self.clipsToBounds = YES;
		self.bouncesZoom = YES;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

- (void)dealloc {
	self.firstTouch = nil;
	self.imageView = nil; 
    [super dealloc];
}


#pragma mark -
#pragma mark Accessors

-(void) setImage:(UIImage*) anImage
{
	self.imageView.image = anImage;
}

-(UIImage*) image
{
	return self.imageView.image;
}

-(void) setFrame:(CGRect) aRect
{
	if(!CGSizeEqualToSize(aRect.size, self.frame.size))
	{
		self.contentSize = aRect.size;
		self.contentOffset = CGPointZero;
	}

	[super setFrame:aRect];
	[self layoutSubviews];
}

#pragma mark -
#pragma mark Layout

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}

-(void) layoutSubviews
{	
	[super layoutSubviews]; 
	
	CGSize boundsSize = self.bounds.size;
	CGRect frameToCenter = _imageView.frame;
	
	frameToCenter.size.width = boundsSize.width * self.zoomScale;
	frameToCenter.size.height = boundsSize.height * self.zoomScale;
	
	if(CGRectGetWidth(frameToCenter) < boundsSize.width)
	{
		frameToCenter.origin.x = (boundsSize.width - CGRectGetWidth(frameToCenter)) / 2;
	}
	else
	{
		frameToCenter.origin.x = 0;		
	}
	
	if(CGRectGetHeight(frameToCenter) < boundsSize.height)
	{
		frameToCenter.origin.y = (boundsSize.height - CGRectGetHeight(frameToCenter)) / 2;
	}
	else
	{
		frameToCenter.origin.y = 0;		
	}
	
	_imageView.frame = frameToCenter;
}

#pragma mark Touch Hnadlers
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.firstTouch = [touches anyObject];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	
	CGPoint firstTouchPoint = [self.firstTouch locationInView:self];
	CGPoint currentTouchPoint = [touch locationInView:self];
	
	if (CGPointDistanceFromPoint(firstTouchPoint, currentTouchPoint) < 4.0)
	{
		if([touch tapCount] == 2)
		{
			if([self zoomScale] != 1.0)
			{
				[self setZoomScale:1.0 animated:YES];
			}
			else
			{
				[self setZoomScale:2.0 animated:YES];
			}
		}
	}
}


@end
