//
//  DTCDocument.m
//  DragonTrajectoryCreator
//
//  Created by Moritz Wittenhagen on 21.03.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//

#import "DTCDocument.h"
#import "DTCVideoView.h"
#import "DTCControlPoint.h"
#import "DTCTrajectory.h"
#import "DSNetworkUtils.h"
#import "ThoCGGeometryUtilities.h"
#import <AVFoundation/AVFoundation.h>


@implementation DTCDocument
{
	NSURL *videoURL;
	DTCTrajectory *trajectory;
}

@synthesize videoView;
@synthesize trajectory;

- (id)init
{
    self = [super init];
    if (self) {
		// Add your subclass-specific initialization here.
		trajectory = [[DTCTrajectory alloc] init];
		
		[self importVideo:self];
    }
    return self;
}

- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"DTCDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	self.videoView.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
	[self.videoView createControlPointLayersForNewTrajectory];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

-(IBAction)exportAsFixedDragonBundle:(id)sender
{	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"fixedDragon"]];
	[savePanel setAllowsOtherFileTypes:NO];	 
	
	if([savePanel runModal] == NSFileHandlingPanelOKButton)
	{	
		NSURL *packageURL = [savePanel URL];
		
		NSMutableArray	*nodes = [NSMutableArray array];
		
		AVAssetTrack *videoTrack = [[[self.videoView.playerItem asset] tracksWithMediaType:AVMediaTypeVideo] lastObject];
		
		NSError *error;
		AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:self.videoView.playerItem.asset error:&error];
		
		AVAssetReaderTrackOutput *videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:nil];
		[assetReader addOutput:videoOutput];
		
		[assetReader startReading];
		
		NSMutableArray *timestamps = [NSMutableArray array];
		
		NSUInteger frameCount = 0;
		while(assetReader.status == AVAssetReaderStatusReading)
		{
			CMSampleBufferRef sampleBuffer = [videoOutput copyNextSampleBuffer];
			
			CMItemCount sampleCount = CMSampleBufferGetNumSamples(sampleBuffer);		
			
			for(CMItemIndex sampleIndex = 0; sampleIndex < sampleCount; sampleIndex++)
			{
				CMSampleTimingInfo timingInfo;
				CMSampleBufferGetSampleTimingInfo(sampleBuffer, sampleIndex, &timingInfo);
				
				CMTime presentationTime = timingInfo.presentationTimeStamp;
				NSNumber *presentationSeconds = [NSNumber numberWithDouble:CMTimeGetSeconds(presentationTime)];
				
				// store the timestamps and sort them later - frames are NOT necesssarily in the right order
				[timestamps addObject:presentationSeconds]; 
				
				frameCount++;
			}
		}
		
		// sort the frame times
		[timestamps sortUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
			return [obj1 compare:obj2];
		}];
	
		
		// walk through the sorted timestamps, calc positions and assign frame numbers
		
		NSUInteger frameNumber = 0;
		for (NSNumber *presentationSeconds in timestamps)
		{
			CMTime presentationTime = CMTimeMakeWithSeconds([presentationSeconds doubleValue], 600);
			
			CGPoint normalizedPosition = [trajectory positionForTime:presentationTime];
			
			if(!CGPointEqualToPoint(normalizedPosition, CGPointInvalid))
			{
				DSTrajectoryNode *node = [[DSTrajectoryNode alloc] initWithPosition:normalizedPosition frameNumber:frameNumber]; // TODO: the frames do not come in the right order!
				// TODO: store in an array, then sort, then renumber
				[nodes addObject:node];					
			}
			
			frameNumber++;
		}
		
		// hopefully that works out ;)
		assert(frameNumber == frameCount);

		
		//create the package if it doesn't exist yet
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		//clear out existing packages
		[fileManager removeItemAtURL:packageURL error:&error];
		
		BOOL creationSuccessful = [fileManager createDirectoryAtURL:packageURL withIntermediateDirectories:NO attributes:nil error:&error];
		
		if(creationSuccessful)
		{
			//now create the new package content
			//first copy the movie
			NSURL *newMovieURL = [packageURL URLByAppendingPathComponent:@"movie.mov"];					
			[fileManager copyItemAtURL:videoURL toURL:newMovieURL error:&error];
			
			NSURL *trajectoryURL = [packageURL URLByAppendingPathComponent:@"trajectory.plist"];
			
			NSData *trajectoryData = [NSKeyedArchiver archivedDataWithRootObject:nodes];
			
			[trajectoryData writeToURL:trajectoryURL atomically:NO];					
		}
		else 
		{
			//TODO: handle errors
		}
	}		
}

- (IBAction)importVideo:(id)sender;
{
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op setAllowedFileTypes:[NSArray arrayWithObjects:@"mov", @"m4v", nil]];
	[op setAllowsMultipleSelection:NO];
	
	if([op runModal] == NSFileHandlingPanelOKButton)
	{
		videoURL = [op URL];
	}
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	// Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
	// You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	if ([typeName isEqualToString:@"trajectory"])
	{
		NSMutableDictionary *box = [NSMutableDictionary dictionaryWithObjectsAndKeys:
							 self.trajectory, @"trajectory",
							 videoURL, @"videoURL",
							 nil];
		return [NSKeyedArchiver archivedDataWithRootObject:box];
	}
	else
		 return nil; 
		 // TODO: set error
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
	BOOL result = NO;
	if ([typeName isEqualToString:@"trajectory"])
	{
		NSMutableDictionary *box = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		self.trajectory = [box	objectForKey:@"trajectory"];
		videoURL = [box objectForKey:@"videoURL"];
		result = YES;
	}
	
	// TODO: set error
	
	return result;
}

@end
