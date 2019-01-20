//
//  CSActionToggleUseTransition.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/11/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionToggleUseTransition.h"
#import "ESDConnectionManager.h"

@implementation CSActionToggleUseTransition

-(void)updateState
{
    if (!self.csRunning)
    {
        return;
    }
    
    if (self.csApp.useTransitions)
    {
        [self.connectionManager setState:@0 forContext:self.context];
    } else {
        [self.connectionManager setState:@1 forContext:self.context];
    }
}



-(void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [super willAppearForAction:action withContext:context withPayload:payload forDevice:deviceID];
    [self updateState];
}

-(void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    if (self.csRunning)
    {
        self.csApp.useTransitions = !self.csApp.useTransitions;
        [self updateState];
    }
}

-(void)cocoaSplitLaunched
{
    [self updateState];
}

-(void)notificationReceived:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"CSNotificationUseTransitionsChanged"])
    {
        [self updateState];
    }
}
@end
