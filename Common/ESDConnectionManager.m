//==============================================================================
/**
@file       ESDConnectionManager.m

@brief      Wrapper to implement the communication with the Stream Deck application

@copyright  (c) 2018, Corsair Memory, Inc.
			This source code is licensed under the MIT-style license found in the LICENSE file.

**/
//==============================================================================

#import "ESDConnectionManager.h"

#import "SRWebSocket.h"

@interface ESDConnectionManager () <SRWebSocketDelegate>

@property (strong) SRWebSocket *socket;

@property (assign) int port;
@property (strong) NSString *pluginUUID;
@property (strong) NSString *registerEvent;
@property (strong) NSString *applicationVersion;
@property (strong) NSString *applicationPlatform;
@property (strong) NSString *applicationLanguage;
@property (strong) NSString *devicesInfo;

@property (weak) id<ESDEventsProtocol> delegate;

@end


@implementation ESDConnectionManager


- (instancetype)initWithPort:(int)inPort
	andPluginUUID:(NSString *)inPluginUUID
	andRegisterEvent:(NSString *)inRegisterEvent
	andInfo:(NSString *)inInfo
	andDelegate:(id<ESDEventsProtocol>)inDelegate
{
    
	self = [super init];
	if (self)
	{
        _contextMap = [NSMutableDictionary dictionary];
        _classMap = @{
                      @"com.cocoasplit.CocoaSplitESD.globalAudioMute": CSActionGlobalMute.class,
                      @"com.cocoasplit.CocoaSplitESD.toggleStaging": CSActionToggleStaging.class,
                      @"com.cocoasplit.CocoaSplitESD.goLive": CSActionGolive.class,
                      @"com.cocoasplit.CocoaSplitESD.InstantRecord": CSActionInstantRecord.class,
                      @"com.cocoasplit.CocoaSplitESD.SwapLayouts": CSActionSwapLayouts.class,
                      @"com.cocoasplit.CocoaSplitESD.ToggleStream": CSActionToggleStream.class,
                      @"com.cocoasplit.CocoaSplitESD.audioMute": CSActionMute.class,
                      @"com.cocoasplit.CocoaSplitESD.Transitions": CSActionTransition.class,
                      @"com.cocoasplit.CocoaSplitESD.ToggleUseTransition": CSActionToggleUseTransition.class,
                      @"com.cocoasplit.CocoaSplitESD.Layout": CSActionLayout.class,
                      @"com.cocoasplit.CocoaSplitESD.Output": CSActionOutput.class,
                      };
        
		_port = inPort;
		_pluginUUID = inPluginUUID;
		_registerEvent = inRegisterEvent;
		_delegate = inDelegate;
		[_delegate setConnectionManager:self];

		NSError *error = nil;
		NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[inInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
		
		NSDictionary *applicationInfo = json[@kESDSDKApplicationInfo];
		_applicationVersion = applicationInfo[@kESDSDKApplicationInfoVersion];
		_applicationPlatform = applicationInfo[@kESDSDKApplicationInfoPlatform];
		_applicationLanguage = applicationInfo[@kESDSDKApplicationInfoLanguage];
		
		_devicesInfo = json[@kESDSDKDevicesInfo];

        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(distributedNotificationMessage:) name:nil object:@"CocoaSplit" suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
		NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://localhost:%d", inPort]]];
		self.socket = [[SRWebSocket alloc] initWithURLRequest:urlRequest];
		self.socket.delegate = self;
		[self.socket open];
        
	}
    
	return self;
}


#pragma mark - APIs

-(void)distributedNotificationMessage:(NSNotification *)notification
{
    [_contextMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary *cMap = obj;
        [cMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            CSActionBase *action = obj;
            if ([notification.name isEqualToString:@"CSNotificationLaunchCompleted"])
            {
                [action cocoaSplitLaunched];
            } else {
                [action notificationReceived:notification];
            }
        }];
    }];
}


-(void)setTitle:(nullable NSString *)inTitle withContext:(id)inContext withTarget:(ESDSDKTarget)inTarget
{
	NSDictionary *json = nil;

	if(inTitle != NULL)
	{
		json = @{
				   @kESDSDKCommonEvent: @kESDSDKEventSetTitle,
				   @kESDSDKCommonContext: inContext,
				   @kESDSDKCommonPayload: @{
				   		@kESDSDKPayloadTitle: inTitle,
					   	@kESDSDKPayloadTarget: [NSNumber numberWithInt:inTarget]
					}
				   };
	}
	else
	{
		json = @{
				   @kESDSDKCommonEvent: @kESDSDKEventSetTitle,
				   @kESDSDKCommonContext: inContext,
				   @kESDSDKCommonPayload: @{
					   	@kESDSDKPayloadTarget: [NSNumber numberWithInt:inTarget]
					}
				   };
	}

	NSError *err = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&err];
	if (err == nil)
	{
		NSError *error = nil;
		[self.socket sendData:jsonData error:&error];
		if(error != nil)
		{
			NSLog(@"Failed to change the title due to error %@", error);
		}
	}
}

