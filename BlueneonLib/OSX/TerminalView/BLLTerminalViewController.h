//
//  BLLTerminalViewController.h
//  Xgdb
//
//  Created by Alex Carter on 14-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLLTerminalTextView.h"

@class BLLTerminalView;
@class BLLTerminalTextView;
@class BLLTerminalViewController;
@protocol BLLTerminalViewDelegate;
@protocol BLLTerminalViewDataSource;

@interface BLLTerminalViewController : NSObject <BLLTerminalTextViewDelegate> {
@private
    BLLTerminalView* _terminalView;
    BLLTerminalTextView* _textView;
    NSInteger _selectedCommandHistory;
    NSMutableArray* _commandHistory;
    id<BLLTerminalViewDelegate> _delegate;
    id<BLLTerminalViewDataSource> _dataSource;
    
// Internal
    dispatch_source_t _stdoutDispatchSource;
    dispatch_source_t _stderrDispatchSource;
    dispatch_queue_t _readDispachQueue;
    NSMutableDictionary* _shadowCommandHistory;
    
    NSRange _editableRange;
    NSString* _editedText;
}
@property (retain, readonly) BLLTerminalTextView* textView;
@property (assign, nonatomic) NSInteger selectedCommandHistory;
@property (retain, nonatomic) NSMutableArray* commandHistory;
@property (assign, nonatomic) id<BLLTerminalViewDelegate> delegate;
@property (retain, nonatomic) id<BLLTerminalViewDataSource> dataSource;

-(id) initWithTerminalView:(BLLTerminalView*) terminalView;

-(BOOL) sendCommands:(NSArray*) commands excludeFromHistory:(BOOL) exclude;

@end
