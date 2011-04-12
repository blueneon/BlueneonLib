//
//  BLLPagingImageViewViewController.m
//  BLLPagingImageView
//
//  Created by Alex Carter on 10-08-07.
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

#import "BLLPagingImageViewViewController.h"

@implementation BLLPagingImageViewViewController
@synthesize pagingImageView;
@synthesize images=_images;


- (void)viewDidLoad {
    [super viewDidLoad];
	self.images = [NSArray arrayWithObjects:
				   [UIImage imageNamed:@"blue-lego.png"],
				   [UIImage imageNamed:@"oak_2560x1600.jpg"],
				   [UIImage imageNamed:@"solar_system.jpg"],
				   [UIImage imageNamed:@"solutions2.png"],
				   [UIImage imageNamed:@"lymph.png"],
				   nil];
	
	[self.pagingImageView reloadImages];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.pagingImageView = nil;
	self.images = nil;
	
    [super dealloc];
}


-(NSUInteger) numberOfImagesInPagingImageView:(BLLPagingImageView*)aPagingImageView
{
	return [self.images count];
	
}

-(UIImage*) pagingImageView:(BLLPagingImageView*)aPagingImageView imageAtIndex:(NSUInteger) index
{
	return [self.images objectAtIndex:index];	
}

- (void)pagingImageView:(BLLPagingImageView*)aPagingImageView didScrollToImageAtIndex:(int)index
{
	NSLog(@"didScrollToImageAtIndex: %d",index);
}
- (void)pagingImageView:(BLLPagingImageView*)aPagingImageView userTappedImageAtIndex:(int)index count:(int)count
{
	NSLog(@"userTappedImageAtIndex: %d",index);
}

@end

