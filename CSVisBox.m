//
//  CSVisBox.m
//  CSExperiment
//
//  Created by Andreas Nett on 06.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "CSVisBox.h"

@implementation CSVisBox

- (id)initWithConverter:(CSConverterClass *)theConverter
				   logs:(NSMutableString *)theLogs
           instructions:(NSMutableString *)theInstructions
                   view:(NSBox *)theView
               delegate:(id)theDelegate
                 target:(double)theTarget
                 length:(int)theLength
{
    self = [super initWithConverter:theConverter logs:theLogs instructions:theInstructions view:theView delegate:theDelegate target:theTarget];
    if (self != nil)
		length = theLength;
    // define visual elements to be drawn later
    vMiddle = [self.parent bounds].size.height / 2;
	
	// define offset of whole drawing from left border of box
	leftOffset = ([self.parent bounds].size.width - length) / 2 ; 
	
	// outline of the slider
	CGFloat sliderOutlineWidth = 30;
    sliderOutlineRect = NSMakeRect(leftOffset, vMiddle - (sliderOutlineWidth / 2), length, sliderOutlineWidth);
	
	// two small arrows pointing to the target on the bar
	CGFloat arrowSize = 12;
    NSPoint up1		= NSMakePoint(leftOffset + (length / 100) * self.target, vMiddle + (sliderOutlineWidth / 2));
    NSPoint up2		= NSMakePoint(leftOffset + (length / 100) * self.target - arrowSize / 3, vMiddle + (sliderOutlineWidth / 2) + arrowSize);
    NSPoint up3		= NSMakePoint(leftOffset + (length / 100) * self.target + arrowSize / 3, vMiddle + (sliderOutlineWidth / 2) + arrowSize);
	NSPoint down1	= NSMakePoint(leftOffset + (length / 100) * self.target, vMiddle - (sliderOutlineWidth / 2));
    NSPoint down2	= NSMakePoint(leftOffset + (length / 100) * self.target - arrowSize / 3, vMiddle - (sliderOutlineWidth / 2) - arrowSize);
    NSPoint down3	= NSMakePoint(leftOffset + (length / 100) * self.target + arrowSize / 3, vMiddle - (sliderOutlineWidth / 2) - arrowSize);
    targetArrow = [NSBezierPath bezierPath];
    [targetArrow moveToPoint:up1];
    [targetArrow lineToPoint:up2];
    [targetArrow lineToPoint:up3];
    [targetArrow lineToPoint:up1];
    [targetArrow moveToPoint:down1];
    [targetArrow lineToPoint:down2];
    [targetArrow lineToPoint:down3];
    [targetArrow lineToPoint:down1];
	
	// the colors for the elements
	sliderBackgroundColor	= [NSColor colorWithSRGBRed:0.7 green:0.7 blue:0.7 alpha:1.0];
	targetArrowColor	= [NSColor colorWithSRGBRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	indicatorColor		= [NSColor colorWithSRGBRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    return self;
}






- (void)drawRect:(NSRect)dirtyRect
{
	    // draw slider background and target area
    [sliderBackgroundColor set];
    [NSBezierPath fillRect: sliderOutlineRect];
	[targetArrowColor set];
    [targetArrow fill];
	
    // the user controlled moving indicator 
    [indicatorColor set];
	CGFloat indicatorWidth = 28;
	
	// the user controlled, moving part
	// (only visible after the slider has been nulled, so the behaviour experience is not given away to the user)
	if (self.isNulled)
	{
		indicatorRect	= NSMakeRect(leftOffset, vMiddle -(indicatorWidth /2), ((length / 100) * self.position), indicatorWidth);
	}
	else
	{
		indicatorRect	= NSMakeRect(leftOffset, 0, 0, 0);
	}
	
	NSRectFill(indicatorRect);
	
}




@end
