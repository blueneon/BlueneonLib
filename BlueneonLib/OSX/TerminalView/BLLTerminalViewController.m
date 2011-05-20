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
#import "BLLTerminalViewDelegate.h"
#import "Debug.h"

@interface BLLTerminalViewController ()
@property (assign, readonly) dispatch_queue_t readDispachQueue;
@property (assign) NSRange editableRange;
@property(retain,nonatomic) NSString* editedText;
@property(retain,nonatomic) NSMutableDictionary* shadowCommandHistory;

-(void) installStandardOutputPipeForTask:(NSTask*) aTask;
-(void) appendStdoutString:(NSString*) string;
-(void) appendStderrString:(NSString*) string;
-(void) replaceEditableRangeWithString:(NSString*) string;
-(void) resetEditableRange;
-(BOOL) isSelectionInEditableRange;
// Convinience
-(BOOL) shouldSendData:(NSData*) data;
-(NSData*) willSendData:(NSData*) data;
-(void) didSendData:(NSData*) data;
-(void) didRecieveData:(NSData*) data;
-(BOOL) shouldDisplayData:(NSData*) data;
-(NSData*) willDisplayData:(NSData*) data;
-(void) didDisplayData:(NSData*) data;
-(BOOL) sendData:(NSData*)data;
-(BOOL) recvData:(NSData*) data onPipe:(NSPipe*) pipe;
// Command history
-(void) selectPrevCommand;
-(void) selectNextCommand;
-(void) pushCommand;
-(void) updateCommandWithString:(NSString*) command atIndex:(NSInteger) index;
-(void) updateCommandWithString:(NSString*) command;
-(void) updateTopCommandWithString:(NSString*) command;

@end

@implementation BLLTerminalViewController
@synthesize textView=_textView;
@synthesize task=_task;
@synthesize selectedCommandHistory=_selectedCommandHistory;
@synthesize commandHistory=_commandHistory;
@synthesize delegate=_delegate;
// Private
@synthesize readDispachQueue=_readDispachQueue;
@synthesize editableRange=_editableRange;
@synthesize editedText=_editedText;
@synthesize shadowCommandHistory=_shadowCommandHistory;

#pragma mark -
#pragma mark Lifecycle 

-(id) initWithTerminalView:(BLLTerminalView*) terminalView {
    self = [super init];
    if (self) {
        _terminalView = terminalView;
        _stdoutDispatchSource = NULL;
        _stderrDispatchSource = NULL;
        _selectedCommandHistory = NSNotFound;
        _delegate = nil;
    }
    return self;
}

- (void)dealloc {
    _terminalView = nil;
    self.delegate = nil;
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
        _commandHistory = [[NSMutableArray alloc] init];
    }
    return _commandHistory; 
}

-(NSMutableDictionary*) shadowCommandHistory
{
    if(_shadowCommandHistory == nil) {
        _shadowCommandHistory = [[NSMutableDictionary alloc] init];
    }
    return _shadowCommandHistory; 
}

-(dispatch_queue_t) readDispachQueue
{
    if (_readDispachQueue == NULL) {
        _readDispachQueue = dispatch_queue_create([[NSString stringWithFormat:@"com.blueneon.task.input[%d]",[self hash]] cStringUsingEncoding:NSUTF8StringEncoding], NULL);
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self recvData:inData onPipe:pipe];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self recvData:inData onPipe:pipe];
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
#pragma mark Public Methods

-(BOOL) sendCommands:(NSArray*) commands excludeFromHistory:(BOOL) exclude
{
    __block BOOL result = YES;
    dispatch_async(dispatch_get_main_queue(),^{
        [commands enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL* stop){
            if (!exclude) {
                [self updateTopCommandWithString:(NSString*)obj];
                [self pushCommand];
            }            
            NSString* command = [(NSString*)obj stringByAppendingString:@"\n"];
            NSData* data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
            result &= [self sendData:data];
        }];
    });
    return result;
}

#pragma mark -
#pragma mark Command History
-(void) selectPrevCommand
{
    @try {
        self.selectedCommandHistory = MIN(self.selectedCommandHistory + 1,[[self commandHistory] count] - 1);   
        [self replaceEditableRangeWithString:[[self commandHistory] objectAtIndex:self.selectedCommandHistory]];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@",exception);
    }
}

