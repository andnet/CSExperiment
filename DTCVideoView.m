//
//  DTCVideoView.m
//  DragonTrajectoryCreator
//
//  Created by Moritz Wittenhagen on 21.03.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "DTCVideoView.h"
#import "DTCControlPoint.h"
#import "DTCControlPointLayer.h"
#import "ThoCGGeometryUtilities.h"
#import "DTCTrajectory.h"
#import "DTCDocument.h"
#import <CoreMedia/CoreMedia.h>

#define kDTCVideoViewPathColorRGBComponents 1.000, 0.502, 0.000, 1.000


typedef enum DTCVideoViewMouseModes
{
	kDTCVideoViewMouseModeNewControlPoint,
	kDTCVideoViewMouseModeMoveControlPoint,
	kDTCVideoViewMouseModeMoveLeftHandle,
	kDTCVideoViewMouseModeMoveRightHandle,
	kDTCVideoViewMouseModeCount	

} DTCVideoViewMouseMode;






@interface DTCVideoView ()
@property (strong, nonatomic) DTCControlPoint *selectedControlPoint;

-(DTCControlPoint *)addControlPoint:(CGPoint)normalizedMovieLocation;
-(void)updatePath;
-(void)updateTrajectoryWiperLayerForTime:(CMTime)theTime;
@end

@implementation DTCVideoView
{
	AVPlayerLayer	*movieLayer;
	AVPlayer		*moviePlayer;	
	
	NSMutableDictionary		*controlPointLayerDict;
	DTCControlPoint			*selectedControlPoint;
	DTCVideoViewMouseMode	mouseMode;
	
	CAShapeLayer			*pathLayer;
	CAShapeLayer			*trajectoryWiperLayer;
	
}

@dynamic playerItem;
@synthesize selectedControlPoint;
@synthesize timelineSlider;
@synthesize document;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{

    }
    
    return self;
}


-(void)awakeFromNib
{
	moviePlayer = [AVPlayer playerWithPlayerItem:nil];
	movieLayer = [AVPlayerLayer playerLayerWithPlayer:moviePlayer];
	movieLayer.frame = [self layer].bounds;
	movieLayer.videoGravity = AVLayerVideoGravityResize;
	

	
	[movieLayer setAutoresizingMask:kCALayerHeightSizable | kCALayerWidthSizable];		 
	[[self layer] addSublayer:movieLayer];
	
	pathLayer = [CAShapeLayer layer];
	
	CGColorRef pathColor = CGColorCreateGenericRGB(kDTCVideoViewPathColorRGBComponents);
	pathLayer.strokeColor = pathColor;
	pathLayer.lineWidth	  = 4;
	pathLayer.fillColor	  = NULL;

	
	[movieLayer addSublayer:pathLayer];
	
	NSMutableDictionary *layerActionsWithDisabledMovementAnimation = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"position"];	
	trajectoryWiperLayer = [CAShapeLayer layer];
	CGColorRef wiperStrokeColor = CGColorCreateGenericRGB(0.631, 0.440, 0.273, 1.000);
	CGRect		wiperPathRect	= CGRectMake(0, 0, 12, 12);
	CGPathRef	wiperPath		= CGPathCreateWithEllipseInRect(wiperPathRect, NULL);
	
	trajectoryWiperLayer.strokeColor	= wiperStrokeColor;
	trajectoryWiperLayer.lineWidth		= 2;
	trajectoryWiperLayer.frame			= wiperPathRect; 
	trajectoryWiperLayer.fillColor		= pathColor;
	trajectoryWiperLayer.path			= wiperPath;
	trajectoryWiperLayer.anchorPoint	= CGPointMake(0.5, 0.5);
	trajectoryWiperLayer.actions		= layerActionsWithDisabledMovementAnimation;
	trajectoryWiperLayer.hidden			= YES;
	
	[movieLayer addSublayer:trajectoryWiperLayer];
	
	CGPathRelease(wiperPath);
	CGColorRelease(pathColor);
	CGColorRelease(wiperStrokeColor);
	
	controlPointLayerDict = [NSMutableDictionary dictionary];
	
	[[self timelineSlider] setNextResponder:self];
	
	

}


-(IBAction)sliderChanged:(id)sender;
{
	double minValue = [(NSSlider *)sender minValue];
	double maxValue = [(NSSlider *)sender maxValue];	
	
	double currentValue = [(NSSlider *)sender doubleValue];
	
	double percentage = (currentValue - minValue) / (maxValue - minValue);
	
	CMTime movieDuration = [[moviePlayer currentItem] duration];
	CMTime dstTime = movieDuration;
	dstTime.value *= percentage;
	
	[moviePlayer seekToTime:dstTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
		[self updateTrajectoryWiperLayerForTime:dstTime];
	}];
	
	self.selectedControlPoint = [document.trajectory findControlPointForTime:dstTime];
	
}

