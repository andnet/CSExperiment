//
//  CSVisBox.m
//  CSExperiment
//
//  Created by Andreas Nett on 06.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "CSVisTestblink.h"

@implementation CSVisTestblink

@synthesize white;
@synthesize gray;
@synthesize black;
@synthesize indicatorRect;


- (id)initWithConverter:(CSConverterClass *)theConverter
				   logs:(NSMutableString *)theLogs
           instructions:(NSMutableString *)theInstructions
                   view:(NSBox *)theView
               delegate:(id)theDelegate
                 target:(double)theTarget
{
    self = [super initWithConverter:theConverter logs:theLogs instructions:theInstructions view:theView delegate:theDelegate target:theTarget];

    // define visual elements
	indicatorRect = NSMakeRect(0, 0, 500, 500);
	white = [NSColor whiteColor];
	gray = [NSColor grayColor];
	black = [NSColor blackColor];

    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
	// If position is < 500 then paint black, else white
	if (self.position < 50)
	{
		[black set];
	}
	else
	{
		[white set];
	}

	 NSRectFill(indicatorRect);

	
}




@end