-(void) selectNextCommand
{
    @try {
        self.selectedCommandHistory = MAX(self.selectedCommandHistory - 1,0);
        [self replaceEditableRangeWithString:[[self commandHistory] objectAtIndex:self.selectedCommandHistory]];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@",exception);
    }
}

-(void) pushCommand
{
    [self willChangeValueForKey:@"commandHistory"];
#define USE_IMUTABLE_COMMAND_HISTORY 1
#if USE_IMUTABLE_COMMAND_HISTORY
    [[self shadowCommandHistory] enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL* stop){
        if(obj) {
            [[self commandHistory] replaceObjectAtIndex:[key integerValue] withObject:obj];
        }
    }];
#else
    NSString* lastValue = [[self shadowCommandHistory] objectForKey:[NSNumber numberWithInteger:self.selectedCommandHistory]];
    if(lastValue) {
        [[self commandHistory] replaceObjectAtIndex:self.selectedCommandHistory withObject:lastValue];
    }
#endif //USE_IMUTABLE_COMMAND_HISTORY  
    [[self shadowCommandHistory] removeAllObjects];
    [[self commandHistory] insertObject:[[NSString string] autorelease] atIndex:0];
    self.selectedCommandHistory = 0;
    [self didChangeValueForKey:@"commandHistory"];
}

-(void) updateCommandWithString:(NSString*) command atIndex:(NSInteger) index
{    
    NSString* lastValue = [[self commandHistory] objectAtIndex:index];
    
    if([[self shadowCommandHistory] objectForKey:[NSNumber numberWithInteger:index]] == nil
       && [lastValue length] > 0
       && index != 0) {
        [[self shadowCommandHistory] setObject:lastValue forKey:[NSNumber numberWithInteger:index]]; 
    }
    
    [self willChangeValueForKey:@"commandHistory"];
    [[self commandHistory] replaceObjectAtIndex:index withObject:command];
    [self didChangeValueForKey:@"commandHistory"];
}


-(void) updateCommandWithString:(NSString*) command
{
    if([[self commandHistory] count] == 0) {
        [self pushCommand];
    }
        
    [self updateCommandWithString:command atIndex:self.selectedCommandHistory];
}

-(void) updateTopCommandWithString:(NSString*) command
{
    if([[self commandHistory] count] == 0) {
        [self pushCommand];
    }
    
    [self updateCommandWithString:command atIndex:0];
}

#pragma mark -
#pragma mark BLLTerminalTextViewDelegate

-(void) textViewDidRecieve:(BLLTerminalTextView*) terminalTextView keyDownEvent:(NSEvent*) theEvent;
{
    if ([theEvent modifierFlags] & NSControlKeyMask) {
        
        if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"c"]) {
            [self sendData:[[NSString stringWithString:@"\\cc"] dataUsingEncoding:[NSString defaultCStringEncoding]]];
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

        NSString* commandString = [[[textView textStorage] attributedSubstringFromRange:self.editableRange] string];       
//        [self updateTopCommandWithString:commandString];
//        [self pushCommand];
//        
//        NSData* data = [[commandString stringByAppendingString:@"\n"] dataUsingEncoding:NSASCIIStringEncoding];
//        if([self sendData:data]) {
//            [self resetEditableRange]; 
//            result = YES;
//        }
        if([self sendCommands:[NSArray arrayWithObject:commandString] excludeFromHistory:NO]) {
            [self resetEditableRange]; 
            result = YES;
        } 
    } else if(commandSelector == @selector(moveUp:) && [self isSelectionInEditableRange]) {
        [self selectPrevCommand];
        result = YES;
    } else if(commandSelector == @selector(moveDown:) && [self isSelectionInEditableRange]) {
        [self selectNextCommand];
        result = YES;
    } else {    
        NSLog(@"Selector: %@", NSStringFromSelector(commandSelector));
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
    [self updateCommandWithString:[[[[self textView] textStorage] attributedSubstringFromRange:self.editableRange] string]];    
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
    
}

#pragma mark -
#pragma mark Methods

-(BOOL) isSelectionInEditableRange
{
    NSRange selectedRange = [[self textView] selectedRange];
    if(IsIndexInRangeInclusive(selectedRange.location, self.editableRange) 
       && IsIndexInRangeInclusive(selectedRange.location + selectedRange.length, self.editableRange)) {
        return YES; 
    }
    return NO;
}

