//
//  CSActionGolive.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/9/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionGolive.h"

@implementation CSActionGolive

-(void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    if (self.csRunning)
    {
        [self.csApp goLive];
    }
}


@end
