//
//  DTCControlPoint.m
//  DragonTrajectoryCreator
//
//  Created by Moritz Wittenhagen on 21.03.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "DTCControlPoint.h"
#import <AVFoundation/AVFoundation.h>

@implementation DTCControlPoint
{
	CMTime time;
	
	//normalized coordinates
	CGPoint location;
	CGPoint leftHandleOffset;
	CGPoint rightHandleOffset;
	BOOL	selected;
	BOOL	expanded;	
}

@synthesize time;
@synthesize location;
@synthesize leftHandleOffset;
@synthesize rightHandleOffset;
@synthesize selected;
@synthesize expanded;


+(NSComparator)timeComparison;
{
	return ^NSComparisonResult(DTCControlPoint *obj1, DTCControlPoint *obj2) 
	{
		return CMTimeCompare(obj1.time, obj2.time);
	};

}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super init]) 
	{
		self.time				= [aDecoder decodeCMTimeForKey:@"time"];
		self.location			= NSPointToCGPoint([aDecoder decodePointForKey:@"location"]);
		self.leftHandleOffset	= NSPointToCGPoint([aDecoder decodePointForKey:@"leftHandleOffset"]);
		self.rightHandleOffset	= NSPointToCGPoint([aDecoder decodePointForKey:@"rightHandleOffset"]);
		self.selected			= [aDecoder decodeBoolForKey:@"selected"];
		self.expanded			= [aDecoder decodeBoolForKey:@"expanded"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeCMTime:self.time forKey:@"time"];
	[aCoder encodePoint:NSPointFromCGPoint(self.location) forKey:@"location"];
	[aCoder encodePoint:NSPointFromCGPoint(self.leftHandleOffset) forKey:@"leftHandleOffset"];
	[aCoder encodePoint:NSPointFromCGPoint(self.rightHandleOffset) forKey:@"rightHandleOffset"];
	[aCoder encodeBool:self.selected forKey:@"selected"];
	[aCoder encodeBool:self.expanded forKey:@"expanded"];
}

-(id)copyWithZone:(NSZone *)zone
{	
	DTCControlPoint *copy = [[DTCControlPoint alloc] init];
	copy.time = self.time;
	copy.location = self.location;
	copy.leftHandleOffset = self.leftHandleOffset;
	copy.rightHandleOffset = self.rightHandleOffset;
	copy.selected = self.selected;
	copy.expanded = self.expanded;
	
	return copy;
}

-(BOOL)isEqual:(DTCControlPoint *)other
{
	return CMTimeCompare(self.time, other.time) == NSOrderedSame;
}

-(NSUInteger)hash
{
	return self.time.value;
}

-(NSString *)description
{
	return (NSString *)CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, self.time));
}

@end
