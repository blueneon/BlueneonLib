//
//  BLLTerminalTextView.m
//  Xgdb
//
//  Created by Alex Carter on 14-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BLLTerminalTextView.h"

@implementation BLLTerminalTextView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) keyDown:(NSEvent *)theEvent
{
    if ([[self delegate] respondsToSelector:@selector(textViewDidRecieve:keyDownEvent:)]) {
        [(id<BLLTerminalTextViewDelegate>)[self delegate] textViewDidRecieve:self keyDownEvent:theEvent];
    }
    [super keyDown:theEvent];
}

-(void) keyUp:(NSEvent *)theEvent
{
    if ([[self delegate] respondsToSelector:@selector(textViewDidRecieve:keyUpEvent:)]) {
        [(id<BLLTerminalTextViewDelegate>)[self delegate] textViewDidRecieve:self keyUpEvent:theEvent];
    }
    [super keyUp:theEvent];
}


@end
