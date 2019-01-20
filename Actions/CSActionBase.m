//
//  CSActionBase.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/9/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionBase.h"
#import "ESDConnectionManager.h"
#import "ESDUtilities.h"

@implementation CSActionBase

-(CocoaSplitApplication *)csApp
{
    CocoaSplitApplication *retApp = [SBApplication applicationWithBundleIdentifier:@"zakk.lol.CocoaSplit"];
    return retApp;
}

-(bool)csRunning
{
    if (!self.csApp)
    {
        return NO;
    }
    
    return self.csApp.isRunning;
}


- (void)keyDownForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [self.connectionManager sendToPropertyInspector:@{@"pluginWantsSave": @YES} withContext:self.context forAction:self.actionName];
    return;
}

- (void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    return;
}

- (void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    NSDictionary *settings = payload[@kESDSDKPayloadSettings];
    if (!settings)
    {
        settings = @{};
    }
    self.settings = settings.mutableCopy;
    return;
}


- (void)willDisappearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    [self saveSettings:self.actionName withContext:self.context withSettings:self.settings
             forDevice:self.deviceID];
    return;
}

- (void)deviceDidConnect:(NSString *)deviceID withDeviceInfo:(NSDictionary *)deviceInfo
{
    return;
}

- (void)deviceDidDisconnect:(NSString *)deviceID
{
    return;
}

- (void)applicationDidLaunch:(NSDictionary *)applicationInfo
{
    return;
}

- (void)applicationDidTerminate:(NSDictionary *)applicationInfo
{
    return;
}

- (void)sendToPluginForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    
    NSDictionary *saveData = payload[@kESDSDKPayloadRequestsSave];
    if (saveData)
    {
        
        [self saveSettings:self.actionName withContext:self.context withSettings:saveData
                 forDevice:self.deviceID];
        
        return;
    }
    

    if (payload[@kESDSDKRegisterPropertyInspector])
    {
        
        [self.connectionManager sendToPropertyInspector:@{@"settings": self.settings} withContext:self.context forAction:self.actionName];
    }
    return;
    
}

- (void)saveSettings:(NSString *)action withContext:(id)context withSettings:(NSDictionary *)settings forDevice:(NSString *)deviceID
{
    
    [self.connectionManager setSettings:settings forContext:context];
    self.settings = settings.mutableCopy;
    
    
}

-(void)messageFromPropertyInspector:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    return;
}
-(void)notificationReceived:(NSNotification *)notification
{
    return;
}

-(void)cocoaSplitLaunched
{
    return;
}
-(void)cocoaSplitExited
{
    return;
}
@end

NSString * GetResourcePath(NSString *inFilename)
{
    NSString *outPath = nil;
    
    if([inFilename length] > 0)
    {
        NSString * bundlePath = [ESDUtilities pluginPath];
        if(bundlePath != nil)
        {
            outPath = [bundlePath stringByAppendingPathComponent:inFilename];
        }
    }
    
    return outPath;
}

CGContextRef CreateBitmapContext(CGSize inSize)
{
    CGFloat bitmapBytesPerRow = inSize.width * 4;
    CGFloat bitmapByteCount = (bitmapBytesPerRow * inSize.height);
    
    //void *bitmapData = calloc(bitmapByteCount, 1);
    //if(bitmapData == NULL)
  //  {
  //     return NULL;
  //  }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, inSize.width, inSize.height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    if(context == NULL)
    {
        CGColorSpaceRelease(colorSpace);
        //free(bitmapData);
        return NULL;
    }
    else
    {
        CGColorSpaceRelease(colorSpace);
        return context;
    }
}

CGImageRef __nullable RenderImageWithBackgroundColor(NSString *imageFilename, CGColorRef bgColor)
{
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imageFilename];
    if (!image)
    {
        return NULL;
    }
    
    CGSize imgSize = CGSizeMake(72,72);
    CGRect imgRect = CGRectMake(0, 0, imgSize.width, imgSize.height);
    CGImageRef imageRef = [image CGImageForProposedRect:&imgRect context:NULL hints:nil];
    if (!imageRef)
    {
        return NULL;
    }
    CGContextRef cgContext = CreateBitmapContext(imgSize);
    if (!cgContext)
    {
        return NULL;
    }
    
    CGContextSetFillColorWithColor(cgContext, bgColor);
    CGContextFillRect(cgContext, imgRect);
    CGContextDrawImage(cgContext, imgRect, imageRef);
    CGImageRef returnImg = CGBitmapContextCreateImage(cgContext);
    CFRelease(cgContext);
    //CFRelease(imageRef);
    return returnImg;
}

NSString *CreateBase64EncodedStringForImage(CGImageRef img)
{
    NSString *outStr = nil;
    if (img)
    {
        CFMutableDataRef imgData = CFDataCreateMutable(kCFAllocatorDefault, 0);
        if (imgData)
        {
            CGImageDestinationRef destinationRef = CGImageDestinationCreateWithData(imgData, kUTTypePNG, 1, NULL);
            if (destinationRef)
            {
                CGImageDestinationAddImage(destinationRef, img, nil);
                if (CGImageDestinationFinalize(destinationRef))
                {
                    NSString *base64PNG = [(__bridge NSData *)imgData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
                    if (base64PNG.length > 0)
                    {
                        outStr = [NSString stringWithFormat:@"data:image/png;base64,%@\">", base64PNG];
                    }
                }
                CFRelease(destinationRef);
            }
            CFRelease(imgData);
        }
    }
    return outStr;
}
