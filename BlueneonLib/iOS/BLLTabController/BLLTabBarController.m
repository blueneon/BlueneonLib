    //
//  BLLTabController.m
//  TheNobleSage
//
//  Created by Alex Carter on 10-07-04.
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

#import "BLLTabBarController.h"

@interface BLLTabBarController ()
-(void) updateLayoutToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation;

@end


@implementation BLLTabBarController
@synthesize customTabBarView=_customTabBarView;


- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self updateLayoutToInterfaceOrientation:self.interfaceOrientation];
	[self.selectedViewController viewWillAppear:animated];
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self updateLayoutToInterfaceOrientation:toInterfaceOrientation];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{	

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
	self.customTabBarView = nil;
    [super dealloc];
}
#pragma mark -
#pragma mark Observation

#pragma mark -
#pragma mark Accessors
-(void) setSelectedIndex:(NSUInteger) newIndex
{
	[super setSelectedIndex:newIndex];
	[[[self viewControllers] objectAtIndex:newIndex] viewWillAppear:NO];	
}

-(void) setSelectedViewController:(UIViewController *) aViewController
{
	[super setSelectedViewController:aViewController];
	//[aViewController viewWillAppear:NO];
}

//-(void) setViewControllers:(NSArray *)newViewControllers
//{
//	[super setViewControllers:newViewControllers];
//	
//	NSArray* items = [self.viewControllers valueForKeyPath:@"tabBarItem.title"];
//	
//	UISegmentedControl* newTabBar = [[UISegmentedControl alloc] initWithItems:items];
//	[newTabBar setFrame:CGRectMake(0, 0, 320, 40) ];
//	newTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//	
//	[newTabBar addTarget:self
//						 action:@selector(action:)
//			   forControlEvents:UIControlEventValueChanged];
//	
//	self.customTabBarView = newTabBar;
//	[[self view] addSubview:newTabBar];
//}
//
//-(void) action:(id) sender
//{
//	UISegmentedControl* segCtrl = (UISegmentedControl*)sender;
//	[self setSelectedIndex:[segCtrl selectedSegmentIndex] animated: YES];
//}

#pragma mark -

-(void) setTabBarHidden:(BOOL) hidden
{
	[self.tabBar setHidden:hidden];
}

-(void) updateLayoutToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation
{
	if([self.tabBar isHidden])
	{
		CGRect newRect = [[UIScreen mainScreen] applicationFrame]; 	
			
		if(CGAffineTransformEqualToTransform(self.view.transform, CGAffineTransformMake(1, 0, 0, 1, 0, 0)) &&
		   toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
		{
			CGRect appFrame = newRect;
			newRect.size.height = CGRectGetWidth(appFrame) + CGRectGetHeight([self.tabBar bounds]);
			newRect.size.width = CGRectGetHeight(appFrame);
		}
		else if(CGAffineTransformEqualToTransform(self.view.transform, CGAffineTransformMake(1, 0, 0, 1, 0, 0)) &&
		   toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
		{
			CGRect appFrame = newRect;
			newRect.size.height = CGRectGetWidth(appFrame) + CGRectGetHeight([self.tabBar bounds]);
			newRect.size.width = CGRectGetHeight(appFrame);		
			newRect.origin.y -= CGRectGetHeight([self.tabBar bounds]);
		}		
		else
		{
			if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)	
			{
				newRect.size.width += CGRectGetHeight([self.tabBar bounds]);
			}
			else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
			{			
				//newRect.size.height -= CGRectGetHeight([self.tabBar bounds]);
				newRect.origin.x -= CGRectGetHeight([self.tabBar bounds]);
				newRect.size.width += CGRectGetHeight([self.tabBar bounds]);
			}
			else if(toInterfaceOrientation == UIInterfaceOrientationPortrait)
			{			
				newRect.size.height += CGRectGetHeight([self.tabBar bounds]);
				//newRect.size.width += CGRectGetHeight([self.tabBar bounds]);
			}
			else if(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
			{			
				newRect.origin.y -= CGRectGetHeight([self.tabBar bounds]);
				newRect.size.height += CGRectGetHeight([self.tabBar bounds]);			
			}
		}
		
		[self.view setFrame:newRect];		
	}
	[[self view] bringSubviewToFront: self.customTabBarView];
}


@end
