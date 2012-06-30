//
//  CSVisNumber.m
//  CSExperiment
//
//  Created by Andreas Nett on 10.06.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "CSVisNumber.h"

@implementation CSVisNumber

@synthesize length;
@synthesize indicatorText;
@synthesize targetText;
@synthesize targetRect;
@synthesize indicatorRect;
@synthesize targetColor;
@synthesize indicatorColor;
@synthesize font;
@synthesize targetAttributes;
@synthesize indicatorAttributes;
@synthesize attributedText;
@synthesize size;
@synthesize x_pos;
@synthesize y_pos;


- (id)initWithConverter:(CSConverterClass *)theConverter
				   logs:(NSMutableString *)theLogs
           instructions:(NSMutableString *)theInstructions
                   view:(NSBox *)theView
               delegate:(id)theDelegate
                 target:(double)theTarget
                 length:(int)theLength
{
    self	= [super initWithConverter:theConverter logs:theLogs instructions:theInstructions view:theView delegate:theDelegate target:theTarget];
	length	= theLength;

	targetText		= [[NSString alloc] initWithFormat:@"Goal: %d", (int)((length / 100) * theTarget)];
	indicatorText	= [[NSString alloc] initWithString:@"0"];
	
	indicatorRect	= NSMakeRect(([self.parent bounds].size.width / 2 - 30), ([self.parent bounds].size.height - 200), 60, 50);
	targetRect		= NSMakeRect(([self.parent bounds].size.width / 2 - 30), ([self.parent bounds].size.height - 300), 60, 50);
	
	font = [NSFont  fontWithName:@"Helvetica Bold" size:30];
	targetColor		= [NSColor colorWithSRGBRed:0.4 green:0.4 blue:0.4 alpha:1.0];
	indicatorColor	= [NSColor colorWithSRGBRed:0.2 green:0.2 blue:0.2 alpha:1.0];
	targetAttributes	= [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, targetColor, NSForegroundColorAttributeName, nil];
	indicatorAttributes	= [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, indicatorColor, NSForegroundColorAttributeName, nil];	
		
	return self;
}
	


- (void)drawRect:(NSRect)dirtyRect
{
	
	if (self.isNulled)
	{
		// Update position indicator string
		indicatorText = [NSString stringWithFormat:@"%d", (int)((length / 100) * self.position)];
	}
	else
	{
		// Do not visualize current value
		indicatorText = [NSString stringWithString:@"please null slider"];
	}
	

	// Indicator drawing:
	// ...calculate size for centering
	attributedText = [[NSAttributedString alloc] initWithString:indicatorText attributes: indicatorAttributes];
	size = [attributedText size];  
	x_pos = (indicatorRect.size.width - size.width) / 2; 
	y_pos = (indicatorRect.size.height - size.height) /2; 
	// ...drawing
	[indicatorText drawAtPoint:CGPointMake(indicatorRect.origin.x + x_pos, indicatorRect.origin.y + y_pos) withAttributes:indicatorAttributes];

	
	// Target drawing:
	// ...calculate size for centering
	attributedText = [[NSAttributedString alloc] initWithString:targetText attributes: targetAttributes];
	size = [attributedText size];  
	x_pos = (indicatorRect.size.width - size.width) / 2; 
	y_pos = (indicatorRect.size.height - size.height) /2; 
	// ...drawing

	[targetText drawAtPoint:CGPointMake(indicatorRect.origin.x + x_pos, targetRect.origin.y + y_pos) withAttributes:targetAttributes];

	
	
}

@end
