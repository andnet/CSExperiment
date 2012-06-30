//
//  DTCControlPoint.h
//  DragonTrajectoryCreator
//
//  Created by Moritz Wittenhagen on 21.03.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface DTCControlPoint : NSObject <NSCopying, NSCoding>

@property (assign) CMTime time;
@property (assign) CGPoint location;
@property (assign) CGPoint leftHandleOffset;
@property (assign) CGPoint rightHandleOffset;
@property (assign) BOOL selected;
@property (assign) BOOL expanded;

+(NSComparator)timeComparison;

@end
