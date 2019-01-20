//
//  CSActionBase.h
//  CocoaSplitESD
//
//  Created by Zakk on 1/9/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESDEventsProtocol.h"
#import "CocoaSplitSB.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSActionBase : NSObject <ESDEventsProtocol>

@property (strong) NSString *actionName;
@property (strong) id context;
@property (strong) NSMutableDictionary *settings;
@property (weak) ESDConnectionManager *connectionManager;
@property (strong) NSString *deviceID;
@property (readonly) CocoaSplitApplication *csApp;
@property (readonly) bool csRunning;

- (void)keyDownForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;
- (void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;

- (void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;
- (void)willDisappearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;

- (void)deviceDidConnect:(NSString *)deviceID withDeviceInfo:(NSDictionary *)deviceInfo;
- (void)deviceDidDisconnect:(NSString *)deviceID;

- (void)applicationDidLaunch:(NSDictionary *)applicationInfo;
- (void)applicationDidTerminate:(NSDictionary *)applicationInfo;
- (void)sendToPluginForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;
- (void)saveSettings:(NSString *)action withContext:(id)context withSettings:(NSDictionary *)settings forDevice:(NSString *)deviceID;
-(void)messageFromPropertyInspector:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;
-(void)notificationReceived:(NSNotification *)notification;
-(void)cocoaSplitLaunched;
-(void)cocoaSplitExited;
@end

NSString * GetResourcePath(NSString *inFilename);
CGContextRef CreateBitmapContext(CGSize inSize);
CGImageRef __nullable RenderImageWithBackgroundColor(NSString *imageFilename, CGColorRef bgColor);
NSString *CreateBase64EncodedStringForImage(CGImageRef img);

NS_ASSUME_NONNULL_END
