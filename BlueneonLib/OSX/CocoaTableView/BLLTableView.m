//
//  BLLTableView.m
//  
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

#import "BLLTableView.h"
#import "BLLTableViewCell.h"
#import "BLLClipView.h"
#import "BLLFlippedView.h"

#define SCROLL_MULTIPLYER 4


@interface BLLTableView ()
@property (retain) NSMutableSet* recycledViews;
@property (retain) NSMutableSet* visibleViews;

-(NSUInteger) numberOfRows;
-(BLLTableViewCell*) viewAtIndex:(NSUInteger) index;
-(BOOL) isDiplayingViewForIndex:(NSUInteger) index;
-(BLLTableViewCell*) displayedViewForIndex:(NSUInteger) index;

-(void) configureView:(BLLTableViewCell*) aView forIndex:(NSUInteger) index;

-(void) tileCells;

@end

@implementation BLLTableView
@synthesize recycledViews=_recycledViews;
@synthesize visibleViews=_visibleViews;

@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;
@synthesize rowHeight=_rowHeight;

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame]))
	{	
		self.recycledViews = [NSMutableSet set];
		self.visibleViews = [NSMutableSet set];
		self.rowHeight = 44;
		[self awakeFromNib];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) 
	{		
		self.recycledViews = [NSMutableSet set];
		self.visibleViews = [NSMutableSet set];
		self.rowHeight = 44;
	}
	return self;
}

-(void) awakeFromNib
{
	[self setContentView:[[[BLLClipView alloc] initWithFrame:self.bounds] autorelease]];
	
	BLLFlippedView* aView = [[[BLLFlippedView alloc] initWithFrame:[self bounds]] autorelease];
	[self setDocumentView:aView];
	
	[[self contentView] setPostsBoundsChangedNotifications:YES];

	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(contentViewContentBoundsDidChange:)
												 name:NSViewBoundsDidChangeNotification
											   object:[self contentView]];
		
	[self reloadData];	
}

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSViewBoundsDidChangeNotification
												  object:[self contentView]];
	
	self.dataSource = nil;
	self.delegate = nil;
	self.recycledViews = nil;
	self.visibleViews = nil;
	
    [super dealloc];
}


- (void)drawRect:(NSRect)dirtyRect
{
	CGContextRef myContext = [[NSGraphicsContext currentContext]graphicsPort];
    CGContextSetRGBFillColor (myContext, 1, 0, 0, 1);
    CGContextFillRect (myContext, CGRectMake (0, 0, 200, 100 ));
    CGContextSetRGBFillColor (myContext, 0, 0, 1, .5);
    CGContextFillRect (myContext, CGRectMake (0, 0, 100, 200));
}


#pragma mark -
#pragma mark Interface

-(void) reloadData
{
	if([self.dataSource respondsToSelector:@selector(rowHeightInTableView:)])
	{
		self.rowHeight = [self.delegate rowHeightInTableView:self];
	}
	
	NSRect docFrame = [[self documentView] frame];
	docFrame.size.height = self.rowHeight * [self numberOfRows];
	[[self documentView] setFrame:docFrame];
	
	[[self recycledViews] unionSet:[self visibleViews]];
	[[self visibleViews] removeAllObjects];
	
	[self tileCells];
}

#pragma mark -

-(void) contentViewContentBoundsDidChange:(NSNotification*) note 
{
	[self tileCells];
}

-(void) setFrame:(NSRect) aFrame
{
	[super setFrame:aFrame];
	
}

#pragma mark -
-(NSUInteger) numberOfRows
{
	NSUInteger rowCount = 0;
	if([self.dataSource respondsToSelector:@selector(numberOfRowsInTableView:)])
	{
		rowCount = [self.dataSource numberOfRowsInTableView:self];
	}
	return rowCount;
}

