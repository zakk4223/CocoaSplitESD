//
//  CSActionToggleStream.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/10/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionToggleStream.h"
#import "ESDConnectionManager.h"
@implementation CSActionToggleStream

-(void)updateState
{
    if (!self.csRunning)
    {
        return;
    }
    NSNumber *initialState = @0;
    if (self.csApp && self.csApp.streamRunning)
    {
        initialState = @1;
    }
    
    [self.connectionManager setState:initialState forContext:self.context];
}

-(void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    if (!self.csRunning)
    {
        return;
    }
    
    if (!self.csApp.streamRunning)
    {
        [self.csApp startStream];
    } else {
        [self.csApp stopStream];
    }
    
}

-(void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [super willAppearForAction:action withContext:context withPayload:payload forDevice:deviceID];
    [self updateState];
}

-(void)notificationReceived:(NSNotification *)notification
{
    [self updateState];
}

-(void)cocoaSplitLaunched
{
    [self updateState];
}
@end
