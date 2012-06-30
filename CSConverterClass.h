//
//  ConverterClass.h
//  CSExperiment
//
//  Created by Andreas Nett on 05.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSConverterClass : NSObject
{
    NSInteger   maxInput;
}

@property (nonatomic) NSInteger maxInput;

-(id)init;
-(id)initWithMaxInput:(NSInteger)max;
-(double)convert:(NSInteger)input;




@end
