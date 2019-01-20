//
//  CSActionMute.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/10/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionMute.h"
#import "ESDConnectionManager.h"

@implementation CSActionMute
@synthesize selectedAudio = _selectedAudio;


-(void)updateSelectedAudio:(NSString *)uuid
{
    if (!self.csRunning)
    {
        return;
    }
    
    NSString *useAudio = uuid;
    
    if (useAudio)
    {
        CocoaSplitAudioInput *audioDev = nil;
        SBElementArray *audioDevs = self.csApp.audioInputs;
        audioDev = [audioDevs objectWithID:uuid];
        self.selectedAudio = audioDev;
    } else {
        self.selectedAudio = nil;
    }
}
-(void)updateState
{
    if (!self.csRunning)
    {
        return;
    }
    
    if (self.selectedAudio)
    {
        bool isEnabled = self.selectedAudio.enabled;
        if (isEnabled)
        {
            [self.connectionManager setState:@0 forContext:self.context];
        } else {
            [self.connectionManager setState:@1 forContext:self.context];
        }
    }
}

-(void)setSelectedAudio:(CocoaSplitAudioInput *)selectedAudio
{
    _selectedAudio = selectedAudio;
    [self.connectionManager setTitle:_selectedAudio.name withContext:self.context withTarget:kESDSDKTarget_HardwareAndSoftware];
}

-(CocoaSplitAudioInput *)selectedAudio
{
    return _selectedAudio;
}


-(void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    
    if (self.csRunning)
    {
        NSDictionary *settings = payload[@"settings"];
        if (settings)
        {
            NSString *useAudio = settings[@"selectedAudio"];
            
            [self updateSelectedAudio:useAudio];
            if (self.selectedAudio)
            {
                self.selectedAudio.enabled = !self.selectedAudio.enabled;
            }
        }
    }
}

- (void)saveSettings:(NSString *)action withContext:(id)context withSettings:(NSDictionary *)settings forDevice:(NSString *)deviceID
{
    [super saveSettings:action withContext:context withSettings:settings forDevice:deviceID];
    [self updateSelectedAudio:self.settings[@"selectedAudio"]];
    [self updateState];
}

-(void)sendAudioOuputsToPI
{
    if (self.csRunning)
    {
        NSMutableArray *payloadInputs = [NSMutableArray array];
        NSArray *audioInputs = [[self.csApp audioInputs] get];
        for (CocoaSplitAudioInput *inp in audioInputs)
        {
            [payloadInputs addObject:@{@"name": inp.name, @"uuid": [inp id]}];
        }
        
        NSDictionary *payload = @{@"audioInputs": payloadInputs};
        
        [self.connectionManager sendToPropertyInspector:payload withContext:self.context forAction:self.actionName];
    }
}
-(void)sendToPluginForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [super sendToPluginForAction:action withContext:context withPayload:payload forDevice:deviceID];
    
    if (payload[@kESDSDKRegisterPropertyInspector] && self.csRunning)
    {
        [self sendAudioOuputsToPI];
    }
}

-(void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [super willAppearForAction:action withContext:context withPayload:payload forDevice:deviceID];
    [self updateSelectedAudio:self.settings[@"selectedAudio"]];
    [self updateState];

}

-(void)cocoaSplitLaunched
{
    [self updateSelectedAudio:self.settings[@"selectedAudio"]];
    [self updateState];
    [self sendAudioOuputsToPI];

}


-(void)notificationReceived:(NSNotification *)notification
{
    
    if ([notification.name isEqualToString:@"CSNotificationAudioEnabled"] || [notification.name isEqualToString:@"CSNotificationAudioDisabled"])
    {
        if (!self.csRunning)
        {
            return;
        }
        
        if (self.selectedAudio)
        {
            if (notification.userInfo && [notification.userInfo[@"uuid"] isEqualToString:self.selectedAudio.id])
            {
                [self updateState];
            }
        }
    } else if ([notification.name isEqualToString:@"CSNotificationAudioAdded"]) {
        [self sendAudioOuputsToPI];
        [self updateState];
        
    }
}
@end
