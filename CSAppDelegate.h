//
//  AppDelegate.h
//  CSExperiment
//
//  Created by Andreas Nett on 05.05.12.
//  Copyright (c) 2012 RWTH Aachen University. All rights reserved.
//
#pragma mark -

#import <Cocoa/Cocoa.h>


@class CSVisClass;
@class CSVisBox;
@class CSConverterClass;
@class GCDAsyncUdpSocket;
@class CSKeyResponderWindow;


#import "GCDCocoaAsyncUdpSocket/GCDAsyncUdpSocket.h"

@interface CSAppDelegate : NSObject <NSApplicationDelegate, GCDAsyncUdpSocketDelegate>

#pragma mark -
#pragma mark General Properties
// Array of tasks. Each task is contained in one dictionary.
@property (strong) NSMutableArray *tasks;
// Amount of tasks defined in the parameter plist file
@property (assign) NSInteger numberOfTasks;
// Those first tasks belong to the training part of the experiment sequence 
@property (assign) NSInteger numberOfTrainingTasks;
@property (assign) NSInteger currentTaskNumber;
// Is the user able to advance to the next task yet?
@property (assign) BOOL acceptNextTaskCommand;
@property (assign) CFGregorianDate dateOfExperiment;

// A tasks CSVisClass object draws into this box
@property (weak) IBOutlet NSBox *mainBox;
// TODO REPLACE by logic in program sequence
@property (weak) IBOutlet NSButton *createLogFileButton;
// Instructions for the user are displayed here
@property (weak) IBOutlet NSTextField *todoField;

#pragma mark Windows
// Experiment window presented to the user
@property (strong) IBOutlet CSKeyResponderWindow *window;
@property (strong) IBOutlet NSWindow *configurationWindow;
@property (strong) IBOutlet NSWindow *questionaireWindow;
@property (strong) NSAlert *alertTrainingBegins;
@property (strong) NSAlert *alertExperimentBegins;
@property (strong) NSAlert *alertExperimentEnded;
@property (assign) BOOL waitingForModalAlert;





#pragma mark -
#pragma mark Networking (UDP Socket) Properties
@property (strong) GCDAsyncUdpSocket *socket;
@property (assign) BOOL socketIsRunning;
@property (weak) IBOutlet NSMatrix *portSelector;
@property (weak) IBOutlet NSButton *connectButton;
@property (weak) IBOutlet NSTextField *debugPosField;


#pragma mark -
#pragma mark Questionaire (User Data) Properties
@property (strong) NSMutableString *userID;
@property (weak) IBOutlet NSTextField *qUserID;
@property (weak) IBOutlet NSMatrix *qGender;
@property (weak) IBOutlet NSTextField *qAge;
@property (weak) IBOutlet NSTextField *qProfession;
@property (weak) IBOutlet NSMatrix *qHandedness;
@property (weak) IBOutlet NSMatrix *qLikert1;
@property (weak) IBOutlet NSMatrix *qLikert2;
@property (weak) IBOutlet NSMatrix *qLikert3;
@property (weak) IBOutlet NSMatrix *qLikert4;
@property (weak) IBOutlet NSMatrix *qLikert5;
@property (weak) IBOutlet NSMatrix *qLikert6;

#pragma mark -
#pragma mark General Methods
- (IBAction)showConfigurationWindow:(id)sender;
- (IBAction)showQuestionaireWindow:(id)sender;
// Reads an array of task-dictionaries from a plist
- (NSMutableArray*)readParametersFromPlist;
// Adds a CSVisClass object to every task in the task-array
- (NSMutableArray*)createTasksFrom:(NSMutableArray *)tempTasks;

- (IBAction)startExperimentSignal:(id)sender;
- (void)loadTask:(NSInteger)taskNumber;
- (void)showInstructionsForTask:(NSInteger)number;
- (IBAction)taskCompleteSignal:(id)sender;
- (IBAction)createLogFile:(id)sender;
- (void)logABeep;
- (void)modalAlertDismissed;



#pragma mark -
#pragma mark Networking (UDP Socket) Methods
- (IBAction)connect:(id)sender;
- (void)updateDebugPosField:(double)newPos;



#pragma mark -
#pragma mark Questionaire (User Data) Methods
- (IBAction)questGenerateUserID:(id)sender;

@end





