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
BOOL (*TG_GetValueStatus)(int, int) = NULL;
int (*TG_Disconnect)(int) = NULL;
void (*TG_FreeConnection)(int) = NULL;
int (*TG_EnableBlinkDetection)(int, int) = NULL;


@implementation TGManager

@synthesize status, signalQuality, attention, meditation, raw, delta, theta, alpha1, alpha2, beta1, beta2, gamma1, gamma2, blink;

- (void) awakeFromNib	{
	[self start];
}

- (void) _prepareBundle	{
	NSLog(@"%s",__func__);
	CFURLRef bundleURL;
	
	status = TGManagerStatusStopped;

	bundleURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)[NSString stringWithFormat:@"%@/Contents/Resources/ThinkGear.bundle",[[NSBundle mainBundle] bundlePath]],
				kCFURLPOSIXPathStyle, true);
	NSLog(@"\t\tloading think gear bundle URL %@",(NSURL*)bundleURL);
	thinkGearBundle = CFBundleCreate(kCFAllocatorDefault, bundleURL);
	if(!thinkGearBundle)	{
		NSLog(@"Error: Failed to load bundle!");
		goto BAIL;
	}
	
	// now start setting the function pointers
	TG_GetDriverVersion = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_GetDriverVersion"));
	TG_GetNewConnectionId = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_GetNewConnectionId"));
	TG_Connect = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_Connect"));
	TG_Disconnect = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_Disconnect"));
	TG_FreeConnection = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_FreeConnection"));
	TG_GetValue = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_GetValue"));
	TG_GetValueStatus = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_GetValueStatus"));
	TG_ReadPackets = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_ReadPackets"));
	TG_EnableBlinkDetection = (void*)CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_EnableBlinkDetection"));
	if(!TG_Connect)	{
		NSLog(@"Error: Failed to create TG_Connect");
		goto BAIL;
	}
	if(!TG_GetValueStatus)	{
		NSLog(@"Error: Failed to create TG_GetValueStatus");
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
		status = TGManagerStatusError;
		if (delegate)	{
			[delegate statusDidChange:self];
		}
		return;
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
	
	if(!TG_Connect)	{
		goto BAIL;
	}

	connectionID = TG_GetNewConnectionId();
	ret = TG_Connect(connectionID, portname, TG_BAUD_9600, TG_STREAM_PACKETS);
	
	if (ret)	{
		NSLog(@"Error: TG_Connect failed %ld",ret);
		status = TGManagerStatusError;
		_running = NO;
		if (delegate)	{
			[delegate statusDidChange:self];
		}
		goto BAIL;
	}
	
	BOOL blinkActive = NO;
	if (TG_EnableBlinkDetection(connectionID, 1)==0)	{
		NSLog(@"\t\tenabled blink detection");
		blinkActive = YES;
	}
	//	Start the run loop such that we break only when stopped
	//		Within the loop check for new packets, update the variables as needed
	int numPackets = 0;
	_running = YES;
	status=TGManagerStatusRunning;

	if (delegate)	{
		[delegate statusDidChange:self];
	}
	int readCount = 0;
	while(status==TGManagerStatusRunning)	{
		//	Sleep for a little bit
		usleep(33000);
		//	Read new packets
		numPackets = TG_ReadPackets(connectionID, -1);
		
		//	If new packets are received update the variables and notify the delegate
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
			if ((blinkActive)&&(TG_GetValueStatus(connectionID, TG_DATA_BLINK_STRENGTH)))	{
				blink = TG_GetValue(connectionID, TG_DATA_BLINK_STRENGTH);
			}
			else	{
				blink = 0;
			}
			
			
			if (delegate)	{
				[delegate valuesDidChange:self];
			}
		}
		
		//	Every once and a while release the pool and create a new one
		++readCount;
		if (readCount>300)	{
			[pool release];
			pool = [[NSAutoreleasePool alloc] init];
			readCount = 0;
		}
	}
	
	//	Set the internal running flag back to NO and notify the delegate that we've actually stopped
	_running = NO;
	if (delegate)	{
		[delegate statusDidChange:self];
	}
	
	//	Disconnect and free up the connection
	TG_Disconnect(connectionID);
	TG_FreeConnection(connectionID);
	
	//	Release our autorelease pool
	BAIL:
	[pool release];
}

- (void) stop	{
	//	Set the status to stopped - on the next pass it'll bail and exit its thread
	status = TGManagerStatusStopped;
}

@end
