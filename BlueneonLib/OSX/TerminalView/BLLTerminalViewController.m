//
//  BLLTerminalViewController.m
//  Xgdb
//
//  Created by Alex Carter on 14-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BLLTerminalViewController.h"
#import "BLLTerminalTextView.h"

@interface BLLTerminalViewController ()
    @property (assign, readonly) dispatch_queue_t readDispachQueue;
    -(void) installStandardOutputPipeForTask:(NSTask*) aTask;
    -(void) appendStdoutString:(NSString*) string;
    -(void) appendStderrString:(NSString*) string;
@end

@implementation BLLTerminalViewController
@synthesize textView=_textView;
@synthesize task=_task;
// Private
@synthesize readDispachQueue=_readDispachQueue;

#pragma mark -
#pragma mark Lifecycle 

- (id)init {
    self = [super init];
    if (self) {
        _stdoutDispatchSource = NULL;
        _stderrDispatchSource = NULL;
    }
    return self;
}

- (void)dealloc {
    
    self.task = nil;
   
    if (_stdoutDispatchSource) {
        dispatch_source_cancel(_stdoutDispatchSource);
    }
    if (_stderrDispatchSource) {
        dispatch_source_cancel(_stderrDispatchSource);
    }
    if(_readDispachQueue != NULL) {
        dispatch_release(_readDispachQueue);
        _readDispachQueue = NULL;
    }
    
    [_textView release];
    _textView = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark Accessors 

-(dispatch_queue_t) readDispachQueue
{
    if (_readDispachQueue == NULL) {
        _readDispachQueue = dispatch_queue_create([[NSString stringWithFormat:@"com.blueneon.task.input[@d]",[self hash]] cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    }
    return _readDispachQueue;
}

-(BLLTerminalTextView*) textView
{
    if (_textView == nil) {
        _textView = [[BLLTerminalTextView alloc] initWithFrame:NSZeroRect];
    }
    return _textView;
}

-(void) installStandardOutputPipeForTask:(NSTask*) aTask
{
    if (_stdoutDispatchSource) {
        dispatch_source_cancel(_stdoutDispatchSource);
    }
    NSPipe* pipe = [[[NSPipe alloc] init] autorelease];
    uintptr_t fileHandle = [[pipe fileHandleForReading] fileDescriptor];
    _stdoutDispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fileHandle,0,[self readDispachQueue]);
    dispatch_source_set_cancel_handler(_stdoutDispatchSource, ^{
        dispatch_release(_stdoutDispatchSource);
        _stdoutDispatchSource = NULL;
    });
    dispatch_source_set_event_handler(_stdoutDispatchSource, ^{
        NSData *inData = [[pipe fileHandleForReading] availableData];
        if([inData length]) {
            NSString* str = [[[NSString alloc] initWithData:inData encoding:NSUTF8StringEncoding] autorelease];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendStdoutString:str];
            });
        }
    });
    dispatch_resume(_stdoutDispatchSource);
    [aTask setStandardOutput:pipe];
}


-(void) installStandardErrorPipeForTask:(NSTask*) aTask
{
    if (_stderrDispatchSource) {
        dispatch_source_cancel(_stderrDispatchSource);
    }
    NSPipe* pipe = [[[NSPipe alloc] init] autorelease];
    uintptr_t fileHandle = [[pipe fileHandleForReading] fileDescriptor];
    _stderrDispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fileHandle,0,[self readDispachQueue]);
    dispatch_source_set_cancel_handler(_stderrDispatchSource, ^{
        dispatch_release(_stderrDispatchSource);
        _stderrDispatchSource = NULL;
    });
    dispatch_source_set_event_handler(_stderrDispatchSource, ^{
        NSData *inData = [[pipe fileHandleForReading] availableData];
        if([inData length]) {
            NSString* str = [[[NSString alloc] initWithData:inData encoding:NSUTF8StringEncoding] autorelease];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendStderrString:str];
            });
        }
    });
    dispatch_resume(_stderrDispatchSource);
    [aTask setStandardError:pipe];
}


-(void) installStandardInputPipeForTask:(NSTask*) aTask
{
    NSPipe* pipe = [[[NSPipe alloc] init] autorelease];
    [aTask setStandardInput:pipe];
}


-(void) setTask:(NSTask *)task
{
    if(_task != task) {
        [_task autorelease];
        _task = [task retain];
        
        if(_task) {
            [self installStandardOutputPipeForTask:_task];
            [self installStandardErrorPipeForTask:_task];
            [self installStandardInputPipeForTask:_task];
        }
    }
}

#pragma mark -
#pragma mark Methods

-(void) appendStdoutString:(NSString*) string
{
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:string];
    [[[self textView] textStorage] appendAttributedString:attributedString];
    [attributedString release];
}

-(void) appendStderrString:(NSString*) string
{
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSColor redColor],NSForegroundColorAttributeName,
                                nil];
    
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    [[[self textView] textStorage] appendAttributedString:attributedString];
    [attributedString release];
}



@end
