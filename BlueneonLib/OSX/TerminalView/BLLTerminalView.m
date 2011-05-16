//
//  BLLTerminalView.m
//  Xgdb
//
//  Created by Alex Carter on 13-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BLLTerminalView.h"
#import "BLLTerminalViewController.h"

@interface BLLTerminalView ()
@property (retain, readonly) NSScrollView* internalScrollView; 
@property (retain, readonly) BLLTerminalViewController* internalController;
@end

@implementation BLLTerminalView
@synthesize internalScrollView=_internalScrollView;
@synthesize internalController=_internalController;
@dynamic task;
#pragma mark -
#pragma mark Lifecycle 

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self awakeFromNib];
    }
    
    return self;
}

- (void)dealloc {
    [_internalScrollView release];
    _internalScrollView = nil;
    
    [_internalController release];
    _internalController = nil;
    
    [super dealloc];
}

-(void) awakeFromNib
{
    [self addSubview:[self internalScrollView]];
}

#pragma mark -
#pragma mark Accessors 

-(BLLTerminalViewController*) internalController
{
    if(_internalController == nil) {
        _internalController = [[BLLTerminalViewController alloc] init];
    }
    return _internalController;
}

-(NSScrollView*) internalScrollView 
{
    if(_internalScrollView == nil) {
        _internalScrollView = [[NSScrollView alloc] initWithFrame:[self bounds]];
        BLLTerminalTextView* textView = [[self internalController] textView];
        [textView setFrame:[self bounds]];
        [_internalScrollView setDocumentView:(NSView*)textView];
        [_internalScrollView setHasVerticalScroller:YES];
        [_internalScrollView setBackgroundColor:[NSColor redColor]];
        [_internalScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    return _internalScrollView;
}

-(void) setTask:(NSTask *)task
{
    [[self internalController] setTask:task];
}

#pragma mark -

@end
