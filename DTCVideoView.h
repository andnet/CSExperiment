//
//  DTCVideoView.h
//  DragonTrajectoryCreator
//
//  Created by Moritz Wittenhagen on 21.03.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@class DTCDocument;

@interface DTCVideoView : NSView

@property (retain)		AVPlayerItem		*playerItem;
@property (weak)		IBOutlet NSSlider	*timelineSlider;
@property (weak)		IBOutlet DTCDocument *document;

-(IBAction)sliderChanged:(id)sender;
-(void)setExpandControlPoints:(BOOL)doesExpand;
-(void)deleteSelectedControlPoint;
-(void)createControlPointLayersForNewTrajectory;

@end
