//
//  CSActionSwapLayouts.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/9/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionSwapLayouts.h"

@implementation CSActionSwapLayouts

-(void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    if (self.csRunning)
    {
        [self.csApp swapLayouts];
    }
    
}
@end
