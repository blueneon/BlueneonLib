//
//  BLLTerminalViewDelegate.h
//  Xgdb
//
//  Created by Alex Carter on 5/19/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BLLTerminalView;

@protocol BLLTerminalViewDelegate <NSObject>
@optional
-(BOOL) terminalView:(BLLTerminalView*)terminalView shouldSendData:(NSData*) data toTask:(NSTask*) task;
-(NSData*) terminalView:(BLLTerminalView*)terminalView willSendData:(NSData*) data toTask:(NSTask*) task;
-(void) terminalView:(BLLTerminalView*)terminalView didSendData:(NSData*) data toTask:(NSTask*) task;


-(void) terminalView:(BLLTerminalView*)terminalView didRecieveData:(NSData*) data fromTask:(NSTask*) task;

-(BOOL) terminalView:(BLLTerminalView*)terminalView shouldDisplayData:(NSData*) data fromTask:(NSTask*) task;
-(NSData*) terminalView:(BLLTerminalView*)terminalView willDisplayData:(NSData*) data fromTask:(NSTask*) task;
-(void) terminalView:(BLLTerminalView*)terminalView didDisplayData:(NSData*) data fromTask:(NSTask*) task;

@end