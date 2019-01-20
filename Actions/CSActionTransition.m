//
//  CSActionTransition.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/11/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionTransition.h"
#import "ESDConnectionManager.h"

@implementation CSActionTransition
@synthesize selectedTransition = _selectedTransition;

-(void)updateSelectedTransition:(NSString *)uuid
{
    if (!self.csRunning)
    {
        return;
    }
    
    if (uuid)
    {
        CocoaSplitTransition *transition = nil;
        SBElementArray *transitions = self.csApp.transitions;
        transition = [transitions objectWithID:uuid];
        self.selectedTransition = transition;
    } else {
        self.selectedTransition = nil;
    }
}

-(void)updateState
{
    if (!self.csRunning)
    {
        return;
    }
    
    if (!self.selectedTransition)
    {
        return;
    }
    
    CGColorRef bgColor = NULL;
    if (self.selectedTransition.active)
    {
        if (self.selectedTransition.isToggle)
        {
            bgColor = CGColorCreateGenericRGB(0.0f, 1.0f, 0.0f, 1.0f);
        } else {
            bgColor = CGColorCreateGenericRGB(1.0f, 0.0f, 0.0f, 1.0f);
        }
    } else {
        bgColor = CGColorCreateGenericRGB(0.0f, 0.f, 0.0f, 0.0f);
        
    }
    
    NSString *imagePath = GetResourcePath(@"img/Transition.png");
    CGImageRef transitionImg = RenderImageWithBackgroundColor(imagePath, bgColor);
    CGColorRelease(bgColor);
    if (transitionImg)
    {
        NSString *imgString = CreateBase64EncodedStringForImage(transitionImg);
        CGImageRelease(transitionImg);
        if (imgString)
        {
            [self.connectionManager setImage:imgString withContext:self.context withTarget:kESDSDKTarget_HardwareAndSoftware];
        }
    }
}

-(void)setSelectedTransition:(CocoaSplitTransition *)selectedTransition
{
    _selectedTransition = selectedTransition;
    [self.connectionManager setTitle:_selectedTransition.name withContext:self.context withTarget:kESDSDKTarget_HardwareAndSoftware];
}

-(CocoaSplitTransition *)selectedTransition
{
    return _selectedTransition;
}


-(void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    
    if (self.csRunning)
    {
        NSDictionary *settings = payload[@"settings"];
        if (settings)
        {
            NSString *useTransition = settings[@"selectedTransition"];
            [self updateSelectedTransition:useTransition];
            if (self.selectedTransition)
            {
                NSString *transitionAction = settings[@"transitionAction"];
                
                if ([transitionAction isEqualToString:@"toggleUse"])
                {
                    [self.selectedTransition toggleLive];
                } else if ([transitionAction isEqualToString:@"activate"]) {
                    [self.selectedTransition toggle];
                }
            }
        }
    }
}

-(void)sendTransitionsToPI
{
    if (self.csRunning)
    {
        NSMutableArray *payloadTransitions = [NSMutableArray array];
        NSArray *transitions = [[self.csApp transitions] get];
        for (CocoaSplitTransition *trt in transitions)
        {
            [payloadTransitions addObject:@{@"name": trt.name, @"uuid": [trt id]}];

        }
        NSDictionary *payload  = @{@"transitions": payloadTransitions};
        [self.connectionManager sendToPropertyInspector:payload withContext:self.context forAction:self.actionName];
    }
}


- (void)saveSettings:(NSString *)action withContext:(id)context withSettings:(NSDictionary *)settings forDevice:(NSString *)deviceID
{
    [super saveSettings:action withContext:context withSettings:settings forDevice:deviceID];
    [self updateSelectedTransition:self.settings[@"selectedTransition"]];
    [self updateState];
}

-(void)sendToPluginForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [super sendToPluginForAction:action withContext:context withPayload:payload forDevice:deviceID];
    
    if (payload[@kESDSDKRegisterPropertyInspector] && self.csRunning)
    {
        [self sendTransitionsToPI];
    }
}

-(void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [super willAppearForAction:action withContext:context withPayload:payload forDevice:deviceID];
    [self updateSelectedTransition:self.settings[@"selectedTransition"]];
    [self updateState];
}

-(void)cocoaSplitLaunched
{
    [self updateSelectedTransition:self.settings[@"selectedTransition"]];
    [self updateState];
    [self sendTransitionsToPI];
}

-(void)notificationReceived:(NSNotification *)notification
{
    if (!self.csRunning)
    {
        return;
    }
    
    
    if ([notification.name isEqualToString:@"CSNotificationTransitionAdded"] || [notification.name isEqualToString:@"CSNotificationTransitionRemoved"])
    {
        [self sendTransitionsToPI];
        [self updateState];
    } else if ([notification.name isEqualToString:@"CSNotificationTransitionStateChanged"]) {
        if (self.selectedTransition)
        {
            if (notification.userInfo && [notification.userInfo[@"uuid"] isEqualToString:[self.selectedTransition id]])
            {
                [self updateState];
            }
        }
    }
    
    
}


@end
