//
//  CSActionToggleStaging.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/9/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionToggleStaging.h"
#import "ESDConnectionManager.h"
@implementation CSActionToggleStaging

-(void)updateState
{
    if (!self.csRunning)
    {
        return;
    }
    
    NSString *liveUUID = [self.csApp.livelayout id];
    NSString *activeUUID = [self.csApp.activelayout id];
    NSString *stagingUUID = [self.csApp.staginglayout id];
    
    if (self.csApp.stagingEnabled)
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
        [self.csApp toggleStagingView];
    }
}

-(void)cocoaSplitLaunched
{
    [self updateState];
}
-(void)notificationReceived:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"CSNotificationLayoutModeChanged"])
    {
        [self updateState];
    }
}

@end
