//
//  CSActionGlobalMute.h
//  CocoaSplitESD
//
//  Created by Zakk on 1/9/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSActionBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSActionGlobalMute : CSActionBase
@property (strong) CocoaSplitAudioInput *selectedAudio;

@end

NS_ASSUME_NONNULL_END
