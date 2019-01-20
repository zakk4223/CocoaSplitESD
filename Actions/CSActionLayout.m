//
//  CSActionLayout.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/11/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionLayout.h"
#import "ESDConnectionManager.h"

@implementation CSActionLayout
@synthesize selectedLayout = _selectedLayout;

-(void)setSelectedLayout:(CocoaSplitLayout *)selectedLayout
{
    _selectedLayout = selectedLayout;
    [self.connectionManager setTitle:_selectedLayout.name withContext:self.context withTarget:kESDSDKTarget_HardwareAndSoftware];
    
}

-(CocoaSplitLayout *)selectedLayout
{
    return _selectedLayout;
}


-(void)updateSelectedLayout:(NSString *)uuid
{

    if (!self.csRunning)
    {
        return;
    }
    
    CocoaSplitLayout *layout = nil;
    if (uuid)
    {
        
        SBElementArray *layouts = self.csApp.layouts;
        layout = [layouts objectWithID:uuid];
    }
    
    self.selectedLayout = layout;
}


-(void)updateLayoutState
{
    if (!self.csRunning)
    {
        return;
    }
    
    NSString *imagePath = GetResourcePath(@"img/Layout.png");
    if (self.selectedLayout)
    {
        CGColorRef useColor = NULL;
        bool in_staging = self.selectedLayout.inStaging;
        bool in_live = self.selectedLayout.inLive;
        if (in_staging && in_live)
        {
            useColor = CGColorCreateGenericRGB(1.0f, 1.0f, 0.0f, 1.0f);
        } else if (in_staging) {
            useColor = CGColorCreateGenericRGB(0.0f, 1.0f, 0.0f, 1.0f);
        } else if (in_live) {
            useColor = CGColorCreateGenericRGB(1.0f, 0.0f, 0.0f, 1.0f);
        } else {
            useColor = CGColorCreateGenericRGB(0.0f, 0.0f, 0.0f, 0.0f);
        }
        
        CGImageRef layoutImg = RenderImageWithBackgroundColor(imagePath, useColor);
        CGColorRelease(useColor);
        if (layoutImg)
        {
            NSString *imgString = CreateBase64EncodedStringForImage(layoutImg);
            CGImageRelease(layoutImg);
            
            if (imgString)
            {
                [self.connectionManager setImage:imgString withContext:self.context withTarget:kESDSDKTarget_HardwareAndSoftware];
                
            }
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
            NSString *useLayout = settings[@"selectedLayout"];
            
            [self updateSelectedLayout:useLayout];
            if (self.selectedLayout)
            {
                NSString *layoutAction = settings[@"layoutAction"];
                NSString *layoutOrder = settings[@"layoutOrder"];
                
                if ([layoutAction isEqualToString:@"replace"])
                {
                    [self.selectedLayout replaceWithUsing:self.csApp.activelayout];
                } else if ([layoutAction isEqualToString:@"merge"]) {
                    [self.selectedLayout toggleUsing:self.csApp.activelayout order:layoutOrder];
                }
            }
        }
    }
}

- (void)saveSettings:(NSString *)action withContext:(id)context withSettings:(NSDictionary *)settings forDevice:(NSString *)deviceID
{
    [super saveSettings:action withContext:context withSettings:settings forDevice:deviceID];
    [self updateSelectedLayout:self.settings[@"selectedLayout"]];
    [self updateLayoutState];
    
}

-(void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [super willAppearForAction:action withContext:context withPayload:payload forDevice:deviceID];
    [self updateSelectedLayout:self.settings[@"selectedLayout"]];
    [self updateLayoutState];
}


-(void)sendLayoutsToPI
{
    if (self.csRunning)
    {
        NSMutableArray *payloadLayouts = [NSMutableArray array];
        NSArray *layouts = [[self.csApp layouts] get];
        
        for (CocoaSplitLayout *lyt in layouts)
        {
            
            [payloadLayouts addObject:@{@"name": [lyt name], @"uuid": [lyt id]}];
            
        }
        
        NSDictionary *piPayload = @{@"layouts": payloadLayouts};
        
        [self.connectionManager sendToPropertyInspector:piPayload withContext:self.context forAction:self.actionName];
    }
}

-(void)sendToPluginForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [super sendToPluginForAction:action withContext:context withPayload:payload forDevice:deviceID];
    
    if (payload[@kESDSDKRegisterPropertyInspector] && self.csRunning)
    {
        [self sendLayoutsToPI];
    }
}

-(void)cocoaSplitLaunched
{
    [self updateSelectedLayout:self.settings[@"selectedLayout"]];
    [self updateLayoutState];
    
    
}
-(void)notificationReceived:(NSNotification *)notification
{
    
    if (!self.csRunning)
    {
        return;
    }
    
    if ([notification.name isEqualToString:@"CSNotificationLayoutAdded"] || [notification.name isEqualToString:@"CSNotificationLayoutDeleted"]) {
        [self sendLayoutsToPI];
        [self updateLayoutState];
    } else if ([notification.name isEqualToString:@"CSNotificationLayoutInStagingChanged"] || [notification.name isEqualToString:@"CSNotificationLayoutInLiveChanged"])
    {
        if (self.selectedLayout)
        {
            [self updateLayoutState];
        }
    }
}
@end
