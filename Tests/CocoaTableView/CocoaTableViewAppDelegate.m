//
//  CocoaTableViewAppDelegate.m
//  CocoaTableView
//
//  Created by Alex Carter on 10-09-27.
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

#import "CocoaTableViewAppDelegate.h"

#import "BLLTableView.h"
#import "BLLTableViewCell.h"

@implementation CocoaTableViewAppDelegate

@synthesize window;
@synthesize data;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 

		
}

-(NSArray*) data
{
	if(data == nil)
	{
		NSMutableArray* contents = [NSMutableArray arrayWithObjects: 
									[NSString stringWithString:@"One/twewrwtw/wwtw/ewtwtwt/wtweetw%20dkbldb%02slkslls"],
									[NSString stringWithString:@"Two"],
									[NSString stringWithString:@"Three"],
									[NSString stringWithString:@"Four"],
									[NSString stringWithString:@"Two"],
									[NSString stringWithString:@"Three"],
									[NSString stringWithString:@"Four"],
									[NSString stringWithString:@"Two"],
									[NSString stringWithString:@"Three"],
									[NSString stringWithString:@"Four"],
									[NSString stringWithString:@"Two"],
									[NSString stringWithString:@"Three"],
									[NSString stringWithString:@"Four"],
									[NSString stringWithString:@"Two"],
									[NSString stringWithString:@"Three"],
									[NSString stringWithString:@"Four"],
									nil];
		
		
		for (int i = 0; i < 1000; i++)
		{
			[contents addObject:[NSString stringWithFormat:@"Item%i",i]];
		}
		data = [contents retain];
	}
	return data;
}

#pragma mark BLLTableViewDelegate


-(NSUInteger) rowHeightInTableView:(BLLTableView*)aTableView
{
	return 30;
}


-(NSUInteger) numberOfRowsInTableView:(BLLTableView*)aTableView
{
	return [self.data count];
}

-(BLLTableViewCell*) tableView:(BLLTableView*)aTableView viewAtIndex:(NSUInteger) index
{
	BLLTableViewCell* cell = nil;
	
	cell = [aTableView dequeueReusableTableViewCell];
	
	if(index < [self.data count])
	{
		if(cell == nil)
		{
			cell = [[[BLLTableViewCell alloc] initWithFrame:NSMakeRect(0, 0, 300, 30)] autorelease];
			
			NSRect textFieldRect = cell.bounds;
			textFieldRect.size.height = 18;
			textFieldRect = CGRectInset(textFieldRect, 2, 0);
			
			NSRect pathFieldRect = cell.bounds;
			pathFieldRect.origin.y = 18;
			pathFieldRect.size.height = 10;
			
			
			NSTextField* textField = [[[NSTextField alloc] initWithFrame:textFieldRect] autorelease];
			[textField setTag:1001];
			[textField setBezeled:NO];
			[textField setEditable:NO];
			
			[textField setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
			[cell addSubview:textField];
			
			NSPathControl* pathControl = [[[NSPathControl alloc] initWithFrame:pathFieldRect] autorelease];
			[pathControl setBackgroundColor:[NSColor whiteColor]];
			[pathControl setAlphaValue:0.5]; // Hack to make the text gray;
			[[pathControl cell] setBordered:NO];
			[[pathControl cell] setBezeled:NO];
			
			[pathControl setFont: [NSFont fontWithName:[[pathControl font] fontName] size:9]];
			
			[pathControl setTag:1002];
			[pathControl setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
			[cell addSubview:pathControl];
		}
		
		NSString* str = [self.data objectAtIndex:index];
		
		[(NSTextField*)[cell viewWithTag:1001] setStringValue:str];
	}
	else
	{
		[(NSTextField*)[cell viewWithTag:1001] setStringValue:@""];			
	}
	return cell;
}

#pragma mark -

@end