-(void)setImage:(NSString*)inBase64ImageString withContext:(id)inContext withTarget:(ESDSDKTarget)inTarget
{
	NSDictionary *json = @{
				   @kESDSDKCommonEvent: @kESDSDKEventSetImage,
				   @kESDSDKCommonContext: inContext,
				   @kESDSDKCommonPayload: @{
				   		@kESDSDKPayloadImage: inBase64ImageString,
					   	@kESDSDKPayloadTarget: [NSNumber numberWithInt:inTarget]
					}
				   };

	NSError *err = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&err];
	if (err == nil)
	{
		NSError *error = nil;
		[self.socket sendData:jsonData error:&error];
		if(error != nil)
		{
			NSLog(@"Failed to change the image due to error %@", error);
		}
	}
}

-(void)showAlertForContext:(id)inContext
{
	NSDictionary *json = @{
				   @kESDSDKCommonEvent: @kESDSDKEventShowAlert,
				   @kESDSDKCommonContext: inContext,
				   };

	NSError *err = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&err];
	if (err == nil)
	{
		NSError *error = nil;
		[self.socket sendData:jsonData error:&error];
		if(error != nil)
		{
			NSLog(@"Failed to show the alert due to error %@", error);
		}
	}
}

-(void)showOKForContext:(id)inContext
{
	NSDictionary *json = @{
				   @kESDSDKCommonEvent: @kESDSDKEventShowOK,
				   @kESDSDKCommonContext: inContext,
				   };

	NSError *err = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&err];
	if (err == nil)
	{
		NSError *error = nil;
		[self.socket sendData:jsonData error:&error];
		if(error != nil)
		{
			NSLog(@"Failed to show OK due to error %@", error);
		}
	}
}

-(void)setSettings:(NSDictionary *)inSettings forContext:(id)inContext
{
	NSDictionary *json = @{
				   @kESDSDKCommonEvent: @kESDSDKEventSetSettings,
				   @kESDSDKCommonContext: inContext,
				   @kESDSDKCommonPayload: inSettings
				   };
	
	NSError *err = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&err];
	if (err == nil)
	{
		NSError *error = nil;
		[self.socket sendData:jsonData error:&error];
		if(error != nil)
		{
			NSLog(@"Failed to change the settings due to error %@", error);
		}
	}
}

-(void)setState:(NSNumber *)inState forContext:(id)inContext
{
	if(inState != NULL)
	{
		NSDictionary *json = @{
				   @kESDSDKCommonEvent: @kESDSDKEventSetState,
				   @kESDSDKCommonContext: inContext,
				   @kESDSDKCommonPayload: @{
				   		@kESDSDKPayloadState: inState
					}
				   };
		
		NSError *err = nil;
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&err];
		if (err == nil)
		{
			NSError *error = nil;
			[self.socket sendData:jsonData error:&error];
			if(error != nil)
			{
				NSLog(@"Failed to change the state due to error %@", error);
			}
		}
	}
}

-(void)sendToPropertyInspector:(id)payload withContext:(id)inContext forAction:(NSString *)action
{
    
    NSDictionary *json = @{@kESDSDKCommonEvent: @kESDSDKEventSendToPropertyInspector,
                           @kESDSDKCommonContext: inContext,
                           @kESDSDKCommonAction: action,
                           @kESDSDKCommonPayload: payload
                           };
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&err];
    
    if (err == nil)
    {
        NSError *error = nil;
        [self.socket sendData:jsonData error:&error];
        
        if(error != nil)
        {
            NSLog(@"Failed to send payload to property inspector due to error %@", error);
            
        }
    } else {
        NSLog(@"ERROR");
    }
}


#pragma mark - WebSocket events

