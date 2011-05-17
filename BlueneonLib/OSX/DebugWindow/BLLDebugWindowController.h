//
//  BLLDebugWindowController.h
//  Xgdb
//
//  Created by Alex Carter on 5/16/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BLLDebugWindowController : NSWindowController {
    IBOutlet NSDictionaryController *debugInfoController;
    
    NSMutableDictionary* _debugInfo;
}
@property (retain, nonatomic) NSMutableDictionary* debugInfo;

+(id) sharedInstance;
+(void) updateValue:(NSString*)value forKey:(NSString*)key;

@end