-(void) replaceEditableRangeWithString:(NSString*) string
{ 
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSColor blackColor],NSForegroundColorAttributeName,
                  nil];
    NSAttributedString* attributedString = [[[NSAttributedString alloc] initWithString:string attributes:attributes] autorelease];
    if (self.editableRange.length > 0 || [attributedString length] > 0) {
        @try {
            [[[self textView] textStorage] replaceCharactersInRange:self.editableRange withAttributedString:attributedString];    
            self.editableRange = NSMakeRange(self.editableRange.location, [attributedString length]);
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@",exception);
        }
    }
}

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
    NSAttributedString* attributedString = [[[NSAttributedString alloc] initWithString:string attributes:attributes] autorelease];
    [[[self textView] textStorage] appendAttributedString:attributedString];
    
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
    
    NSAttributedString* attributedString = [[[NSAttributedString alloc] initWithString:string attributes:attributes] autorelease];
    [[[self textView] textStorage] appendAttributedString:attributedString];
    
    [self resetEditableRange];
    [[[self textView] textStorage] insertAttributedString:tmpEditedString atIndex:self.editableRange.location];
    [self extendEditableRangeBy:[tmpEditedString length]];
        
    [[self textView] scrollRangeToVisible:self.editableRange];
}

#pragma mark -
#pragma Delegate Interface

-(BOOL) shouldSendData:(NSData*) data
{
    BOOL result = YES;    
    if([_delegate respondsToSelector:@selector(terminalView:shouldSendData:toTask:)]) {
        result = [_delegate terminalView:_terminalView shouldSendData: data toTask:_task];
    }    
    return result;
}

-(NSData*) willSendData:(NSData*) data
{    
    if([_delegate respondsToSelector:@selector(terminalView:willSendData:toTask:)]) {
        data = [_delegate terminalView:_terminalView willSendData:data toTask:_task];        
    }    
    return data;
}

-(void) didSendData:(NSData*) data
{
    if([_delegate respondsToSelector:@selector(terminalView:didSendData:toTask:)]) {
        [_delegate terminalView:_terminalView didSendData:data toTask:_task];        
    }        
}

-(void) didRecieveData:(NSData*) data 
{
    if([_delegate respondsToSelector:@selector(terminalView:didRecieveData:fromTask:)]) {
        [_delegate terminalView:_terminalView didRecieveData:data fromTask:_task];        
    } 
}

-(BOOL) shouldDisplayData:(NSData*) data
{
    BOOL result = YES;
    if([_delegate respondsToSelector:@selector(terminalView:shouldDisplayData:fromTask:)]) {
        result = [_delegate terminalView:_terminalView shouldDisplayData:data fromTask:_task];
    }    
    return result;    
}

-(NSData*) willDisplayData:(NSData*) data
{
    if([_delegate respondsToSelector:@selector(terminalView:willDisplayData:fromTask:)]) {
        data = [_delegate terminalView:_terminalView willDisplayData:data fromTask:_task];
    }        
    return data;
}

-(void) didDisplayData:(NSData*) data
{
    if([_delegate respondsToSelector:@selector( terminalView:didDisplayData:fromxxxxTask:)]) {
        [_delegate terminalView:_terminalView didDisplayData:data fromTask:_task];                
    }     
}

-(BOOL) sendData:(NSData*) data
{
    BOOL send = [self shouldSendData:data];
    if (send) {
        data = [self willSendData:data];
        if ([[[[NSString alloc] initWithData:data encoding:[NSString defaultCStringEncoding]] autorelease] isEqualToString:@"\\cc"]) {
            pid_t pid = [self.task processIdentifier];
            if (pid > 0) {
                kill(pid, SIGINT);
            }
        } else {
            [[[_task standardInput] fileHandleForWriting] writeData:data];
        }
        [self didSendData:data];
    } 
    return send;
}

-(BOOL) recvData:(NSData*) data onPipe:(NSPipe*) pipe
{
    [self didRecieveData:data];
    BOOL result = [self shouldDisplayData:data];
    if(result) {   
        data = [self willDisplayData:data];
        NSString* str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];  
        if([_task standardOutput] == pipe) {
            [self appendStdoutString:str];
        } else {
            [self appendStderrString:str];
        }
        [self didDisplayData:data];
    }
    return result;
}

@end