-(void)updateTrajectoryWiperLayerForTime:(CMTime)theTime;
{
	// check if the current time is covered by the path
	// if yes, draw a marker on the path to visualize the position in time
	BOOL timeIsConveredByTrajectory = [document.trajectory containsTime:theTime];
	if(timeIsConveredByTrajectory)
	{
		CGPoint wiperPosition = [document.trajectory positionForTime:theTime];
		wiperPosition = CGPoint2DScale(wiperPosition, [self bounds].size);
		
		trajectoryWiperLayer.position = wiperPosition;		
		trajectoryWiperLayer.hidden = NO;
	}
	else
	{
		trajectoryWiperLayer.hidden = YES;
	}

}


#pragma mark -
#pragma mark Mouse Handling

-(CGPoint)normalizedLocationInMovie:(NSEvent *)theEvent;
{
	//TODO: if video gravity is set to something sensible, you have to do math here
	NSPoint locationInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	CGPoint normalizedLocation = NSPointToCGPoint(locationInView);
	normalizedLocation.x /= [self bounds].size.width;
	normalizedLocation.y /= [self bounds].size.height;
	
	return normalizedLocation;
}


-(void)mouseDown:(NSEvent *)theEvent
{
	//TODO: check if we hit a control point or we already have one for the current time
	CGPoint normalizedMovieLocation = [self normalizedLocationInMovie:theEvent];
	
	CGPoint locationInView = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
	CALayer *clickedLayer = [movieLayer hitTest:locationInView];
	

	
	mouseMode = kDTCVideoViewMouseModeNewControlPoint;
	
	BOOL cpExists = NO;
	if([[clickedLayer name] isEqualToString:@"controlPoint"] ||
	   [[clickedLayer name] isEqualToString:@"rightHandle"] ||
	   [[clickedLayer name] isEqualToString:@"leftHandle"])
	{	
		cpExists = YES;		
		
		if([[clickedLayer name] isEqualToString:@"leftHandle"])
		{
			mouseMode = kDTCVideoViewMouseModeMoveLeftHandle;
			self.selectedControlPoint = [(DTCControlPointLayer *)[clickedLayer superlayer] controlPoint];			
			
		}
		else if([[clickedLayer name] isEqualToString:@"rightHandle"])
		{
			mouseMode = kDTCVideoViewMouseModeMoveRightHandle;
			self.selectedControlPoint = [(DTCControlPointLayer *)[clickedLayer superlayer] controlPoint];
		}
		else
		{
			mouseMode = kDTCVideoViewMouseModeMoveControlPoint;
			self.selectedControlPoint = [(DTCControlPointLayer *)clickedLayer controlPoint];
		}

		
		[moviePlayer seekToTime:self.selectedControlPoint.time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
			[self updateTrajectoryWiperLayerForTime:self.selectedControlPoint.time];
		}];
		
		double minValue = [timelineSlider minValue];
		double maxValue = [timelineSlider maxValue];	
		
		CMTime movieDuration = [[moviePlayer currentItem] duration];
		CMTime currentTime = [moviePlayer currentTime];
		
		double percentage = (double)currentTime.value / (double)movieDuration.value;
		
		double sliderValue = (maxValue - minValue) * percentage + minValue;
		
		[timelineSlider setDoubleValue:sliderValue];
	}
	else 
	{
		self.selectedControlPoint = [document.trajectory findControlPointForTime:[moviePlayer currentTime]];
		
		if(self.selectedControlPoint)
		{
			mouseMode = kDTCVideoViewMouseModeMoveControlPoint;	
		}

	}
	
	switch (mouseMode)
	{
		case kDTCVideoViewMouseModeNewControlPoint:
			self.selectedControlPoint = [self addControlPoint:normalizedMovieLocation];
			mouseMode = kDTCVideoViewMouseModeMoveControlPoint;
			break;
		case kDTCVideoViewMouseModeMoveControlPoint:
			self.selectedControlPoint.location = normalizedMovieLocation;
			break;
			
		default:
			break;
	}
	
	[self updatePath];
	[self updateTrajectoryWiperLayerForTime:[moviePlayer currentTime]];


}


