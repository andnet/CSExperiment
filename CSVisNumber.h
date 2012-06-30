//
//  CSVisNumber.h
//  CSExperiment
//
//  Created by Andreas Nett on 10.06.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "CSVisClass.h"

@interface CSVisNumber : CSVisClass


@property (assign) NSInteger length;
@property (strong) NSString *indicatorText;
@property (strong) NSString *targetText;
@property (assign) NSRect targetRect;
@property (assign) NSRect indicatorRect;
@property (assign) NSColor *targetColor;
@property (assign) NSColor *indicatorColor;
@property (assign) NSFont *font;
@property (strong) NSDictionary *targetAttributes;
@property (strong) NSDictionary *indicatorAttributes;
@property (strong) NSAttributedString *attributedText;
@property (assign) CGSize size;
@property (assign) CGFloat x_pos;
@property (assign) CGFloat y_pos;



- (id)initWithConverter:(CSConverterClass *)theConverter
				   logs:(NSMutableString *)theLogs
           instructions:(NSMutableString *)theInstructions
                   view:(NSBox *)theView
               delegate:(id)theDelegate
                 target:(double)theTarget
                 length:(int)theLength;


@end
