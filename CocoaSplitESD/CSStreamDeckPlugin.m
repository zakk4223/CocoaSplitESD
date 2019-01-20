//
//  CSStreamDeckPlugin.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/8/19.
//

#import "CSStreamDeckPlugin.h"

@implementation CSStreamDeckPlugin



-(void)sendToPluginForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    if ([action containsString:@"streamMute"])
    {
        if (payload[@"propertyInspectorConnected"])
        {
            
            CocoaSplitApplication *app = [SBApplication applicationWithBundleIdentifier:@"zakk.lol.CocoaSplit"];
            if (app)
            {
                
                NSMutableArray *payloadInputs = [NSMutableArray array];
                NSArray *audioInputs = [[app audioInputs] get];
                for (CocoaSplitAudioInput *inp in audioInputs)
                {
                    [payloadInputs addObject:@{@"name": inp.name}];
                }
                
                NSDictionary *payload = @{@"audioInputs": payloadInputs};
                [self.connectionManager sendToPropertyInspector:payload withContext:context forAction:action];
                
            }
        }
    }
    
}
-(void)keyDownForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    
}

-(void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    
    if ([action containsString:@"streamMute"])
    {
        
        CocoaSplitApplication *app = [SBApplication applicationWithBundleIdentifier:@"zakk.lol.CocoaSplit"];
        if (app)
        {
            CocoaSplitAudioInput *streamAudio = app.streamAudio;
            streamAudio.muted = !streamAudio.muted;
        }
        //[CSAppleScript toggleMuteForInput:@"streamAudio"];
    }
}

- (void)deviceDidConnect:(NSString *)deviceID withDeviceInfo:(NSDictionary *)deviceInfo
{
    // Nothing to do
}

- (void)deviceDidDisconnect:(NSString *)deviceID
{
    // Nothing to do
}

- (void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    NSDictionary *settings = payload[@"settings"];
    
    if (settings)
    {
        [self.connectionManager sendToPropertyInspector:@{@"settings": settings} withContext:context forAction:action];
        [self.connectionManager setTitle:settings[@"selectedAudio"] withContext:context withTarget:kESDSDKTarget_HardwareAndSoftware];
    }
}

- (void)willDisappearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
}

-(void)saveSettings:(NSString *)action withContext:(id)context withSettings:(NSDictionary *)settings forDevice:(NSString *)deviceID
{
    [self.connectionManager setSettings:settings forContext:context];
}


@end
