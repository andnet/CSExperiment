//
//  VisClass.m
//  CSExperiment
//
//  Created by Andreas Nett on 05.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "CSVisClass.h"
#import "CSConverterClass.h"


@implementation CSVisClass

@synthesize converter;
@synthesize logs;
@synthesize instructions;
@synthesize parent;
@synthesize delegate;
@synthesize target;
@synthesize position;
@synthesize isNulled;
@synthesize movementHasStarted;
@synthesize movementStartTimeInMbed;
@synthesize movementStartTimeInApp;



-(id) initWithConverter:(CSConverterClass *)theConverter
                   logs:(NSMutableString *)theLogs
           instructions:(NSMutableString *)theInstructions
                   view:(NSBox *)theView
               delegate:(id)theDelegate
                 target:(double)theTarget;
{
    self = [super init];
    if (self) {
        
        BOOL paramcheck = YES;
        
        if (!paramcheck) {
            return nil;
        }
        
        self.converter = theConverter;
        self.logs = theLogs;
        self.instructions = theInstructions;
        self.parent = theView;
        self.delegate = theDelegate;
        self.target = theTarget;

    }
    return self;
}

-(id) init {
    return [self initWithConverter:nil logs:nil instructions:nil view:nil delegate:nil target:0];

}


/* Delegate method for GCDAsyncUdpSocket, handles data receiving.
 * NSData payload contains a 13 byte char[].
 * First 3 bytes are "000"-"999" for slider position
 * Last 10 bytes are "0000000000" for a milisecond timestamp created inside the mbed. */
- (void)udpSocket   :(GCDAsyncUdpSocket *)sock
      didReceiveData:(NSData *)payload
         fromAddress:(NSData *)address
   withFilterContext:(id) filterContext
{	
	// Unpack the NSData object payload
	NSRange posRange = NSMakeRange(0, 3);
	NSRange timeRange = NSMakeRange(3, 10);
	char posMsg[4];
    char timeMsg[11];
	[payload getBytes:posMsg range:posRange];
	[payload getBytes:timeMsg range:timeRange];
	// Convert the char[] to NSInteger 
	NSInteger pos = atoi(posMsg);
	NSInteger time = atoi(timeMsg);
	// NSLog(@"UDP Socket incoming pos: \t %ld", pos);
    [self updateWithNewPercent:[converter convert:pos] mbedTimestamp:time];
}

/* This method is called by CSAppDelegate when the CSVisClass becomes thet current CSVisClass.
 * "Parent"
 * */
-(void) makeActive
{
    [parent setContentView:self];
	[self setNeedsDisplay:YES];

	
	
    isNulled = NO;
    movementHasStarted = NO;
}


/*	After a UDP packet arrived, and the position and mbed-time have been extracted,
 *	this method contains the logic what to do with the data.
 *	Logging of experimental data takes place after the user nulled the slider and initiated the movement. */
-(void) updateWithNewPercent:(double)newPercent mbedTimestamp:(NSInteger)mbedTimestamp
{

	// NSLog(@"alert: %d \t nulled: %d", [delegate waitingForModalAlert], isNulled);
	if ([delegate waitingForModalAlert])
	{
		// USER HAS TO DISMISS THE DAMN ALERT!!!!!111
	}
	else
	{
		// Wait for slider to be nulled. Then enable isNulled.
		if (!isNulled)
		{
			[delegate updateTodoFieldWithString:@"Please move slider to zero position and begin task."];
			if (newPercent <= 0.1) 
			{
				isNulled = YES;
				[delegate updateTodoFieldWithString:@"Please begin task."];
			}
		}
		// After slider is nulled, wait for movement to start.
		// Until then, do not log, and keep track of timestamp to know the starting time for the users movement.
		else if (!movementHasStarted)
		{
			if (newPercent >= 1) 
			{
				movementHasStarted = YES;
				[delegate setAcceptNextTaskCommand:YES];
				// Note the starting values for time in the application and time sent by the mbed.
				movementStartTimeInApp = CFAbsoluteTimeGetCurrent();
				movementStartTimeInMbed = mbedTimestamp;
			}
		}
		else
		{
			// append local and mbed timestamp as well as position to task log
			[logs appendFormat:@"%3.4f \t %ld \t %f  \n", (CFAbsoluteTimeGetCurrent() - movementStartTimeInApp), (mbedTimestamp - movementStartTimeInMbed), newPercent];
		}
		[delegate updateDebugPosField:newPercent];
		position = newPercent;
		[parent setNeedsDisplay:YES];
	}
    
	
	
	
}

- (NSMutableString *)getLogs
{
	return logs;
}


- (void)keyDown:(NSEvent *)theEvent
{
	NSLog(@"Key was pressed!");
}



- (BOOL)isFlipped {
    return YES;
}


@end