-(void)mouseDragged:(NSEvent *)theEvent
{
	CGPoint normalizedMovieLocation = [self normalizedLocationInMovie:theEvent];
	
	switch (mouseMode)
	{
		case kDTCVideoViewMouseModeMoveControlPoint:
			self.selectedControlPoint.location = normalizedMovieLocation;
			break;
		case kDTCVideoViewMouseModeMoveLeftHandle:
			self.selectedControlPoint.leftHandleOffset = CGPointSubtract(normalizedMovieLocation, self.selectedControlPoint.location);
			break;
		case kDTCVideoViewMouseModeMoveRightHandle:
			self.selectedControlPoint.rightHandleOffset = CGPointSubtract(normalizedMovieLocation, self.selectedControlPoint.location);
			break;
			
		case kDTCVideoViewMouseModeNewControlPoint:
		default:
			break;
	}
	
	[self updatePath];
	[self updateTrajectoryWiperLayerForTime:[moviePlayer currentTime]];
	
}


-(void)setExpandControlPoints:(BOOL)doesExpand;
{
	[document.trajectory expandControlPoints:doesExpand];
}

#pragma mark -
#pragma mark Bezier Path Management

-(void)updatePath
{
	if([document.trajectory count] < 2)
		return;
	
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale([self bounds].size.width, [self bounds].size.height);
	
	CGPathRef normalizedPath = [document.trajectory createPath];
	CGPathRef path = CGPathCreateCopyByTransformingPath(normalizedPath, &scaleTransform);
	
	[pathLayer setPath:path];
	
	CGPathRelease(normalizedPath);	
	CGPathRelease(path);
}





#pragma mark -
#pragma mark Control Point Management

-(DTCControlPoint *)addControlPoint:(CGPoint)normalizedMovieLocation;
{
	DTCControlPoint *cp = [[DTCControlPoint alloc] init];

	cp.time = [moviePlayer currentTime];
	cp.location = normalizedMovieLocation;
	cp.leftHandleOffset = CGPointZero;
	cp.rightHandleOffset = CGPointZero;
	cp.selected = YES;


	DTCControlPointLayer *controlPointLayer	= [[DTCControlPointLayer alloc] initWithControlPoint:cp];
	
	[controlPointLayer willChangeValueForKey:@"superlayer"];
	[movieLayer addSublayer:controlPointLayer];
	[controlPointLayer didChangeValueForKey:@"superlayer"];

	[document.trajectory addControlPoint:cp];
	
	[controlPointLayerDict setObject:controlPointLayer forKey:cp];
	
	return cp;
}

-(void)createControlPointLayersForNewTrajectory;
{
	for (DTCControlPoint *cp in document.trajectory.controlPoints)
	{
		DTCControlPointLayer *controlPointLayer	= [[DTCControlPointLayer alloc] initWithControlPoint:cp];
		
		[controlPointLayer willChangeValueForKey:@"superlayer"];
		[movieLayer addSublayer:controlPointLayer];
		[controlPointLayer didChangeValueForKey:@"superlayer"];
		
		[controlPointLayerDict setObject:controlPointLayer forKey:cp];
	}
	
	double delayInSeconds = 0.5;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self updatePath];
	});
}

-(void)deleteSelectedControlPoint;
{
	DTCControlPointLayer *controlPointLayer = [controlPointLayerDict objectForKey:self.selectedControlPoint];
	[controlPointLayer removeFromSuperlayer];
//	[controlPointLayerDict removeObjectForKey:self.selectedControlPoint];
	
	[document.trajectory removeControlPoint:self.selectedControlPoint];	
	self.selectedControlPoint = nil;
	
	[self updatePath];
	[self updateTrajectoryWiperLayerForTime:moviePlayer.currentTime];
}



#pragma mark -
#pragma mark Custom Property Implementation

-(void)setPlayerItem:(AVPlayerItem *)playerItem
{
	[moviePlayer replaceCurrentItemWithPlayerItem:playerItem];
}


-(AVPlayerItem *)playerItem
{
	return [moviePlayer currentItem];
}

-(void)setSelectedControlPoint:(DTCControlPoint *)theSelectedControlPoint
{
	if(selectedControlPoint != theSelectedControlPoint)
	{
		selectedControlPoint.selected = NO;		
		selectedControlPoint = theSelectedControlPoint;
		
		selectedControlPoint.selected = YES;
	}
}


#pragma mark -
#pragma mark Custom View Drawing
- (void)drawRect:(NSRect)dirtyRect
{
    //NOOP, drawing is done in layers
}

@end
