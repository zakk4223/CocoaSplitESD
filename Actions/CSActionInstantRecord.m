//
//  CSActionInstantRecord.m
//  CocoaSplitESD
//
//  Created by Zakk on 1/9/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionInstantRecord.h"

@implementation CSActionInstantRecord

-(void)keyDownForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    if (self.csRunning)
    {
        [self.csApp instantRecord];
    }
}
@end
