//
//  BrainOSCAppDelegate.h
//  BrainOSC
//
//  Created by David Lublin on 2/20/12.
//  Copyright 2012 Vidvox. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <VVOSC/VVOSC.h>
#import "TGManager.h"



/*

	Simple app controller class-
	1. Listen for incoming brainwave data (delegate for tgManager)
	2. Pass off data to OSCManager (see NetworkSetupController for OSCManager config methods)
	3. Update UI when brainwave connection status changes


	See http://code.google.com/p/vvopensource/ for more details on VVOSC

*/




@interface BrainOSCAppDelegate : NSObject <NSApplicationDelegate, TGManagerDelegate> {
    NSWindow *window;

	IBOutlet TGManager *tgManager;
	IBOutlet OSCManager	*oscManager;
	
	IBOutlet NSPopUpButton		*dstPopUpButton;
	IBOutlet NSButton			*startStopButton;
	IBOutlet NSTextField		*tgManagerStatusField;

}


@property (assign) IBOutlet NSWindow *window;

- (IBAction) startStopButtonUsed:(id)sender;

- (void) _updateStatusDisplay;
- (void) _sendValues;

@end