-(CSActionBase *)objectForAction:(NSString *)action withContext:(id)context
{
    CSActionBase *ret = nil;
    
    NSMutableDictionary *aMap = nil;
    aMap = _contextMap[action];
    if (aMap)
    {
        ret = aMap[context];
    }
    
    if (!ret)
    {
        Class useClass = _classMap[action];
        if (useClass)
        {
            ret = (CSActionBase *)[[useClass alloc] init];
            ret.actionName = action;
            ret.context = context;
            ret.connectionManager = self;
            if (!_contextMap[action])
            {
                _contextMap[action] = [NSMutableDictionary dictionary];
            }
            _contextMap[action][context] = ret;
        }
    }
    return ret;
}
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    
	@try
	{
		NSError *error = nil;
		NSDictionary *json = nil;
		if([message isKindOfClass:[NSString class]])
		{
			json = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
		}
		else if([message isKindOfClass:[NSData class]])
		{
			json = [NSJSONSerialization JSONObjectWithData:message options:NSJSONReadingMutableContainers error:&error];
		}

		NSString *event = json[@kESDSDKCommonEvent];
		id context = json[@kESDSDKCommonContext];
		NSString *action = json[@kESDSDKCommonAction];
		NSDictionary *payload = json[@kESDSDKCommonPayload];
		NSString *deviceID = json[@kESDSDKCommonDevice];

        CSActionBase *actionObj = [self objectForAction:action withContext:context];
        
        if([event isEqualToString:@kESDSDKEventApplicationDidLaunch])
        {
            for (NSString *actionName in _contextMap)
            {
                NSDictionary *cMap = _contextMap[actionName];
                for (id oContext in cMap)
                {
                    CSActionBase *sendObj = cMap[oContext];
                    if (sendObj)
                    {
                        [sendObj cocoaSplitLaunched];
                    }
                }
            }
            return;
        }
        
        if (!actionObj)
        {
            return;
        }
        
        actionObj.deviceID = deviceID;
        
        
        if ([event isEqualToString:@kESDSDKEventSendToPlugin])
        {
            [actionObj sendToPluginForAction:action withContext:context withPayload:payload forDevice:deviceID];
        } else if ([event isEqualToString:@kESDSDKEventKeyDown]) {
            [actionObj keyDownForAction:action withContext:context withPayload:payload forDevice:deviceID];
	 	}
		else if([event isEqualToString:@kESDSDKEventKeyUp])
	 	{
            [actionObj keyUpForAction:action withContext:context withPayload:payload forDevice:deviceID];
	 	}
	 	else if([event isEqualToString:@kESDSDKEventWillAppear])
	 	{
            [actionObj willAppearForAction:action withContext:context withPayload:payload forDevice:deviceID];
	 	}
	 	else if([event isEqualToString:@kESDSDKEventWillDisappear])
	 	{
            [actionObj willDisappearForAction:action withContext:context withPayload:payload forDevice:deviceID];
	 	}
	 	else if([event isEqualToString:@kESDSDKEventDeviceDidConnect])
	 	{
            NSDictionary *deviceInfo = json[@kESDSDKCommonDeviceInfo];
            if(deviceID != nil)
            {
                [actionObj deviceDidConnect:deviceID withDeviceInfo:deviceInfo];
            }
	 	}
	 	else if([event isEqualToString:@kESDSDKEventDeviceDidDisconnect])
	 	{
            if(deviceID != nil)
            {
                [actionObj deviceDidDisconnect:deviceID];
            }
	 	}
	 	else if([event isEqualToString:@kESDSDKEventApplicationDidLaunch])
	 	{
            for (NSString *actionName in _contextMap)
            {
                NSDictionary *cMap = _contextMap[actionName];
                for (id oContext in cMap)
                {
                    CSActionBase *sendObj = cMap[oContext];
                    if (sendObj)
                    {
                        //[sendObj cocoaSplitLaunched];
                    }
                }
            }
	 	}
	 	else if([event isEqualToString:@kESDSDKEventApplicationDidTerminate])
	 	{
            [actionObj applicationDidTerminate:payload];
	 	}
	}
	@catch(...)
	{
		NSLog(@"Failed to parse the JSON data: %@", message);
	}
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
	NSDictionary *registerJson = @{
				   @kESDSDKCommonEvent: self.registerEvent,
				   @kESDSDKRegisterUUID: self.pluginUUID };

	NSError *err = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:registerJson options:NSJSONWritingPrettyPrinted error:&err];
	if (err == nil)
	{
		NSError *error = nil;
		[self.socket sendData:jsonData error:&error];
		if(error != nil)
		{
			NSLog(@"Failed to register the plugin due to error %@", error);
		}
	}
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
	NSLog(@"The socket could not be opened due to the error %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
	NSLog(@"Websocket closed with reason: %@", reason);
	
	// The socket has been closed so we just quit
	exit(0);
}

-(void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:nil object:@"CocoaSplit"];
}

@end
