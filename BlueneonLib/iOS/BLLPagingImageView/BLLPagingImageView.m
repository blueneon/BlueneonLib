//
//  BLLPagingImageView.m
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


#import "BLLPagingImageView.h"
#import "BLLZoomingImageView.h"

@interface BLLPagingImageView ()
@property (retain) UIScrollView* scrollView;
@property (retain) NSMutableSet* recycledPages;
@property (retain) NSMutableSet* visiblePages;

-(NSUInteger) numberOfImages;
-(UIImage*) imageAtIndex:(NSUInteger) index;
-(BOOL) isDiplayingPageForIndex:(NSUInteger) index;
-(BLLZoomingImageView*) displayedPageForIndex:(NSUInteger) index;
-(void) tilePages;
-(BLLZoomingImageView*) dequeueReusablePage;
-(void) configurePage:(BLLZoomingImageView*) aPage forIndex:(NSUInteger) index;


@end

@implementation BLLPagingImageView
@synthesize recycledPages=_recycledPages;
@synthesize visiblePages=_visiblePages;
@synthesize scrollView=_scrollView;

@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;
@synthesize imagePadding=_imagePadding;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		self.clipsToBounds = YES;
		
		self.imagePadding = CGSizeMake(5, 0);
		self.scrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
		[self.scrollView setPagingEnabled:YES];
		[self.scrollView setShowsHorizontalScrollIndicator:NO];
		[self.scrollView setShowsVerticalScrollIndicator:NO];
		[self.scrollView setDelegate:self];
		[self addSubview:self.scrollView];
		
		[self setBackgroundColor: [UIColor blackColor]];
		
		self.recycledPages = [NSMutableSet set];
		self.visiblePages = [NSMutableSet set];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		
		self.clipsToBounds = YES;
		
		self.imagePadding = CGSizeMake(5, 0);
		self.scrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
		[self.scrollView setPagingEnabled:YES];
		[self.scrollView setShowsHorizontalScrollIndicator:NO];
		[self.scrollView setShowsVerticalScrollIndicator:NO];
		[self.scrollView setDelegate:self];
		[self addSubview:self.scrollView];
		
		[self setBackgroundColor: [UIColor blackColor]];
		
		self.recycledPages = [NSMutableSet set];
		self.visiblePages = [NSMutableSet set];
	}
	return self;
	
}


- (void)dealloc {
	
	self.dataSource = nil;
	self.delegate = nil;
	[self.scrollView setDelegate:nil];
	self.scrollView = nil;
	self.recycledPages = nil;
	self.visiblePages = nil;
	
    [super dealloc];
}
#pragma mark -
#pragma mark Interface

-(void) reloadImages
{
	[self setNeedsLayout];
}


-(void) reloadImageAtIndex:(NSUInteger) index
{
	BLLZoomingImageView* aPage = [self displayedPageForIndex:index];
	if(aPage != nil)
	{
		[self configurePage:aPage forIndex:index];
	}
}

#pragma mark -

-(void) setFrame:(CGRect) aFrame
{
	[super setFrame:aFrame];
}

#pragma mark -

-(NSUInteger) currentImage
{
	return  floor(self.scrollView.contentOffset.x / CGRectGetWidth(self.bounds));
}

-(void) setCurrentImage:(NSUInteger) index animate:(BOOL) animate
{
	CGFloat xPos = index * (CGRectGetWidth(self.bounds) + self.imagePadding.width * 2);
	[self.scrollView setContentOffset:CGPointMake(xPos, 0) animated:animate]; 
}


-(NSUInteger) numberOfImages
{
	NSUInteger imageCount = 0;
	if([self.dataSource respondsToSelector:@selector(numberOfImagesInPagingImageView:)])
	{
		imageCount = [self.dataSource numberOfImagesInPagingImageView:self];
	}
	return imageCount;
}

-(UIImage*) imageAtIndex:(NSUInteger) index
{
	UIImage* image = nil;
	if([self.dataSource respondsToSelector:@selector(pagingImageView:imageAtIndex:)])
	{
		image = [self.dataSource pagingImageView:self imageAtIndex: index];
	}
	return image;
}

-(UIImage*) previewImageAtIndex:(NSUInteger) index
{
	UIImage* image = nil;
	if([self.dataSource respondsToSelector:@selector(pagingImageView:previewImageAtIndex:)])
	{
		image = [self.dataSource pagingImageView:self previewImageAtIndex: index];
	}
	else{
		image = [self imageAtIndex:index];
	}
	
	return image;
}

#pragma mark -
#pragma mark Layout

