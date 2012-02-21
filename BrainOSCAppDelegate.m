//
//  BrainOSCAppDelegate.m
//  BrainOSC
//
//  Created by David Lublin on 2/20/12.
//  Copyright 2012 Vidvox. All rights reserved.
//

#import "BrainOSCAppDelegate.h"

@implementation BrainOSCAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

- (IBAction) startStopButtonUsed:(id)sender	{
	if ([tgManager status]==TGManagerStatusRunning)	{
		[tgManager stop];
	}
	else	{
		[tgManager start];
	}
}

- (void) statusDidChange:(id)m	{
	//NSLog(@"%s",__func__);
	[self _updateStatusDisplay];
}

- (void) valuesDidChange:(id)m	{
	//NSLog(@"%s",__func__);
	[self _sendValues];
}

- (void) _updateStatusDisplay	{
	if ([NSThread isMainThread]==NO)	{
		[self performSelectorOnMainThread:@selector(_updateStatusDisplay) withObject:nil waitUntilDone:NO];
		return;
	}
	NSLog(@"%s",__func__);
	switch((int)[tgManager status])	{
		case TGManagerStatusStopped:
			[startStopButton setTitle:@"Start"];
			[tgManagerStatusField setStringValue:@"Not running"];
			break;
		case TGManagerStatusRunning:
			[startStopButton setTitle:@"Stop"];
			[tgManagerStatusField setStringValue:@"Active"];
			break;
		case TGManagerStatusError:
			[startStopButton setTitle:@"Retry"];
			[tgManagerStatusField setStringValue:@"Connection Error"];
			break;
	}
}

- (void) _sendValues	{
	OSCBundle		*bundle = [OSCBundle create];
	OSCPacket		*pack = nil;
	
	NSString *address = nil;
	OSCMessage		*msg = 	nil;

	BOOL	contact = NO;
	if ([tgManager signalQuality]!=200)
		contact=YES;
	
	//	Send each of the variables out over OSC
	//	signalQuality, attention, meditation, raw, delta, theta, alpha1, alpha2, beta1, beta2, gamma1, gamma2
	address = @"/BrainWave/SignalQuality";
	msg = [[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		if ([tgManager signalQuality]!=200)
			[msg addFloat:(1.0-[tgManager signalQuality]/199.0)];
		else
			[msg addFloat:0.0];
		[bundle addElement:msg];
		[msg release];
	}

	//	If the signalQuality is 200 there is no detected connection to the forehead, send this as a bool
	address = @"/BrainWave/Contact";
	msg = [[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addBOOL:contact];
		[bundle addElement:msg];
		[msg release];
	}	
	
	//	If no contact is made don't send any other data
	if (contact==NO)
		goto BAIL;

	address = @"/BrainWave/Attention";
	msg = [[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addFloat:[tgManager attention]/100.0];
		[bundle addElement:msg];
		[msg release];
	}
	
	address = @"/BrainWave/Meditation";
	msg = 	[[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addFloat:[tgManager meditation]/100.0];
		[bundle addElement:msg];
		[msg release];
	}
	
	address = @"/BrainWave/Raw";
	msg = 	[[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addFloat:[tgManager raw]/100.0];
		[bundle addElement:msg];
		[msg release];
	}
	
	address = @"/BrainWave/Delta";
	msg = 	[[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addFloat:[tgManager delta]];
		[bundle addElement:msg];
		[msg release];
	}
	
	address = @"/BrainWave/Theta";
	msg = 	[[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addFloat:[tgManager theta]];
		[bundle addElement:msg];
		[msg release];
	}
	
	address = @"/BrainWave/Alpha1";
	msg = 	[[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addFloat:[tgManager alpha1]];
		[bundle addElement:msg];
		[msg release];
	}
	
	address = @"/BrainWave/Alpha2";
	msg = 	[[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addFloat:[tgManager alpha2]];
		[bundle addElement:msg];
		[msg release];
	}
	
	address = @"/BrainWave/Beta1";
	msg = 	[[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addFloat:[tgManager beta1]];
		[bundle addElement:msg];
		[msg release];
	}
	
	address = @"/BrainWave/Beta2";
	msg = 	[[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addFloat:[tgManager beta2]];
		[bundle addElement:msg];
		[msg release];
	}
	
	address = @"/BrainWave/Gamma1";
	msg = 	[[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addFloat:[tgManager gamma1]];
		[bundle addElement:msg];
		[msg release];
	}
	
	address = @"/BrainWave/Gamma2";
	msg = 	[[OSCMessage alloc] _fastInit:
			address:
			NO:
			OSCMessageTypeControl:
			OSCQueryTypeUnknown:
			0:
			0];
			
	if (msg)	{
		[msg addFloat:[tgManager gamma2]];
		[bundle addElement:msg];
		[msg release];
	}
	
	BAIL:
	pack = [OSCPacket createWithContent:bundle];
	
	int outportIndex = [dstPopUpButton indexOfSelectedItem];
	OSCOutPort *oscOutPort = [[oscManager outPortArray] lockObjectAtIndex:outportIndex];
	[oscOutPort sendThisPacket:pack];
}

@end
