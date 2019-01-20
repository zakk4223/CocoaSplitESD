//
//  CSAppleScript.h
//  CocoaSplitESD
//
//  Created by Zakk on 1/8/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSAppleScript : NSObject
+(void)toggleMuteForInput:(NSString *)inputString;
+(bool)fetchCSMuteStatus:(NSString *)inputString;
+(NSAppleEventDescriptor *)executeAppleScript:(NSString *)aScript;
+(NSArray *)audioInputs;

@end

NS_ASSUME_NONNULL_END
