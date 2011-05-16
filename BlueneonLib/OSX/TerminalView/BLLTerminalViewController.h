//
//  BLLTerminalViewController.h
//  Xgdb
//
//  Created by Alex Carter on 14-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLLTerminalView;
@class BLLTerminalTextView;

@interface BLLTerminalViewController : NSObject {
@private
    BLLTerminalTextView* _textView;
    NSTask* _task;
// Internal
    dispatch_source_t _stdoutDispatchSource;
    dispatch_source_t _stderrDispatchSource;
    dispatch_queue_t _readDispachQueue;
}
@property (retain, readonly) BLLTerminalTextView* textView;
@property (retain, nonatomic) NSTask* task;
@end
