//
//  BLLHorizontalBoxLayout.m
//
//  Created by Alex Carter on 10-05-04.
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

#import "BLLLayoutManager.h"


@implementation BLLLayoutManager
@dynamic containerView;
@synthesize views;
@dynamic layout;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.containerView = nil;
		self.views = nil;
		self.layout = nil;
	}
	return self;
}

- (void) dealloc
{
	self.containerView = nil;
	self.views = nil;
	self.layout = nil;
	
	[super dealloc];
}

-(NSUInteger) viewCount
{
	return [self.views count];
}

-(UIView*) viewAtIndex:(NSUInteger) index
{
	return [self.views objectAtIndex:index];
}

-(void) setContainerView:(UIView *) aView
{
	[containerView removeObserver:self forKeyPath:@"frame"];
	[containerView autorelease];
	containerView = [aView retain];
	[containerView addObserver:self forKeyPath:@"frame" options:0 context:nil];
}

-(void) setLayout:(id <BLLLayout>) aLayout
{
	[layout autorelease];
	layout = [aLayout retain];
	[self layoutViews];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"frame"] && object == self.containerView)
	{
		[self layoutViews];
	}
}

-(void) layoutViews
{
	NSUInteger i, count = [self.views count];
	for (i = 0; i < count; i++) 
	{	
		UIView* aSubview = [self.views objectAtIndex:i];
		aSubview.frame = [layout frameForViewIndex:i inLayoutManager:self];
	}
}

-(NSIndexSet*) indexSetForViewsIntersectingRect:(CGRect) aRect
{
	// If the layout has an optomised way of calculating this allow it to do so otherwise do the bruit force method
	if([self.layout respondsToSelector:@selector(indexSetForViewsIntersectingRect:inLayoutManager:)])
	{
		return [self.layout indexSetForViewsIntersectingRect:aRect inLayoutManager:self];
	}
	else
	{
		NSMutableIndexSet* indexSet = [[[NSMutableIndexSet alloc] init] autorelease];
		NSUInteger i, count = [self.views count];
		for (i = 0; i < count; i++) 
		{	
			CGRect frame = [layout frameForViewIndex:i inLayoutManager:self];
			if(CGRectIntersectsRect(frame, aRect))
			{
				[indexSet addIndex:i];
			}
		}
		return indexSet;
	}
}


@end
