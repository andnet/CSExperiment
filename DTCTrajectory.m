//
//  DTCTrajectory.m
//  DragonTrajectoryCreator
//
//  Created by Moritz Wittenhagen on 22.03.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "DTCTrajectory.h"
#import "DTCControlPoint.h"
#import "ThoCGGeometryUtilities.h"

@interface DTCTrajectory ()
-(CGPoint)evaluateBezierForLeftCP:(DTCControlPoint *)leftCP rightCP:(DTCControlPoint *)rightCP at:(double)t;
@end

@implementation DTCTrajectory
{
	NSMutableArray *controlPoints;
}

@synthesize controlPoints;

- (id)init
{
    self = [super init];
    if (self) {
        controlPoints = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        controlPoints = [coder decodeObject];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:controlPoints];
}

-(void)addControlPoint:(DTCControlPoint *)controlPoint;
{
	[controlPoints addObject:controlPoint];
	[controlPoints sortUsingComparator:[DTCControlPoint timeComparison]];
}


-(void)removeControlPoint:(DTCControlPoint *)controlPoint
{
	[controlPoints removeObject:controlPoint];
}


-(NSUInteger)count
{
	return [controlPoints count];
}


-(void)expandControlPoints:(BOOL)shouldExpand
{
	[controlPoints enumerateObjectsUsingBlock:^(DTCControlPoint *cp, NSUInteger idx, BOOL *stop) 
	{
		cp.expanded = shouldExpand;
	}];
}


-(BOOL)containsTime:(CMTime)theTime
{
	if([self count] < 2)
		return NO;
	
	DTCControlPoint *firstCP = [controlPoints objectAtIndex:0];
	DTCControlPoint *lastCP  = [controlPoints lastObject];
	CMTimeRange coveredTime = CMTimeRangeMake(firstCP.time, CMTimeSubtract(lastCP.time, firstCP.time));
	
	return CMTimeRangeContainsTime(coveredTime, theTime);
}


-(CGPoint)positionForTime:(CMTime)theTime;
{
	if(![self containsTime:theTime])
		return CGPointInvalid;
	
	__block DTCControlPoint *leftCP;
	__block DTCControlPoint *rightCP;
	
	[controlPoints enumerateObjectsUsingBlock:^(DTCControlPoint *obj, NSUInteger idx, BOOL *stop) 
	{
		 leftCP = obj;
		 rightCP  = [controlPoints objectAtIndex:idx + 1];
		 CMTimeRange coveredTime = CMTimeRangeMake(leftCP.time, CMTimeSubtract(rightCP.time, leftCP.time));
		 
		 BOOL timeIsCoveredBySegment = CMTimeRangeContainsTime(coveredTime, theTime);
		 
		 *stop = timeIsCoveredBySegment;
	}];
	
	CMTime timeIntoSegment = CMTimeSubtract(theTime, leftCP.time);
	CMTime segmentDuration = CMTimeSubtract(rightCP.time, leftCP.time);
	
	double t = CMTimeGetSeconds(timeIntoSegment) / CMTimeGetSeconds(segmentDuration);
	
	return [self evaluateBezierForLeftCP:leftCP rightCP:rightCP at:t];

}


-(DTCControlPoint *)findControlPointForTime:(CMTime)theTime
{
	DTCControlPoint *fakeCP = [[DTCControlPoint alloc] init];
	
	fakeCP.time = theTime;
	
	NSUInteger index = [controlPoints indexOfObject:fakeCP inSortedRange:NSMakeRange(0, [controlPoints count]) options:NSBinarySearchingFirstEqual usingComparator:[DTCControlPoint timeComparison]];
	
	
	if(index != NSNotFound)
	{
		return [controlPoints objectAtIndex:index];
	}
	else 
	{
		return nil;		
	}
}


-(CGPoint)evaluateBezierForLeftCP:(DTCControlPoint *)leftCP rightCP:(DTCControlPoint *)rightCP at:(double)t;
{
	// de Casteljeau
	NSParameterAssert(0.0 <= t && t <= 1.0);
	
	double T = 1.0 - t;
	CGPoint P0 = leftCP.location;
	CGPoint P1 = CGPointAdd(P0, leftCP.rightHandleOffset);
	CGPoint P3 = rightCP.location;
	CGPoint P2 = CGPointAdd(P3, rightCP.leftHandleOffset);
	
	// Step 0
	CGPoint c00 = CGPointMake( T * P0.x + t * P1.x, T * P0.y + t * P1.y );
	CGPoint c01 = CGPointMake( T * P1.x + t * P2.x, T * P1.y + t * P2.y );
	CGPoint c02 = CGPointMake( T * P2.x + t * P3.x, T * P2.y + t * P3.y );
	
	// Step 1
	CGPoint c10 = CGPointMake( T * c00.x + t * c01.x, T * c00.y + t * c01.y );
	CGPoint c11 = CGPointMake( T * c01.x + t * c02.x, T * c01.y + t * c02.y );
	
	// Step 2
	CGPoint c20 = CGPointMake( T * c10.x + t * c11.x, T * c10.y + t * c11.y );
	
	return c20;
}

-(CGPathRef)createPath;
{
	CGMutablePathRef path = CGPathCreateMutable();
	
	DTCControlPoint *firstCP = [controlPoints objectAtIndex:0];
	CGPathMoveToPoint(path, NULL, firstCP.location.x, firstCP.location.y);
	
	
	for(int i = 1; i < [self count]; i++)
	{
		DTCControlPoint *leftCP = [controlPoints objectAtIndex:i -1];
		DTCControlPoint *rightCP = [controlPoints objectAtIndex:i];
		
		CGPoint rightHandleLocation = CGPointAdd(leftCP.location, leftCP.rightHandleOffset);
		CGPoint leftHandleLocation = CGPointAdd(rightCP.location, rightCP.leftHandleOffset);
		
		CGPathAddCurveToPoint(path, NULL, 
							  rightHandleLocation.x, rightHandleLocation.y, 
							  leftHandleLocation.x, leftHandleLocation.y, 
							  rightCP.location.x, rightCP.location.y);
	}
	
	return path;
	
}


@end
