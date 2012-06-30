//
//  CSConverterDiscontinuity.m
//  CSExperiment
//
//  Created by Andreas Nett on 19.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSConverterDiscontinuity.h"


@implementation CSConverterDiscontinuity

@synthesize hwStartOfDisc;	// set by user
@synthesize hwLengthOfDisc;	// set by user
@synthesize hwEffectiveLength;
@synthesize visSpeedupFactor;
@synthesize visWaitPos;
@synthesize visOffsetAfterWait;


-(id)initWithMaxInput:(NSInteger)max hwStartOfDis:(NSInteger)theHwStartOfDisc  hwLengthOfDisc:(NSInteger)theHwLengthOfDisc
{
	self = [super initWithMaxInput:max+1];
	[self setHwStartOfDisc:theHwStartOfDisc];
	[self setHwLengthOfDisc:theHwLengthOfDisc];
	// Calculate dependend values:
	[self setHwEffectiveLength:(maxInput - hwLengthOfDisc)];
	[self setVisSpeedupFactor:((double)maxInput / (double)hwEffectiveLength)];
	[self setVisWaitPos:[self convert:hwStartOfDisc]];
	// TRASH  [self setVisOffsetAfterWait:(  ((hwStartOfDisc + hwLengthOfDisc) / maxInput) * 100 ) - visWaitPos];
	[self setVisOffsetAfterWait:[self convert:(hwStartOfDisc+hwLengthOfDisc)] - visWaitPos ];
	NSLog(@"+++ CSConverterDiscontinuity params: start: %ld length: %ld effective: %ld speedup: %f waitPos: %f offset: %f", hwStartOfDisc, hwLengthOfDisc, hwEffectiveLength, visSpeedupFactor, visWaitPos, visOffsetAfterWait);
	
	return self;
}


-(id)initWithHwStartOfDis:(NSInteger)theHwStartOfDisc  hwLengthOfDisc:(NSInteger)theHwLengthOfDisc
{
	self = [self initWithMaxInput:999
			   hwStartOfDis:theHwStartOfDisc
			 hwLengthOfDisc:theHwLengthOfDisc];
	return self;
}


-(id)init
{
	self = [self initWithHwStartOfDis:400 hwLengthOfDisc:200];
	return self;
}


-(double)convert:(NSInteger)input
{
	double output = 0;
	if (input <= hwStartOfDisc)
	{
		output = (((double)input / (double)maxInput)) * 100 * visSpeedupFactor;
		NSLog(@"+++ DISC: %ld is %f, \t before", input, output);
	}
	else if (hwStartOfDisc < input && input  < hwStartOfDisc + hwLengthOfDisc)
	{
		output = visWaitPos;
		NSLog(@"+++ DISC: %ld is %f, \t WAIT", input, output);
	}
	else
	{
		output = (((double)input / (double)maxInput)) * 100 * visSpeedupFactor - visOffsetAfterWait;
			NSLog(@"+++ DISC: %ld is %f, \t after", input, output);
	}

    return output;
}




@end