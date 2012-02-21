//
//  TGManager.h
//  BrainOSC
//
//  Created by David Lublin on 2/20/12.
//  Copyright 2012 Vidvox. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h> 
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>



@protocol TGManagerDelegate

- (void) statusDidChange:(id)m;
- (void) valuesDidChange:(id)m;

@end


typedef enum	{
	TGManagerStatusStopped = 0,
	TGManagerStatusRunning = 1,
	TGManagerStatusError = 2
} TGManagerStatus;


/* Baud rate for use with TG_Connect() and TG_SetBaudrate(). */
#define TG_BAUD_1200 1200
#define TG_BAUD_2400 2400
#define TG_BAUD_4800 4800
#define TG_BAUD_9600 9600
#define TG_BAUD_57600 57600
#define TG_BAUD_115200 115200

/* Data format for use with TG_Connect() and TG_SetDataFormat(). */
#define TG_STREAM_PACKETS 0 
#define TG_STREAM_5VRAW 1 
#define TG_STREAM_FILE_PACKETS 2

/* Data type that can be requested from TG_GetValue() */
#define TG_DATA_BATTERY 0
#define TG_DATA_POOR_SIGNAL 1 
#define TG_DATA_ATTENTION 2
#define TG_DATA_MEDITATION 3
#define TG_DATA_RAW 4
#define TG_DATA_DELTA 5 
#define TG_DATA_THETA 6
#define TG_DATA_ALPHA1 7
#define TG_DATA_ALPHA2 8
#define TG_DATA_BETA1 9
#define TG_DATA_BETA2 10
#define TG_DATA_GAMMA1 11
#define TG_DATA_GAMMA2 12



@interface TGManager : NSObject {
	
	id delegate;

	CFBundleRef thinkGearBundle;
	int connectionID;
	
	NSRunLoop	*runLoop;
	BOOL _running;
	
	TGManagerStatus status;
	
	//	Variables
	float signalQuality;
	float attention;
	float meditation;
	float raw;
	float delta;
	float theta;
	float alpha1;
	float alpha2;
	float beta1;
	float beta2;
	float gamma1;
	float gamma2;

}

- (void) _prepareBundle;
- (void) start;
- (void) _threadProc;
- (void) stop;

@property (readonly) TGManagerStatus status;

@property (readonly) float signalQuality;
@property (readonly) float attention;
@property (readonly) float meditation;
@property (readonly) float raw;

@property (readonly) float delta;
@property (readonly) float theta;
@property (readonly) float alpha1;
@property (readonly) float alpha2;
@property (readonly) float beta1;
@property (readonly) float beta2;
@property (readonly) float gamma1;
@property (readonly) float gamma2;

@end
