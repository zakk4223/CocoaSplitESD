//
//  CSActionOutput.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/11/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionOutput.h"
#import "ESDConnectionManager.h"

@implementation CSActionOutput
@synthesize selectedOutput = _selectedOutput;

-(void)setSelectedOutput:(CocoaSplitOutput *)selectedOutput
{
    _selectedOutput = selectedOutput;
    [self.connectionManager setTitle:_selectedOutput.name withContext:self.context withTarget:kESDSDKTarget_HardwareAndSoftware];
}

-(CocoaSplitOutput *)selectedOutput
{
    return _selectedOutput;
}


-(void)updateSelectedOutput:(NSString *)uuid
{
    if (!self.csRunning)
    {
        return;
    }
    
    if (uuid)
    {
        CocoaSplitOutput *output = nil;
        SBElementArray *outputs = self.csApp.outputs;
        output = [outputs objectWithID:uuid];
        self.selectedOutput = output;
    } else {
        self.selectedOutput = nil;
    }
}

-(void)updateState
{
    if (!self.csRunning)
    {
        return;
    }
    
    bool sendAlert = NO;
    NSString *imgName = @"img/Output.png";
    
    if (self.selectedOutput)
    {
        if (self.selectedOutput.running)
        {
            imgName = @"img/OutputOK.png";
            if (self.selectedOutput.errored)
            {
                imgName = @"img/OutputError.png";
                sendAlert = YES;
            } else if (self.selectedOutput.isDraining) {
                imgName = @"img/OutputDrain.png";
            }
        }
    }
    
    NSString *fullPath = GetResourcePath(imgName);
    CGColorRef bgColor = CGColorCreateGenericRGB(0.0f, 0.0f, 0.0f, 0.0f);
    CGImageRef oImg = RenderImageWithBackgroundColor(fullPath, bgColor);
    CGColorRelease(bgColor);
    NSString *imgStr = CreateBase64EncodedStringForImage(oImg);
    CGImageRelease(oImg);
    [self.connectionManager setImage:imgStr withContext:self.context withTarget:kESDSDKTarget_HardwareAndSoftware];
    if (sendAlert)
    {
        [self.connectionManager showAlertForContext:self.context];
    }
    return;
}


-(void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    
    if (self.csRunning)
    {
        NSDictionary *settings = payload[@"settings"];
        if (settings)
        {
            NSString *useOutput = settings[@"selectedOutput"];
            [self updateSelectedOutput:useOutput];
            if (self.selectedOutput)
            {
                self.selectedOutput.active = !self.selectedOutput.active;
            }
            
        }
    }
}

-(void)sendOutputsToPI
{
    if (self.csRunning)
    {
        NSMutableArray *payloadOutputs = [NSMutableArray array];
        NSArray *outputs = [[self.csApp outputs] get];
        for (CocoaSplitOutput *outp in outputs)
        {
            [payloadOutputs addObject:@{@"name": outp.name, @"uuid": [outp id]}];
        }
        NSDictionary *payload = @{@"outputs": payloadOutputs};
        [self.connectionManager sendToPropertyInspector:payload withContext:self.context forAction:self.actionName];
    }
}


- (void)saveSettings:(NSString *)action withContext:(id)context withSettings:(NSDictionary *)settings forDevice:(NSString *)deviceID
{
    [super saveSettings:action withContext:context withSettings:settings forDevice:deviceID];
    [self updateSelectedOutput:self.settings[@"selectedOutput"]];
    [self updateState];
}

-(void)sendToPluginForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [super sendToPluginForAction:action withContext:context withPayload:payload forDevice:deviceID];
    
    if (payload[@kESDSDKRegisterPropertyInspector] && self.csRunning)
    {
        [self sendOutputsToPI];
    }
}

-(void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [super willAppearForAction:action withContext:context withPayload:payload forDevice:deviceID];
    [self updateSelectedOutput:self.settings[@"selectedOutput"]];
    [self updateState];
}

-(void)cocoaSplitLaunched
{
    [self updateSelectedOutput:self.settings[@"selectedOutput"]];
    [self updateState];
    [self sendOutputsToPI];
}

-(void)notificationReceived:(NSNotification *)notification
{
    
    if (!self.csRunning)
    {
        return;
    }
    
    
    if ([notification.name isEqualToString:@"CSNotificationOutputAdded"] || [notification.name isEqualToString:@"CSNotificationOutputDeleted"])
    {
        [self sendOutputsToPI];
        [self updateState];
    } else if ([notification.name containsString:@"CSNotificationOutput"]) {
        if (self.selectedOutput)
        {
            if (notification.userInfo && [notification.userInfo[@"uuid"] isEqualToString:[self.selectedOutput id]])
            {
                [self updateState];
            }
        }
    }
}
@end
