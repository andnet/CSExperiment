//
//  ThoCGGeometryUtilities.h
//  DRAGimationClient
//
//  Created by Thorsten Karrer on 17.8.11.
//  Copyright 2011 Media Computing Group, RWTH Aachen University. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef CGPoint CGVector;

extern const CGPoint	CGPointInvalid;
extern const CGVector	CGVectorInvalid;

extern Float64	CGVectorScalarProduct(const CGVector A, const CGVector B);
extern Float64	CGVectorLength(const CGVector A);

extern Float64	CGPointDistance(const CGPoint A, const CGPoint B);

extern CGVector CGPointSubtract(const CGPoint A, const CGPoint B);
extern CGVector CGVectorSubtract(const CGVector A, const CGVector B);

extern CGPoint	CGPointAdd(const CGPoint A, const CGVector B);
extern CGVector	CGVectorAdd(const CGVector A, const CGVector B);

extern CGPoint	CGPoint2DScale(const CGPoint a, const CGSize s);
extern CGVector CGVector2DScale(const CGVector a, const CGSize s);
extern CGPoint	CGPoint2DScaleInverse(const CGPoint a, const CGSize s);
extern CGVector CGVector2DScaleInverse(const CGVector a, const CGSize s);


extern CGVector CGVectorNormalize(const CGVector A);

extern CGPoint	CGPointScale(const CGPoint A, const Float64 s);
extern CGVector CGVectorScale(const CGVector A, const Float64 s);

extern CGVector CGVectorRotate270(const CGVector A);

