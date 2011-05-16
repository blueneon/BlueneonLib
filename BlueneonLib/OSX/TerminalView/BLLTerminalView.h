//
//  BLLTerminalView.h
//  Xgdb
//
//  Created by Alex Carter on 13-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BLLTerminalTextView;
@class BLLTerminalViewController;
@interface BLLTerminalView : NSView 
{
    NSScrollView* _internalScrollView;
    BLLTerminalViewController* _internalController;
}
@property (retain, nonatomic) NSTask* task;

@end
