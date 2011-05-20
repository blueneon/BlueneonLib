//
//  BLLTerminalTextView.h
//  Xgdb
//
//  Created by Alex Carter on 14-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BLLTerminalTextView;
@protocol BLLTerminalTextViewDelegate <NSTextViewDelegate>
@optional
-(void) textViewDidRecieve:(BLLTerminalTextView*) terminalTextView keyDownEvent:(NSEvent*) theEvent;
-(void) textViewDidRecieve:(BLLTerminalTextView*) terminalTextView keyUpEvent:(NSEvent*) theEvent;
@end

@interface BLLTerminalTextView : NSTextView

@end
