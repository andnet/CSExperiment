//
//  AppDelegate.m
//  CSExperiment
//
//  Created by Andreas Nett on 05.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//


#import "CSConstants.h"



#import "CSAppDelegate.h"
#import "CSVisBox.h"
#import "CSVisSpline.h"
#import "CSVisTestblink.h"
#import "CSVisNumber.h"
#import "DTCTrajectory.h"

#import "CSConverterClass.h"
#import "CSConverterAffin.h"
#import "CSConverterDiscontinuity.h"


#import "CSKeyResponderWindow.h"

@implementation CSAppDelegate

@synthesize qUserID;
@synthesize qGender;
@synthesize qAge;
@synthesize qProfession;
@synthesize qHandedness;
@synthesize qLikert1;
@synthesize qLikert2;
@synthesize qLikert3;
@synthesize qLikert4;
@synthesize qLikert5;
@synthesize qLikert6;
@synthesize questionaireWindow;
@synthesize debugPosField;
@synthesize todoField;
@synthesize mainBox;
@synthesize connectButton;
@synthesize createLogFileButton;
@synthesize dateOfExperiment;
@synthesize window;
@synthesize configurationWindow;
@synthesize alertTrainingBegins;
@synthesize alertExperimentBegins;
@synthesize alertExperimentEnded;
@synthesize waitingForModalAlert;
@synthesize portSelector;
@synthesize acceptNextTaskCommand;
@synthesize socket;
@synthesize socketIsRunning;
@synthesize currentTaskNumber;
@synthesize tasks;
@synthesize numberOfTasks;
@synthesize numberOfTrainingTasks;
@synthesize userID;



-(NSMutableArray*)readParametersFromPlist
{
	// Assemble path to locate 'parameters.plist' file in the users document folder

	NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"parameters" ofType:@"plist"];
	// Create an array with the contents of parameters.plist
	NSMutableArray *temp = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
	return temp;
}


-(NSMutableArray*)createTasksFrom:(NSMutableArray *)tempTasks
{
	// Enumerator for the dictionaries elements "d" of the array
	NSEnumerator *taskEnumerator = [tempTasks objectEnumerator];
	id d;
	// Assemble every task
	while (d = [taskEnumerator nextObject])
	{
		CSConverterClass	*tempConverter = [[CSConverterClass alloc] initWithMaxInput:999];
		// CSConverterDiscontinuity	*tempConverter = [[CSConverterDiscontinuity alloc] initWithMaxInput:999 hwStartOfDis:400 hwLengthOfDisc:200];
		NSMutableString		*tempLogs = [[NSMutableString alloc] init];
		// check is instructions are defined in paramater file
		if ([d objectForKey:INSTRUCTIONS] == nil || [[d objectForKey:INSTRUCTIONS] length] < 2)
		{
			NSMutableString *defaultInstructions = [NSMutableString stringWithString:@"Set the value to match the target."];
			[d setObject:defaultInstructions forKey:INSTRUCTIONS];
		}


		switch ([[d objectForKey:TASKTYPE] intValue])
		{
			// bar type, add a CSVisBox object
			case 0:
			{
				CSVisBox *tempVis	=	[[CSVisBox alloc] initWithConverter:tempConverter
														   logs:tempLogs
												   instructions:[d objectForKey:INSTRUCTIONS]
														   view:mainBox
													   delegate:self
														 target:[[d objectForKey:TARGET] intValue]
														 length:[[d objectForKey:LENGTH] intValue]];
				[d setObject:tempVis forKey:VISUALIZATION];
			}	
				break;
				
			// trajectory type, add a CSVisSpline object
			case 1:
			{
				// Load the trajectory for the current task
				NSString* trajectoryPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"trajectory"];
				NSURL *url = [NSURL fileURLWithPath:trajectoryPath];
				NSData *data = [NSData dataWithContentsOfURL:url];
				NSMutableDictionary *box = [NSKeyedUnarchiver unarchiveObjectWithData:data];
				DTCTrajectory *tempTrajectory = [box	objectForKey:@"trajectory"];

				CSVisSpline *tempVis = [[CSVisSpline alloc] initWithConverter:tempConverter
																		 logs:tempLogs
																 instructions:[d objectForKey:INSTRUCTIONS]
																		 view:mainBox
																	 delegate:self
																	   target:[[d objectForKey:TARGET] intValue]
																   trajectory:tempTrajectory];
				[d setObject:tempVis forKey:VISUALIZATION];
			}
				break;
				// bar type, add a CSVisBox object
			case 2:
			{
				CSVisNumber *tempVis	=	[[CSVisNumber alloc] initWithConverter:tempConverter
																			  logs:tempLogs
																	  instructions:[d objectForKey:INSTRUCTIONS]
																			  view:mainBox
																		  delegate:self
																		    target:[[d objectForKey:TARGET] intValue]
																		    length:[[d objectForKey:LENGTH] intValue]];
				[d setObject:tempVis forKey:VISUALIZATION];
			}	
		} // END SWITCH

	}
	return tempTasks;
}