-(BLLTableViewCell*) viewAtIndex:(NSUInteger) index
{
	BLLTableViewCell* aView = nil;
	if([self.dataSource respondsToSelector:@selector(tableView:viewAtIndex:)])
	{
		aView = [self.dataSource tableView:self viewAtIndex: index];
	}
	return aView;
}
#pragma mark -

-(BOOL) isDiplayingViewForIndex:(NSUInteger) index
{
	return ([self displayedViewForIndex:index] != nil);
}

-(BLLTableViewCell*) displayedViewForIndex:(NSUInteger) index
{
	for (BLLTableViewCell* aView in [self.visibleViews allObjects])
	{		
		if(aView.tag == index)
		{
			return aView;
		}
	}
	return nil;
}

-(void) tile
{
	[super tile];
	
	NSRect docFrame = [[self documentView] frame];
	docFrame.size.height = self.rowHeight * [self numberOfRows];
	docFrame.size.width = self.bounds.size.width;
	[[self documentView] setFrame:docFrame];
	
	[self tileCells];

}

-(void) tileCells
{
	CGRect visibleBounds = NSRectToCGRect([self documentVisibleRect]);	
	NSUInteger firstViewIndex = floorf(CGRectGetMinY(visibleBounds) / self.rowHeight);	
	NSUInteger lastViewIndex = ceilf((CGRectGetMinY(visibleBounds) + self.bounds.size.height) / self.rowHeight);
		
	firstViewIndex = MAX(firstViewIndex,0);
	lastViewIndex = MIN(lastViewIndex, [self numberOfRows] - 1);
		
	for (BLLTableViewCell* aView in self.visibleViews) 
	{
		if(aView.tag < firstViewIndex || lastViewIndex < aView.tag )
		{
			[self.recycledViews addObject:aView];
			//[aView removeFromSuperview];
		}
	}
	[self.visibleViews minusSet:self.recycledViews];
	
	for (NSUInteger i = firstViewIndex ; i <= lastViewIndex; i++) 
	{
		BLLTableViewCell *aView = nil;
		
		if(![self isDiplayingViewForIndex:i])		
		{
			aView = [self viewAtIndex:i];
			
			if(aView != nil)
			{
				[[self documentView] addSubview:aView];
				[self.visibleViews addObject:aView];
			}
		}
		else
		{
			aView = [self displayedViewForIndex:i];			
		}
		[self configureView:aView forIndex:i];	
	}
	
//	for (BLLTableViewCell* aView in self.recycledViews) 
//	{
//		[aView removeFromSuperview];
//	}
}

-(BLLTableViewCell*) dequeueReusableTableViewCell
{
	BLLTableViewCell* aView = [self.recycledViews anyObject];
	
	if(aView)
	{
		[[aView retain] autorelease];
		[self.recycledViews removeObject:aView];
	}
	return aView;
}

-(void) configureView:(BLLTableViewCell*) aView forIndex:(NSUInteger) index
{
	aView.tag = index;
	
	NSRect viewFrame = NSMakeRect(0,
								   index * self.rowHeight,
								   self.bounds.size.width,
								   self.rowHeight);
	aView.frame = viewFrame;
	
	//NSLog(@"Frame[%d] %@",(int)index,NSStringFromRect(viewFrame));
}

-(void) scrollWheel:(NSEvent *)theEvent
{
	CGRect contentRect = NSRectToCGRect([[self contentView] bounds]);
	CGRect documentRect = NSRectToCGRect([[self documentView] bounds]);
	
	NSPoint curOffset = [[self contentView] bounds].origin;
	NSPoint newOffset = NSMakePoint(curOffset.x, curOffset.y - (SCROLL_MULTIPLYER * [theEvent deltaY]));
	newOffset.y = floorf(MAX(0,newOffset.y));
	newOffset.y = floorf(MIN(newOffset.y, CGRectGetHeight(documentRect)  - CGRectGetHeight(contentRect)));
	
	[[self contentView] scrollToPoint:newOffset];
	[self reflectScrolledClipView:[self contentView]];	
}

@end


