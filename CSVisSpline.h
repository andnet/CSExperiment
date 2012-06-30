//
//  CSVisSpline.h
//  CSExperiment
//
//  Created by Andreas Nett on 16.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "CSVisClass.h"
#import <QuartzCore/QuartzCore.h>

@class DTCTrajectory;
@class CSConverterClass;

@interface CSVisSpline : CSVisClass 
{
    DTCTrajectory *trajectory;
    CAShapeLayer *trajectoryLayer;
    CAShapeLayer *wiperLayer;
	CAShapeLayer *targetLayer;
	
	CGPathRef normalizedPath;
}

@property (strong) DTCTrajectory *trajectory;

- (id)initWithConverter:(CSConverterClass *)theConverter logs:(NSMutableString *)theLogs instructions:(NSMutableString *)theInstructions view:(NSBox *)theView delegate:(id)theDelegate target:(float)theTarget trajectory:(DTCTrajectory *)theTrajectory;


@end
