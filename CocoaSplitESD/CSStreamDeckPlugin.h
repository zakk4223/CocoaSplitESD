//
//  CSStreamDeckPlugin.h
//  CocoaSplitESD
//
//  Created by Zakk on 1/8/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESDEventsProtocol.h"
#import "ESDConnectionManager.h"
#import "CSAppleScript.h"
#import "CocoaSplitSB.h"


NS_ASSUME_NONNULL_BEGIN

@interface CSStreamDeckPlugin : NSObject <ESDEventsProtocol>
@property (weak) ESDConnectionManager *connectionManager;

- (void)keyDownForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;
- (void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;
- (void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;
- (void)willDisappearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;

- (void)deviceDidConnect:(NSString *)deviceID withDeviceInfo:(NSDictionary *)deviceInfo;
- (void)deviceDidDisconnect:(NSString *)deviceID;

- (void)applicationDidLaunch:(NSDictionary *)applicationInfo;
- (void)applicationDidTerminate:(NSDictionary *)applicationInfo;
- (void)saveSettings:(NSString *)action withContext:(id)context withSettings:(NSDictionary *)settings forDevice:(NSString *)deviceID;

@end

NS_ASSUME_NONNULL_END
