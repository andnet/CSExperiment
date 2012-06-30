//
//  VisClass.h
//  CSExperiment
//
//  Created by Andreas Nett on 05.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDCocoaAsyncUdpSocket/GCDAsyncUdpSocket.h"

@class CSConverterClass;


@protocol CSAppDelegate
- (void)updateDebugPosField:(double)newPos;
- (void)updateTodoFieldWithString:(NSString *)newString;
- (void)setAcceptNextTaskCommand:(BOOL)newValue;
- (BOOL)waitingForModalAlert;
@end

@interface CSVisClass : NSView <GCDAsyncUdpSocketDelegate>


// General properties:
@property (strong) CSConverterClass *converter;
@property (strong) NSMutableString *logs;
@property (strong) NSMutableString *instructions;
@property (strong) NSBox *parent;
@property (weak) id<CSAppDelegate> delegate;
@property (assign) double target;
@property (assign) double position;
@property (assign) BOOL isNulled;
@property (assign) BOOL movementHasStarted;
@property (assign) NSInteger movementStartTimeInMbed;
@property (assign) CFAbsoluteTime movementStartTimeInApp;



- (id)initWithConverter:(CSConverterClass *)theConverter
				   logs:(NSMutableString *)theLogs
           instructions:(NSMutableString *)theInstructions
                   view:(NSBox *)theView
               delegate:(id)theDelegate
                 target:(double)theTarget;

- (void)udpSocket   :(GCDAsyncUdpSocket *)sock
      didReceiveData:(NSData *)data
         fromAddress:(NSData *)address
   withFilterContext:(id)filterContext;

- (void)makeActive;
- (void)updateWithNewPercent:(double)newPercent mbedTimestamp:(NSInteger)mbedTimestamp;
- (NSMutableString *)getLogs;




@end
