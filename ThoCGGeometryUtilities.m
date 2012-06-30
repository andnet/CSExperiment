//
//  ThoCGGeometryUtilities.m
//  DRAGimationClient
//
//  Created by Thorsten Karrer on 17.8.11.
//  Copyright 2011 Media Computing Group, RWTH Aachen University. All rights reserved.
//

#import "ThoCGGeometryUtilities.h"
#import <ApplicationServices/ApplicationServices.h>

const CGPoint	CGPointInvalid	= {CGFLOAT_MAX, CGFLOAT_MAX};
const CGVector	CGVectorInvalid = {CGFLOAT_MAX, CGFLOAT_MAX};

Float64	CGVectorScalarProduct(const CGVector A, const CGVector B)
{
	return (A.x * B.x) + (A.y * B.y);
}

Float64	CGVectorLength(const CGVector A)
{
	return sqrt(CGVectorScalarProduct(A, A));
}

Float64 CGPointDistance(CGPoint A, CGPoint B)
{
	return sqrt( ((A.x - B.x) * (A.x - B.x)) + ((A.y - B.y) * (A.y - B.y)));
}


CGVector CGPointSubtract(const CGPoint A, const CGPoint B)
{
	return CGPointMake(A.x - B.x, A.y - B.y);
}

CGVector CGVectorSubtract(const CGVector A, const CGVector B)
{
	return CGPointSubtract(A, B);
}


CGPoint CGPointAdd(const CGPoint A, const CGPoint B)
{
	return CGPointMake(A.x + B.x, A.y + B.y);
}

CGVector	CGVectorAdd(const CGVector A, const CGVector B)
{
	return CGPointAdd(A, B);
}


CGPoint CGPoint2DScale(const CGPoint a, const CGSize s)
{
	return CGPointMake(a.x * s.width, a.y * s.height);
}

CGVector CGVector2DScale(const CGVector a, const CGSize s)
{
	return CGPoint2DScale(a, s);
}

CGPoint	CGPoint2DScaleInverse(const CGPoint a, const CGSize s)
{
	return CGPointMake(a.x / s.width, a.y / s.height);
}

CGVector CGVector2DScaleInverse(const CGVector a, const CGSize s)
{
	return CGPoint2DScaleInverse(a, s);
}


CGVector CGVectorNormalize(const CGVector A)
{
	Float64 l = CGVectorLength(A);
	return CGVectorScale(A, 1.0/l);
}


CGPoint CGPointScale(const CGPoint A, const Float64 s)
{
	return CGPointMake(A.x * s, A.y * s);
}

CGVector CGVectorScale(const CGVector A, const Float64 s)
{
	return CGPointScale(A, s);
}


extern CGVector CGVectorRotate270(const CGVector A)
{
	return CGPointMake(A.y, -A.x);
}