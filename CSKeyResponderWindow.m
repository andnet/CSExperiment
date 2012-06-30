//
//  CSKeyResponderWindow.m
//  CSExperiment
//
//  Created by Andreas Nett on 29.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "CSKeyResponderWindow.h"
#import "CSAppDelegate.h"

@implementation CSKeyResponderWindow
@synthesize keyResponder;




-(void)keyDown:(NSEvent *)theEvent
{
	NSLog(@"Key pressed!");
	[keyResponder taskCompleteSignal:nil];
}



@end
