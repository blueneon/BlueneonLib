//
//  BLLTerminalViewDataSource.h
//  Xgdb
//
//  Created by Alex Carter on 20-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BLLTerminalViewDataSource <NSObject>

- (void)setStandardInput:(id)input;
- (void)setStandardOutput:(id)output;
- (void)setStandardError:(id)error;

- (id)standardInput;
- (id)standardOutput;
- (id)standardError;

@optional
- (pid_t) processIdentifier;

@end
