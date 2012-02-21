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
