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
@dynamic commandHistory;
@dynamic delegate;
@dynamic dataSource;
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
    
    if(_internalController){
        [_internalController removeObserver:self forKeyPath:@"commandHistory"];
    }
    
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
        _internalController = [[BLLTerminalViewController alloc] initWithTerminalView:self];
        [_internalController addObserver:self forKeyPath:@"commandHistory" options:NSKeyValueObservingOptionPrior context:NULL];
        
    }
    return _internalController;
}

-(NSScrollView*) internalScrollView 
{
    if(_internalScrollView == nil) {
        _internalScrollView = [[NSScrollView alloc] initWithFrame:[self bounds]];
        BLLTerminalTextView* textView = [[self internalController] textView];
        [textView setFrame:[self bounds]];
        [(NSView*)textView setAutoresizingMask:NSViewWidthSizable];
                
        [_internalScrollView setDocumentView:(NSView*)textView];
        [_internalScrollView setHasVerticalScroller:YES];
        [_internalScrollView setBackgroundColor:[NSColor redColor]];
        [_internalScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    return _internalScrollView;
}

-(void) setDataSource:(id<BLLTerminalViewDataSource>)dataSource
{
    [[self internalController] setDataSource:dataSource];
}

-(id<BLLTerminalViewDataSource>) dataSource
{
    return [[self internalController] dataSource];
}

-(NSMutableArray*) commandHistory
{
    return [[self internalController] commandHistory];
}

-(id<BLLTerminalViewDelegate>) delegate
{
    return [[self internalController] delegate];
}

-(void) setDelegate:(id<BLLTerminalViewDelegate>)delegate
{
    [[self internalController] setDelegate:delegate];
}

#pragma mark -
#pragma mark Event handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _internalController && [keyPath isEqualToString:@"commandHistory"]) {
        if([change objectForKey:NSKeyValueChangeNotificationIsPriorKey] != nil) {
            [self willChangeValueForKey:@"commandHistory"];
        } else {
            [self didChangeValueForKey:@"commandHistory"];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -
#pragma mark Methods


-(void) sendCommands:(NSArray*) commands
{
    [[self internalController] sendCommands:commands excludeFromHistory:YES];
}

-(void) sendCommands:(NSArray*) commands excludeFromHistory:(BOOL) exclude
{
    [[self internalController] sendCommands:commands excludeFromHistory:exclude];
}

-(void) sendCommand:(NSString*) command
{
    [self sendCommands:[NSArray arrayWithObject:command]];
}

-(void) sendCommand:(NSString*) command excludeFromHistory:(BOOL) exclude
{
    [self sendCommands:[NSArray arrayWithObject:command] excludeFromHistory:exclude];
}

@end
