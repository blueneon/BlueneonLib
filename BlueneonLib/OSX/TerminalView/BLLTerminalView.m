//
//  BLLTerminalView.m
//  Xgdb
//
//  Created by Alex Carter on 13-05-11.
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
