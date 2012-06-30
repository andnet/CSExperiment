//
//  ConverterClass.m
//  CSExperiment
//
//  Created by Andreas Nett on 05.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "CSConverterClass.h"

@implementation CSConverterClass
    

@synthesize maxInput;

-(id) initWithMaxInput:(NSInteger)max
{
    self = [super init];
    if (self != nil)
    {
        [self setMaxInput:max];
    }
    return self;
}

-(id) init
{
    return [self initWithMaxInput:999];
}



-(double)convert:(NSInteger)input
{
    double output = ((double)input / (double)maxInput) * 100;
    return output;
}


    


@end
