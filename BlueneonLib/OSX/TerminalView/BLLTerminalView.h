//
//  BLLTerminalView.h
//  Xgdb
//
//  Created by Alex Carter on 13-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLLTerminalViewDelegate.h"

@class BLLTerminalTextView;
@class BLLTerminalViewController;
@interface BLLTerminalView : NSView 
{
    NSScrollView* _internalScrollView;
    BLLTerminalViewController* _internalController;
}
@property (retain, nonatomic) NSTask* task;
@property (assign, readonly) NSMutableArray* commandHistory;
@property (assign, nonatomic) id<BLLTerminalViewDelegate> delegate;

-(void) sendCommands:(NSArray*) commands excludeFromHistory:(BOOL) exclude;
-(void) sendCommand:(NSString*) command excludeFromHistory:(BOOL) exclude;
-(void) sendCommands:(NSArray*) commands;
-(void) sendCommand:(NSString*) command;

@end
