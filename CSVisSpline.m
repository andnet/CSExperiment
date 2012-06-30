//
//  CSVisSpline.m
//  CSExperiment
//
//  Created by Andreas Nett on 16.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "CSVisSpline.h"
#import "DTCTrajectory.h"
#import "DTCControlPoint.h"
#import "ThoCGGeometryUtilities.h"

@implementation CSVisSpline

@synthesize trajectory;

- (id)initWithConverter:(CSConverterClass *)theConverter logs:(NSMutableString *)theLogs instructions:(NSMutableString *)theInstructions view:(NSBox *)theView delegate:(id)theDelegate target:(float)theTarget trajectory:(DTCTrajectory *)theTrajectory;
{
    self = [super initWithConverter:theConverter logs:theLogs instructions:theInstructions view:theView delegate:theDelegate target:theTarget];
    
    if (self) 
    {
        CGColorRef indicatorStrokeColor		= CGColorCreateGenericGray(0.2, 1.0);// TODO tune
        CGColorRef indicatorFillColor		= indicatorStrokeColor;// TODO tune
		
		CGColorRef targetStrokeColor		= CGColorCreateGenericGray(0.5, 0.5);// TODO tune
        CGColorRef targetFillColor			= targetStrokeColor;// TODO tune
		
        CGColorRef clearColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.0);// TODO tune
		
		NSMutableDictionary *layerActionsWithDisabledMovementAnimation = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"position"];
		
        trajectoryLayer = [CAShapeLayer layer];
        trajectoryLayer.lineWidth = 3; // TODO tune
        trajectoryLayer.strokeColor = indicatorStrokeColor;
		trajectoryLayer.fillColor = clearColor;
		trajectoryLayer.actions = layerActionsWithDisabledMovementAnimation;
        
        wiperLayer = [CAShapeLayer layer];
        wiperLayer.lineWidth = 3; // TODO tune
        wiperLayer.strokeColor = indicatorStrokeColor;
        wiperLayer.fillColor = indicatorFillColor;
		wiperLayer.actions = layerActionsWithDisabledMovementAnimation;
		CGPathRef wiperPath = CGPathCreateWithEllipseInRect(CGRectMake(-7, -7, 14, 14), NULL);
		wiperLayer.path = wiperPath;
		wiperLayer.anchorPoint = CGPointMake(0.5, 0.5);
		CGPathRelease(wiperPath);
        
		// target area
		targetLayer = [CAShapeLayer layer];
		targetLayer.lineWidth = 3; // TODO tune
        targetLayer.strokeColor = targetStrokeColor;
        targetLayer.fillColor = targetFillColor;
		targetLayer.actions = layerActionsWithDisabledMovementAnimation;
		CGPathRef targetPath = CGPathCreateWithEllipseInRect(CGRectMake(-14, -14, 28, 28), NULL);
		targetLayer.path = targetPath;
		targetLayer.anchorPoint = CGPointMake(0.5, 0.5);
		CGPathRelease(targetPath);
		
		
        [self setWantsLayer:YES];
        [[self layer] addSublayer:trajectoryLayer];
        [[self layer] addSublayer:wiperLayer];
		[[self layer] addSublayer:targetLayer];
		
		CGColorRelease(indicatorStrokeColor);
		CGColorRelease(indicatorFillColor);
		CGColorRelease(clearColor);
		
		self.trajectory = theTrajectory;
		
		// scale the uniform coords to view bounds
		CGAffineTransform scaleTransform = CGAffineTransformMakeScale([self bounds].size.width, [self bounds].size.height);
		
		normalizedPath = [self.trajectory createPath];
		CGPathRef path = CGPathCreateCopyByTransformingPath(normalizedPath, &scaleTransform);
		
		[trajectoryLayer setPath:path];
		
		CGPathRelease(path);
    }
    
    return self;
   
}

- (void)makeActive
{
    [super makeActive];
    
	// scale the uniform coords to view bounds
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale([self bounds].size.width, [self bounds].size.height);
	
	CGPathRef path = CGPathCreateCopyByTransformingPath(normalizedPath, &scaleTransform);
	
	[trajectoryLayer setPath:path];
	
	CGPathRelease(path);
}

- (void)updateWithNewPercent:(double)newPercent mbedTimestamp:(NSInteger)mbedTimestamp
{
	[super updateWithNewPercent:newPercent mbedTimestamp:mbedTimestamp];
	
	// convert position to time
	DTCControlPoint *first = [self.trajectory.controlPoints objectAtIndex:0];
	DTCControlPoint *last = [self.trajectory.controlPoints lastObject];
	CMTime start = first.time;
	CMTime end = last.time;
	CMTime duration = CMTimeSubtract(end, start);
	CMTime currTime = CMTimeAdd(CMTimeMultiplyByFloat64(duration, newPercent/100.0), start);
	
	// draw target area
	NSLog(@"p=%f \t t=%f", self.position, self.target);
	CMTime targetTime = CMTimeAdd(CMTimeMultiplyByFloat64(duration, self.target/100.0), start);
	CGPoint targetPosition = [self.trajectory positionForTime:targetTime];
	targetPosition = CGPoint2DScale(targetPosition, [self bounds].size);
	targetLayer.position = targetPosition;
	targetLayer.hidden = NO;
	
	// check if the current time is covered by the path
	// if yes, draw a marker on the path to visualize the position in time
	BOOL timeIsConveredByTrajectory = [self.trajectory containsTime:currTime];
	if(timeIsConveredByTrajectory)
	{
		CGPoint wiperPosition = [self.trajectory positionForTime:currTime];
		wiperPosition = CGPoint2DScale(wiperPosition, [self bounds].size);
		
		wiperLayer.position = wiperPosition;		
		wiperLayer.hidden = NO;
	}
	else
	{
		wiperLayer.hidden = YES;
	}

}


@end
