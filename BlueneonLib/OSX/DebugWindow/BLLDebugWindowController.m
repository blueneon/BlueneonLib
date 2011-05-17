//
//  BLLDebugWindowController.m
//  Xgdb
//
//  Created by Alex Carter on 5/16/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import "BLLDebugWindowController.h"

@implementation BLLDebugWindowController
@synthesize debugInfo=_debugInfo;

+(void) updateValue:(NSString*)value forKey:(NSString*)key
{
    [[self sharedInstance] setValue:value forKey:key];
}

+(id) sharedInstance
{
    static BLLDebugWindowController* s_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_sharedInstance = [[BLLDebugWindowController alloc] initWithWindowNibName:@"BLLDebugWindow"];
        [s_sharedInstance showWindow:nil];
    });
    return s_sharedInstance;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

-(NSMutableDictionary*) debugInfo
{
    if(_debugInfo == nil)
    {
        _debugInfo = [NSMutableDictionary dictionary];
    }
    return _debugInfo;
}


-(void) setValue:(id) value forKey:(NSString*)key
{
    [self willChangeValueForKey:@"debugInfo"];
    [_debugInfo setValue:value forKey:key];
    [self didChangeValueForKey:@"debugInfo"];
}

@end