-(void) layoutSubviews
{
	[super layoutSubviews];
	
	CGSize scrollViewSize = self.scrollView.bounds.size;	
	CGRect newScrollViewFrame = CGRectInset(self.bounds,-self.imagePadding.width,self.imagePadding.height);
	
	
	if(!CGSizeEqualToSize(scrollViewSize, newScrollViewFrame.size))
	{	
		if (CGSizeEqualToSize(scrollViewSize, CGSizeZero))
		{
			scrollViewSize = newScrollViewFrame.size;
		}
		
		NSUInteger numberOfImages = [self numberOfImages];
		CGSize contentSize = CGSizeMake(CGRectGetWidth(newScrollViewFrame) * numberOfImages,
										CGRectGetHeight(newScrollViewFrame));		

		CGFloat ratio = newScrollViewFrame.size.width / scrollViewSize.width;
		CGPoint offset = self.scrollView.contentOffset;
		offset.x = round(offset.x * ratio);
	
		self.scrollView.frame = newScrollViewFrame;
		self.scrollView.contentSize = contentSize;
		self.scrollView.contentOffset = offset;
	}
	
	[self tilePages];
}

#pragma mark -

-(BOOL) isDiplayingPageForIndex:(NSUInteger) index
{
	return ([self displayedPageForIndex:index] != nil);
}

-(BLLZoomingImageView*) displayedPageForIndex:(NSUInteger) index
{
	for (BLLZoomingImageView* aPage in [self.visiblePages allObjects])
	{		
		if(aPage.tag == index)
		{
			return aPage;
		}
	}
	return nil;
}


-(void) tilePages
{
	if(self.scrollView)
	{
		CGRect visibleBounds = [self.scrollView bounds];
		
		NSUInteger firstPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
		NSUInteger lastPageIndex = firstPageIndex;
		if(CGRectGetMinX(visibleBounds) - (CGRectGetWidth(visibleBounds) * firstPageIndex) > 0)
		{
			lastPageIndex++;
		}
				
		firstPageIndex = MAX(firstPageIndex,0);
		lastPageIndex = MIN(lastPageIndex, [self numberOfImages] - 1);
			
		for (BLLZoomingImageView* aPage in self.visiblePages) 
		{
			if(aPage.tag < firstPageIndex || lastPageIndex < aPage.tag )
			{
				[self.recycledPages addObject:aPage];
				[aPage removeFromSuperview];
			}
		}
		[self.visiblePages minusSet:self.recycledPages];
		
		for (NSUInteger i = firstPageIndex ; i <= lastPageIndex; i++) 
		{
			if(![self isDiplayingPageForIndex:i])		
			{
				BLLZoomingImageView *aPage = [self dequeueReusablePage]; 
				if (aPage == nil) 
				{
					CGRect imageFrame = CGRectMake(i * CGRectGetWidth(self.scrollView.bounds),
												   0,
												   CGRectGetWidth(self.scrollView.bounds),
												   CGRectGetHeight(self.scrollView.bounds));
					imageFrame = CGRectInset(imageFrame,self.imagePadding.width,self.imagePadding.height);
					
					aPage = [[[BLLZoomingImageView alloc] initWithFrame:imageFrame] autorelease];
					[aPage setContentMode:UIViewContentModeScaleAspectFit];
				}
				[self configurePage:aPage forIndex:i];
				[self.scrollView addSubview:aPage];
				[self.visiblePages addObject:aPage];
			}
			else
			{
				BLLZoomingImageView *aPage = [self displayedPageForIndex:i];
				[self configurePage:aPage forIndex:i];				
			}
		}
	}
}

-(BLLZoomingImageView*) dequeueReusablePage
{
	BLLZoomingImageView* aPage = [self.recycledPages anyObject];
	
	if(aPage)
	{
		[[aPage retain] autorelease];
		[self.recycledPages removeObject:aPage];
		aPage.zoomScale = 1.0;
	}
	return aPage;
}

-(void) configurePage:(BLLZoomingImageView*) aPage forIndex:(NSUInteger) index
{
	aPage.tag = index;
	
	CGRect imageFrame = CGRectMake(index * CGRectGetWidth(self.scrollView.bounds),
								   0,
								   CGRectGetWidth(self.scrollView.bounds),
								   CGRectGetHeight(self.scrollView.bounds));
	aPage.frame = CGRectInset(imageFrame,self.imagePadding.width,self.imagePadding.height);
	[aPage setImage:[self imageAtIndex:index]];
}

#pragma mark UIScrollViewDelegate
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	NSUInteger currentImage = [self currentImage];	
	if([self.delegate respondsToSelector:@selector(pagingImageView:didScrollToImageAtIndex:)])
	{
		[self.delegate pagingImageView:self didScrollToImageAtIndex:currentImage];
	}
}

@end