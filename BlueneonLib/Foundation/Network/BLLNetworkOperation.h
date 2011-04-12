//
//  BLLDownloadOperation.h
//  Feed
//
//  Created by Alex Carter on 10-05-16.
//
//  Copyright 2011 Alex Carter. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of
//  conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list
//  of conditions and the following disclaimer in the documentation and/or other materials
//  provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Alex Carter.
//

#import <Foundation/Foundation.h>
#import "BLLDataProcessorProtocol.h"
#import "BLLErrorHandlerProtocol.h"

extern NSString* const kBLLNetworkOperationDidFinishNotification;
extern NSString* const kBLLNetworkOperationDidFailNotification;
extern NSString* const kBLLNetworkOperationErrorDomain;
extern NSUInteger const kErrorCouldNotCreateConnnection;
extern NSUInteger const kErrorCouldNotInitializeDataProcessor;
extern NSUInteger const kErrorDataProcessingFailed;
extern NSUInteger const kErrorCouldNotFinalizeDataProcessing;
extern NSUInteger const kErrorCouldNotResetDataProcessor;

@interface BLLNetworkOperation : NSOperation {

	BOOL executing;
	BOOL finished;
	
	NSURLConnection* URLConnection;
	NSURLRequest* URLRequest;
	NSURLResponse* URLResponse;
	NSError* downloadError;
	id<BLLDataProcessorProtocol> dataProcessor;
	id<BLLErrorHandlerProtocol> errorHandler;
	id context;
}
@property (nonatomic, retain) NSURLRequest* URLRequest;
@property (nonatomic, retain) NSURLResponse* URLResponse;
@property (nonatomic, retain) NSError* downloadError;
@property (nonatomic, retain) id<BLLDataProcessorProtocol> dataProcessor;
@property (nonatomic, retain) id<BLLErrorHandlerProtocol> errorHandler;
@property (nonatomic, readonly, retain) id download;
@property (nonatomic, retain) id context;


+(id) networkOperationWithURLRequest:(NSURLRequest*) aURLRequest;
+(id) networkOperationWithURLRequest:(NSURLRequest*) aURLRequest toFilePath:(NSString*) path;
+(id) networkOperationWithURLRequest:(NSURLRequest*) aURLRequest dataProcessor:(id <BLLDataProcessorProtocol>) aDataProcessor;

- (id) initWithURLRequest:(NSURLRequest*) aURLRequest;
-(id) initWithURLRequest:(NSURLRequest *)aURLRequest dataProcessor:(id <BLLDataProcessorProtocol>) aDataProcessor;
@end
