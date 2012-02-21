//
//  TGManager.m
//  BrainOSC
//
//  Created by David Lublin on 2/20/12.
//  Copyright 2012 Vidvox. All rights reserved.
//

#import "TGManager.h"

int (*TG_GetDriverVersion)() = NULL;
int (*TG_GetNewConnectionId)() = NULL;
int (*TG_Connect)(int, const char *, int, int) = NULL; 
int (*TG_ReadPackets)(int, int) = NULL;
float (*TG_GetValue)(int, int) = NULL;
int (*TG_Disconnect)(int) = NULL;
void (*TG_FreeConnection)(int) = NULL;


@implementation TGManager

@synthesize status, signalQuality, attention, meditation, raw, delta, theta, alpha1, alpha2, beta1, beta2, gamma1, gamma2;

- (void) awakeFromNib	{
	[self start];
}

- (void) _prepareBundle	{
	NSLog(@"%s",__func__);
	CFURLRef bundleURL;
	
	status = TGManagerStatusStopped;
		
	bundleURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFSTR("BrainOSC.app/Contents/Resources/ThinkGear.bundle"),
				kCFURLPOSIXPathStyle, true);
	NSLog(@"\t\tbundle URL %@",(NSURL*)bundleURL);
	thinkGearBundle = CFBundleCreate(kCFAllocatorDefault, bundleURL);
	if(!thinkGearBundle)	{
		NSLog(@"\t\tfailed to load bundle!");
		goto BAIL;
	}
	
	// now start setting the function pointers
	TG_GetDriverVersion = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_GetDriverVersion"));
	TG_GetNewConnectionId = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_GetNewConnectionId"));
	TG_Connect = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_Connect"));
	TG_Disconnect = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_Disconnect"));
	TG_FreeConnection = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_FreeConnection"));
	TG_GetValue = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_GetValue"));
	TG_ReadPackets = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_ReadPackets"));
	
	if(!TG_Connect)	{
		NSLog(@"\t\tfailed to create TG_Connect");
		goto BAIL;
	}
	BAIL:
	CFRelease(bundleURL); 
}

- (void) dealloc	{
	[self stop];
	if (thinkGearBundle)
		CFRelease(thinkGearBundle);
	[super dealloc];
}

- (void) start	{
	NSLog(@"%s",__func__);
	if (!thinkGearBundle)	{
		[self _prepareBundle];
	}
	if (_running)
		return;
	if(!thinkGearBundle)	{
		NSLog(@"\t\tfailed to start due to no bundle!");
		status = TGManagerStatusError;
		if (delegate)	{
			[delegate statusDidChange:self];
		}
	}
	_running = YES;
	[NSThread detachNewThreadSelector:@selector(_threadProc) toTarget:self withObject:nil];
}

- (void) _threadProc	{
	NSLog(@"%s",__func__);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//	Create the connection, or bail
	const char *portname = "/dev/tty.MindWave"; 
	int ret = -1;

	connectionID = TG_GetNewConnectionId();
	ret = TG_Connect(connectionID, portname, TG_BAUD_9600, TG_STREAM_PACKETS);
	
	if (ret)	{
		NSLog(@"\t\tstart failed %ld",ret);
		status = TGManagerStatusError;
		_running = NO;
		if (delegate)	{
			[delegate statusDidChange:self];
		}
		return;
	}
	
	//	Start the run loop such that we break only when stopped
	//		Within the loop check for new packets, update the variables as needed
	int numPackets = 0;
	_running = YES;
	status=TGManagerStatusRunning;
	NSLog(@"\t\tstarted!");
	if (delegate)	{
		[delegate statusDidChange:self];
	}
	int readCount = 0;
	while(status==TGManagerStatusRunning)	{
		//	sleep for a quarter-second
		usleep(33000);
		//	get new packets
		numPackets = TG_ReadPackets(connectionID, -1);
		if (numPackets)	{
			signalQuality = TG_GetValue(connectionID, TG_DATA_POOR_SIGNAL); 
			attention = TG_GetValue(connectionID, TG_DATA_ATTENTION); 
			meditation = TG_GetValue(connectionID, TG_DATA_MEDITATION);
			
			raw = TG_GetValue(connectionID, TG_DATA_RAW); 
			delta = TG_GetValue(connectionID, TG_DATA_DELTA); 
			theta = TG_GetValue(connectionID, TG_DATA_THETA);
			
			alpha1 = TG_GetValue(connectionID, TG_DATA_ALPHA1); 
			alpha2 = TG_GetValue(connectionID, TG_DATA_ALPHA2); 
			beta1 = TG_GetValue(connectionID, TG_DATA_BETA1);
			beta2 = TG_GetValue(connectionID, TG_DATA_BETA2); 
			gamma1 = TG_GetValue(connectionID, TG_DATA_GAMMA1); 
			gamma2 = TG_GetValue(connectionID, TG_DATA_GAMMA2);
			
			//NSLog(@"\t\tread: %f : %f : %f",signalQuality,attention,meditation);
			if (delegate)	{
				[delegate valuesDidChange:self];
			}

			++readCount;			
			//	Every once and a while do something special..
			if (readCount>100)	{
				[pool release];
				pool = [[NSAutoreleasePool alloc] init];
				readCount = 0;
			}

		}
	}
	_running = NO;
	if (delegate)	{
		[delegate statusDidChange:self];
	}
	//	Disconnect and free up the connection
	TG_Disconnect(connectionID);
	TG_FreeConnection(connectionID);
	//	Release our autorelease pool
	[pool release];
}

- (void) stop	{
	status = TGManagerStatusStopped;
}

@end
