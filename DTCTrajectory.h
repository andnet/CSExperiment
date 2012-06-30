//
//  DTCTrajectory.h
//  DragonTrajectoryCreator
//
//  Created by Moritz Wittenhagen on 22.03.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class DTCControlPoint;
@interface DTCTrajectory : NSObject <NSCoding>

-(void)addControlPoint:(DTCControlPoint *)controlPoint;
-(void)removeControlPoint:(DTCControlPoint *)controlPoint;
-(void)expandControlPoints:(BOOL)shouldExpand;
-(NSUInteger)count;

-(DTCControlPoint *)findControlPointForTime:(CMTime)time;

-(BOOL)containsTime:(CMTime)time;
-(CGPoint)positionForTime:(CMTime)theTime;

-(CGPathRef)createPath;

@property (readonly) NSArray *controlPoints;


@end
