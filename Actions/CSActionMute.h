//
//  CSActionMute.h
//  CocoaSplitESD
//
//  Created by Zakk on 1/10/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionBase.h"
#import "CocoaSplitSB.h"
NS_ASSUME_NONNULL_BEGIN

@interface CSActionMute : CSActionBase
@property (strong) CocoaSplitAudioInput *selectedAudio;

@end

NS_ASSUME_NONNULL_END
