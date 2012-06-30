//
//  CSConverterAffin.h
//  CSExperiment
//
//  Created by Andreas Nett on 11.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSConverterClass.h"

@interface CSConverterAffin : CSConverterClass

{
}

@property double scalar;
@property double summand;


-(id)init;
-(id)initWithMaxInput:(NSInteger)max;
-(id)initWithScalar:(double)theScalar summand:(double)theSummand;
-(id)initWithMaxInput:(NSInteger)max scalar:(double)theScalar summand:(double)theSummand;

-(double)convert:(NSInteger)input;

@end
