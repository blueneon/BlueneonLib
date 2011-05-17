//
//  BLLTerminalViewController.m
//  Xgdb
//
//  Created by Alex Carter on 14-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BLLTerminalViewController.h"
#import "BLLTerminalTextView.h"
#import "BLLRange.h"
#import "Debug.h"

@interface BLLTerminalViewController ()
    @property (assign, readonly) dispatch_queue_t readDispachQueue;
    @property (assign) NSRange editableRange;
    @property(retain,nonatomic) NSString* editedText;

    -(void) installStandardOutputPipeForTask:(NSTask*) aTask;
    -(void) appendStdoutString:(NSString*) string;
    -(void) appendStderrString:(NSString*) string;
    -(void) resetEditableRange;
@end

@implementation BLLTerminalViewController
@synthesize textView=_textView;
@synthesize task=_task;
@synthesize commandHistory=_commandHistory;
// Private
@synthesize readDispachQueue=_readDispachQueue;
@synthesize editableRange=_editableRange;
@synthesize editedText=_editedText;

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
    self.commandHistory = nil;
   
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
    
    self.editedText = nil;
    
    [_textView release];
    _textView = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark Accessors 

-(NSMutableArray*) commandHistory
{
    if(_commandHistory == nil) {
        _commandHistory = [NSMutableArray array];
        [_commandHistory addObject:[NSString string]];
    }
    return _commandHistory; 
}

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
        [_textView setDelegate:self];
    }
    return _textView;
}

-(void) installStandardOutputPipeForTask:(NSTask*) aTask
{
    dispatch_sync([self readDispachQueue], ^{
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
    });
}

-(void) installStandardErrorPipeForTask:(NSTask*) aTask
{
    dispatch_sync([self readDispachQueue], ^{
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
    });
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
#pragma mark NSTextViewDelegate

-(BOOL) textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    if(commandSelector == @selector(insertNewline:))
    {
        NSAttributedString* attributedString = [[[NSAttributedString alloc] initWithString:@"\n"] autorelease];
        [[textView textStorage] insertAttributedString:attributedString atIndex:[[textView textStorage] length]];

        NSString* commandString = [[[[textView textStorage] attributedSubstringFromRange:self.editableRange] string] 
                                   stringByAppendingString:@"\n"];
        
        [self willChangeValueForKey:@"commandHistory"];
        [[self commandHistory] replaceObjectAtIndex:0 withObject:commandString];
        [[self commandHistory] insertObject:[[[NSAttributedString alloc] initWithString:@""] autorelease] atIndex:0];
        [self didChangeValueForKey:@"commandHistory"];
        
        NSData* data = [commandString dataUsingEncoding:NSASCIIStringEncoding];
        [[[_task standardInput] fileHandleForWriting] writeData:data];
        [self resetEditableRange]; 
        result = YES;
    }
    
    return result;
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray *)affectedRanges replacementStrings:(NSArray *)replacementStrings
{
    __block BOOL result = YES;
    [affectedRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop){
        NSRange modRange = [(NSValue*)obj rangeValue];
        if(!(IsIndexInRangeInclusive(modRange.location, self.editableRange) 
           && IsIndexInRangeInclusive(modRange.location + modRange.length, self.editableRange))) {
            result = NO; 
        }
    }];   
    
    if (result) {
        __block NSInteger accumLengthIncrease = 0;
        [affectedRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop){
            NSRange modRange = [(NSValue*)obj rangeValue];
            NSString* newString = [replacementStrings objectAtIndex:idx];
            accumLengthIncrease += [newString length] - modRange.length;
        }];
        
        self.editableRange = NSMakeRange(self.editableRange.location,self.editableRange.length + accumLengthIncrease);
        
        displayDebugValue(NSStringFromRange(self.editableRange),@"Editable range");
        
    }
    
    return result;
}

- (void)textDidBeginEditing:(NSNotification *)aNotification
{
}

- (void)textDidChange:(NSNotification *)aNotification
{
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSColor blackColor],NSForegroundColorAttributeName,
                  nil];
    [[[self textView] textStorage] setAttributes:attributes range:self.editableRange];
    
    [self willChangeValueForKey:@"commandHistory"];
    [[self commandHistory] replaceObjectAtIndex:0 
                                     withObject:[[[self textView] textStorage] attributedSubstringFromRange:self.editableRange]];
    [self didChangeValueForKey:@"commandHistory"];
    
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
    
}

#pragma mark -
#pragma mark Methods

-(void) resetEditableRange
{
    self.editableRange = NSMakeRange([[[self textView] textStorage] length],0);    
    
    displayDebugValue(NSStringFromRange(self.editableRange),@"Editable range");
}

-(void) extendEditableRangeBy:(NSInteger) delta
{
    NSInteger newLocation = self.editableRange.location;
    NSInteger newLength = MAX(self.editableRange.length + labs(delta),0);
    if(delta < 0) {
        newLocation = MAX(newLocation + delta,0);
    }
    
    self.editableRange = NSMakeRange(newLocation, newLength);    
    
    displayDebugValue(NSStringFromRange(self.editableRange),@"Editable range");
}

-(void) appendStdoutString:(NSString*) string
{
    NSAttributedString* tmpEditedString = [[[self textView] textStorage] attributedSubstringFromRange:self.editableRange];
    [[[self textView] textStorage] replaceCharactersInRange:self.editableRange withString:@""];
    
    NSDictionary* attributes = nil;
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSColor darkGrayColor],NSForegroundColorAttributeName,
                                nil];
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    [[[self textView] textStorage] appendAttributedString:attributedString];
    [attributedString release];
    
    [self resetEditableRange];
    [[[self textView] textStorage] insertAttributedString:tmpEditedString atIndex:self.editableRange.location];
    [self extendEditableRangeBy:[tmpEditedString length]];
    
    [[self textView] scrollRangeToVisible:self.editableRange];
}

-(void) appendStderrString:(NSString*) string
{
    NSAttributedString* tmpEditedString = [[[self textView] textStorage] attributedSubstringFromRange:self.editableRange];
    [[[self textView] textStorage] replaceCharactersInRange:self.editableRange withString:@""];
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSColor redColor],NSForegroundColorAttributeName,
                                nil];
    
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    [[[self textView] textStorage] appendAttributedString:attributedString];
    [attributedString release];
    
    [self resetEditableRange];
    [[[self textView] textStorage] insertAttributedString:tmpEditedString atIndex:self.editableRange.location];
    [self extendEditableRangeBy:[tmpEditedString length]];
        
    [[self textView] scrollRangeToVisible:self.editableRange];
}




@end
