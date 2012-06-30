//
//  CSVisBox.h
//  CSExperiment
//
//  Created by Andreas Nett on 06.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "CSVisClass.h"

@interface CSVisTestblink : CSVisClass


@property (assign) NSColor *gray;
@property (assign) NSColor *white;
@property (assign) NSColor *black;
@property (assign) NSRect indicatorRect;




- (id)initWithConverter:(CSConverterClass *)theConverter
				   logs:(NSMutableString *)theLogs
           instructions:(NSMutableString *)theInstructions
                   view:(NSBox *)theView
               delegate:(id)theDelegate
                 target:(double)theTarget;

@end
