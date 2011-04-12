//
//  TestCollectionView.m
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

#import "TestCollectionView.h"


@implementation TestCollectionView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
		[self awakeFromNib];
    }
    return self;
}


-(void) awakeFromNib
{
	
	[self setMinItemSize:NSMakeSize(self.bounds.size.width,20)];
	[self setMaxItemSize:NSMakeSize(self.bounds.size.width, 200)];
	
//	NSCollectionViewItem* item = [[[NSCollectionViewItem alloc] init] autorelease];
	//	[item setView:[[[NSTextField alloc] initWithFrame:NSMakeRect(0,0, 320, 44)] autorelease]];
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
	
	[self setContent:contents];
	
	
	
}

- (void) dealloc
{
	
	[super dealloc];
}

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object
{
	NSCollectionViewItem* item = [[NSCollectionViewItem alloc] init];
	
	NSPathControl* view = [[[NSPathControl alloc] initWithFrame:NSMakeRect(0,0, 120, 24)] autorelease];
	
	[view setURL:[NSURL URLWithString:object]];
	
	[item setView:view];
	[item setRepresentedObject:object];	
	return item;
}


@end
