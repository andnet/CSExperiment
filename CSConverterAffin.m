//
//  CSConverterAffin.m
//  CSExperiment
//
//  Created by Andreas Nett on 11.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSConverterAffin.h"

@implementation CSConverterAffin

@synthesize scalar, summand;


-(id)init
{
	self = [super initWithMaxInput:999];
	[self setScalar:1.0];
	[self setSummand:0.0];
	return self;
}


-(id)initWithMaxInput:(NSInteger)max
{
	self = [super initWithMaxInput:max];
	[self setScalar:1.0];
	[self setSummand:0.0];
	return self;
}

-(id)initWithScalar:(double)theScalar summand:(double)theSummand
{
	self = [super initWithMaxInput:999];
	[self setScalar:theScalar];
	[self setSummand:theSummand];
	return self;
}


-(id)initWithMaxInput:(NSInteger)max scalar:(double)theScalar summand:(double)theSummand
{
	self = [super initWithMaxInput:max];
	[self setScalar:theScalar];
	[self setSummand:theSummand];
	return self;
}


-(double)convert:(NSInteger)input
{
	double temp = scalar * input + summand;
	temp	= (temp <= 999 ? temp : 999); 
	double output = (temp / (double)maxInput) * 100;
	// NSLog(@"+++ Converter: in: \t %ld \t temp: %f \t out: %f", input, temp, output);
    return output;
}


@end
