//
//  BLLTerminalViewDelegate.h
//  Xgdb
//
//  Created by Alex Carter on 5/19/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BLLTerminalView;
@protocol BLLTerminalViewDataSource;

@protocol BLLTerminalViewDelegate <NSObject>
@optional
-(BOOL) terminalView:(BLLTerminalView*)terminalView shouldSendData:(NSData*) data toDataSource:(id<BLLTerminalViewDataSource>) dataSource;
-(NSData*) terminalView:(BLLTerminalView*)terminalView willSendData:(NSData*) data toDataSource:(id<BLLTerminalViewDataSource>) dataSource;
-(void) terminalView:(BLLTerminalView*)terminalView didSendData:(NSData*) data toDataSource:(id<BLLTerminalViewDataSource>) dataSource;


-(void) terminalView:(BLLTerminalView*)terminalView didRecieveData:(NSData*) data fromDataSource:(id<BLLTerminalViewDataSource>) dataSource;

-(BOOL) terminalView:(BLLTerminalView*)terminalView shouldDisplayData:(NSData*) data fromDataSource:(id<BLLTerminalViewDataSource>) dataSource;
-(NSData*) terminalView:(BLLTerminalView*)terminalView willDisplayData:(NSData*) data fromDataSource:(id<BLLTerminalViewDataSource>) dataSource;
-(void) terminalView:(BLLTerminalView*)terminalView didDisplayData:(NSData*) data fromDataSource:(id<BLLTerminalViewDataSource>) dataSource;

@end