-(void)awakeFromNib
{
	// Prepare windows and alert dialogs
	alertTrainingBegins = [NSAlert alertWithMessageText:@"Training" defaultButton:@"Jepp." alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please use this training phase to get comfortable with the hardware slider."];
	alertExperimentBegins = [NSAlert alertWithMessageText:@"Training Completed" defaultButton:@"Jepp." alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please get ready and proceed. Complete the following tasks like as precise and quickly as possible."];
	alertExperimentEnded = [NSAlert alertWithMessageText:@"Thank you for your time!" defaultButton:@"Jepp." alternateButton:nil otherButton:nil informativeTextWithFormat:@"Thanks for participating."];
	
	// Note the start date of the Experiment launch, just for log file naming, not for timing of any kind.
    dateOfExperiment = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
	userID = [[NSMutableString alloc] init];
	
	// Task Creation
	tasks = [self createTasksFrom:[self readParametersFromPlist]];
	numberOfTasks = [tasks count] - 1;
	// TODO has to be defined properly, just for testing right now
	numberOfTrainingTasks = numberOfTasks - 15;
	NSLog(@"Creating %lu tasks from parameters.plist file in bundle", numberOfTasks);

	
	
	
    // NETWORKING Create UDP Socket
    socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    socketIsRunning = NO;
    acceptNextTaskCommand = NO;
}


// Opens a UDP socket
- (IBAction)connect:(id)sender {
    if (socketIsRunning)
    {
        NSLog(@"CSAppDelegate: Running Socket found. Closing socket.");
        [socket close];
        socketIsRunning = NO;
        [connectButton setTitle:@"Connect"];
    }
    else
    {
		int port = 7771;
		NSString* connectTitle;
        
        if ([portSelector selectedTag] >= 7000 && [portSelector selectedTag] <= 7779)
		{
			port = (int)[portSelector selectedTag];
			NSLog(@"CSAppDelegate: No running Socket found. Opening socket: %i", port);
			connectTitle = [NSString stringWithFormat:@"%i connected", port];
		}
		else
		{
			NSLog(@"CSAppDelegate: No running Socket found. Opening socket: %i", port);
			connectTitle = [NSString stringWithFormat:@"%i (default)", port];
		}
		[connectButton setTitle:connectTitle];
		NSError *error = nil;
        if (![socket bindToPort:port error:&error])
        {
            return;
        }
        if (![socket beginReceiving:&error])
        {
            return;
        }
        socketIsRunning = YES;
    }
}





-(void) showInstructionsForTask:(NSInteger)number
{
	
}

/* Creates a log file on hard drive containing:
 * - Experiment header
 * - User data questionair answers
 * - Acquired experimental data	
 */
- (IBAction)createLogFile:(id)sender
{
    // Determine file location and filename
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if ([userID length] < 6)
	{
		[self questGenerateUserID:nil];
	}
	NSString *fileName = [NSString stringWithFormat:@"%@/%@.cslog\n", documentsDirectory, userID];
	// Assemble log file contents
	NSMutableString *fileContents = [[NSMutableString alloc] initWithFormat:@"ExperimentName: %@\n", cEXPERIMENT];
	// Header:
	[fileContents appendString:@"<header>\n"];
	[fileContents appendFormat:@"Version: %@\n", cVERSION];
	[fileContents appendFormat:@"Subject: %@\n", userID];
	[fileContents appendFormat:@"Date: %i-%i-%i\n", dateOfExperiment.year, dateOfExperiment.month, dateOfExperiment.day];
	[fileContents appendFormat:@"Time: %i:%i\n", dateOfExperiment.hour, dateOfExperiment.minute];
	[fileContents appendString:@"</header>\n"];
	// Questionaire
	[fileContents appendString:@"<questionaire>\n"];
	[fileContents appendFormat:@"Gender: %i\n", [qGender selectedTag]];
	[fileContents appendFormat:@"Age: %@\n", [qAge stringValue]];
	[fileContents appendFormat:@"Handedness: %i\n", [qHandedness selectedTag]];
	[fileContents appendFormat:@"Q1: %i\n", [qLikert1 selectedTag]];
	[fileContents appendFormat:@"Q2: %i\n", [qLikert2 selectedTag]];
	[fileContents appendFormat:@"Q3: %i\n", [qLikert3 selectedTag]];
	[fileContents appendFormat:@"Q4: %i\n", [qLikert4 selectedTag]];
	[fileContents appendFormat:@"Q5: %i\n", [qLikert5 selectedTag]];
	[fileContents appendFormat:@"Q6: %i\n", [qLikert6 selectedTag]];
	[fileContents appendString:@"</questionaire>\n"];
	// Log strings from every task
	[fileContents appendString:@"<tasklogs>\n"];
	NSEnumerator *taskEnumerator = [tasks objectEnumerator];
	id element;
	while (element = [taskEnumerator nextObject])
	{
		[fileContents appendFormat:@"<task:%d>\n", [tasks indexOfObject:element]];
		// Parameters for this task:
		[fileContents appendFormat:@"<parameters:%d>\n", [tasks indexOfObject:element]];
		[fileContents appendFormat:@"%d, %@, %d, %d\n", [[element objectForKey:TASKTYPE] intValue], [element objectForKey:CONVERTER], [[element objectForKey:LENGTH] intValue], [[element objectForKey:TARGET]intValue]];
		[fileContents appendFormat:@"</parameters:%d>\n", [tasks indexOfObject:element]];
		// Actual experimental data
		[fileContents appendString:[[element objectForKey:VISUALIZATION] getLogs]];
		[fileContents appendFormat:@"</task:%d>\n", [tasks indexOfObject:element]];
	}
	[fileContents appendString:@"</tasklogs>\n"];
	
    //save content to the documents directory
	[fileContents replaceOccurrencesOfString:@"." withString:@"," options:0 range:NSMakeRange(0, [fileContents length])];
	[fileContents writeToFile:fileName 
				   atomically:NO 
					 encoding:NSStringEncodingConversionAllowLossy 
						error:nil];
	
	
    
}


- (IBAction)startExperimentSignal:(id)sender
{
	NSLog(@"Received Start Experiment Signal");
	waitingForModalAlert = NO;
	acceptNextTaskCommand = YES;
	currentTaskNumber = - 1;
	NSLog(@"Sending Task Complete Signal");
	[self taskCompleteSignal:self];
}


// called when the user presses a key to signal task completion.
- (IBAction)taskCompleteSignal:(id)sender
{
	NSLog(@"received Task Complete Signal");
	if (acceptNextTaskCommand)
	{
		acceptNextTaskCommand = NO;
		// Show alerts
		if (currentTaskNumber == - 1)
		{
			// Display alert for training phase
			waitingForModalAlert = YES;
			[alertTrainingBegins beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(modalAlertDismissed) contextInfo:nil];
		}
		else if (currentTaskNumber == numberOfTrainingTasks)
		{
			// Display alert for experiment phase
			waitingForModalAlert = YES;
			[alertExperimentBegins beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(modalAlertDismissed) contextInfo:nil];
			
		}
		
		// Proceed or end experiment
		if (currentTaskNumber < numberOfTasks)
		{
			// There are still tasks to to, proceed with next task.
			currentTaskNumber++;
			// Tasks are adressed from 1...numberOfTasks, but inside the array addressing is mapped to 0...(numberOfTasks-1)
			[self loadTask:(currentTaskNumber)];
		}
		else
		{
			// All tasks completed. We are done. Proceed with ending sequence
			// Display alert for end of experiment
			waitingForModalAlert = YES;
			[alertExperimentEnded beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
		}  
	}
}



-(void) loadTask:(NSInteger)taskNumber
{
	NSLog(@"Loading task number %ld", taskNumber);
	// Initialize upcoming task
	[[[tasks objectAtIndex:currentTaskNumber] objectForKey:VISUALIZATION] makeActive];
	// Swich to upcoming task
	[socket setDelegate:[[tasks objectAtIndex:currentTaskNumber] objectForKey:VISUALIZATION]];
}



// Called as delegate method from VisClass, to display the current position
- (void)updateDebugPosField:(double)newPos
{
    [debugPosField setDoubleValue:newPos];
}


/* Generate a random User ID for logging
 */
- (IBAction)questGenerateUserID:(id)sender
{
	// Flush current User ID
	[userID setString:@""];
	// Start with 2 random letters
	NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyz";
	for (int i = 0; i < 2; i++)
	{
		unichar c = [alphabet characterAtIndex:(arc4random() % [alphabet length])];
		[userID appendFormat:@"%C", c];
	}
	// End with 4 random numbers
	for (int i = 0; i < 4; i++)
	{
		[userID appendFormat:@"%i", (arc4random() % 10)];
	}
	// Update textfield to show the new User ID
	[qUserID setStringValue:userID];
}


/* Updates the todoField to display instructions. 
*/
- (void)updateTodoFieldWithString:(NSString *)newString
{
	[todoField setStringValue:newString];
}



- (IBAction)showConfigurationWindow:(id)sender
{
	[configurationWindow makeKeyAndOrderFront:sender];
}


- (IBAction)showQuestionaireWindow:(id)sender
{
	[questionaireWindow makeKeyAndOrderFront:sender];
}


- (void)logABeep
{
	NSLog(@"Beep.");
}


- (void)modalAlertDismissed
{
	waitingForModalAlert = NO;
}


@end





