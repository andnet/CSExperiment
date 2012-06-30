//
//  DTCDocument.h
//  DragonTrajectoryCreator
//
//  Created by Moritz Wittenhagen on 21.03.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DTCVideoView;
@class DTCTrajectory;

@interface DTCDocument : NSDocument
@property (weak) IBOutlet DTCVideoView *videoView;
@property (strong) DTCTrajectory *trajectory;
- (IBAction)exportAsFixedDragonBundle:(id)sender;
- (IBAction)importVideo:(id)sender;

@end
