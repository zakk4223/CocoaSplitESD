//
//  CSActionGlobalMute.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/9/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionGlobalMute.h"
#import "ESDConnectionManager.h"

@implementation CSActionGlobalMute

@synthesize selectedAudio = _selectedAudio;

-(void)setSelectedAudio:(CocoaSplitAudioInput *)selectedAudio
{
    _selectedAudio = selectedAudio;
    [self.connectionManager setTitle:_selectedAudio.name withContext:self.context withTarget:kESDSDKTarget_HardwareAndSoftware];
}

-(CocoaSplitAudioInput *)selectedAudio
{
    return _selectedAudio;
}


-(void)updateSelectedAudio:(NSString *)audioval
{
    if (audioval && self.csRunning)
    {
        CocoaSplitAudioInput *audioDev = nil;
        if ([audioval isEqualToString:@"stream"])
        {
            audioDev = self.csApp.streamAudio;
        } else if ([audioval isEqualToString:@"preview"]) {
            audioDev = self.csApp.previewAudio;
        }
        self.selectedAudio = audioDev;
    } else {
        self.selectedAudio = nil;
    }
}


-(void)updateState
{
    if (self.selectedAudio && self.csRunning)
    {
        if (self.selectedAudio.enabled)
        {
            [self.connectionManager setState:@0 forContext:self.context];
        } else {
            [self.connectionManager setState:@1 forContext:self.context];

        }
    }
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

-(void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [super willAppearForAction:action withContext:context withPayload:payload forDevice:deviceID];
    [self updateSelectedAudio:self.settings[@"selectedAudio"]];
}


-(void)cocoaSplitLaunched
{
    [self updateSelectedAudio:self.settings[@"selectedAudio"]];
    [self updateState];
}


-(void)notificationReceived:(NSNotification *)notification
{
    if (!self.csRunning)
    {
        return;
    }
    
    
    if ([notification.name isEqualToString:@"CSNotificationAudioEnabled"] || [notification.name isEqualToString:@"CSNotificationAudioDisabled"])
    {
        if (self.selectedAudio)
        {
            if (notification.userInfo && [notification.userInfo[@"uuid"] isEqualToString:[self.selectedAudio id]])
            {
                [self updateState];
            }
        }
    }
}

@end
