//
//  CSVisBox.h
//  CSExperiment
//
//  Created by Andreas Nett on 06.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "CSVisClass.h"

@interface CSVisBox : CSVisClass
{
    NSInteger length;
    NSInteger vMiddle;
	NSInteger leftOffset;
    NSRect sliderOutlineRect;
    NSBezierPath *targetArrow;
    NSRect indicatorRect;
    NSColor *sliderBackgroundColor;
    NSColor *targetArrowColor;
    NSColor *indicatorColor;
}


- (id)initWithConverter:(CSConverterClass *)theConverter
				   logs:(NSMutableString *)theLogs
           instructions:(NSMutableString *)theInstructions
                   view:(NSBox *)theView
               delegate:(id)theDelegate
                 target:(double)theTarget
                 length:(int)theLength;

@end
