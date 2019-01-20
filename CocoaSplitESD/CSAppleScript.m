//
//  CSAppleScript.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/8/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSAppleScript.h"

@implementation CSAppleScript


+(NSAppleEventDescriptor *)executeAppleScript:(NSString *)aScript
{
    NSString *useString = [NSString stringWithFormat:@"tell application \"CocoaSplit\"\n %@ \n end tell", aScript];
    NSAppleScript *useScript = [[NSAppleScript alloc] initWithSource:useString];
    NSAppleEventDescriptor *eDesc = [useScript executeAndReturnError:nil];
    return eDesc;
}

+(NSArray *)audioInputs
{
    NSMutableArray *ret = [NSMutableArray array];
    NSAppleEventDescriptor *eDesc = [self executeAppleScript:@"get properties of audioInputs"];
    if (eDesc)
    {
        NSAppleEventDescriptor *listDesc = [eDesc coerceToDescriptorType:typeAEList];
        
        for (NSInteger i = 1; i <= listDesc.numberOfItems; i++)
        {
            NSAppleEventDescriptor *inputDesc = [listDesc descriptorAtIndex:i];
            
        }
    }
    
    return ret;
}

+(void)toggleMuteForInput:(NSString *)inputString
{
    bool muteStatus = [self fetchCSMuteStatus:@"streamAudio"];
    NSString *mAction = @"mute";
    if (muteStatus)
    {
        mAction = @"unmute";
    }
    
    NSString *muteScript = [NSString stringWithFormat:@"%@ %@", mAction, inputString];
    
    NSAppleEventDescriptor *eDesc = [self executeAppleScript:muteScript];
}


+(bool)fetchCSMuteStatus:(NSString *)inputString
{
    bool mStatus = NO;
    
    
    NSString *muteStatusString = [NSString stringWithFormat:@"get muted of %@", inputString];
    NSAppleEventDescriptor *eDesc = [self executeAppleScript:muteStatusString];
    if (eDesc != nil && [eDesc descriptorType] != kAENullEvent)
    {
        mStatus = [eDesc booleanValue];
    }
    
    return mStatus;
}

@end
