//
//  CSConverterDiscontinuity.h
//  CSExperiment
//
//  Created by Andreas Nett on 19.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSConverterClass.h"

@interface CSConverterDiscontinuity : CSConverterClass
{
	
}


@property (nonatomic) NSInteger hwStartOfDisc;	// set by user
@property (nonatomic) NSInteger hwLengthOfDisc;	// set by user
@property (nonatomic) NSInteger hwEffectiveLength;
@property (nonatomic) double	visSpeedupFactor;
@property (nonatomic) double	visWaitPos;
@property (nonatomic) double	visOffsetAfterWait;






-(id)initWithMaxInput:(NSInteger)max hwStartOfDis:(NSInteger)theHwStartOfDisc  hwLengthOfDisc:(NSInteger)theHwLengthOfDisc;
-(id)initWithHwStartOfDis:(NSInteger)theHwStartOfDisc  hwLengthOfDisc:(NSInteger)theHwLengthOfDisc;
-(id)init;

-(double)convert:(NSInteger)input;




@end

