//
//  CSActionTransition.h
//  CocoaSplitESD
//
//  Created by Zakk on 1/11/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "CSActionBase.h"
#import "CocoaSplitSB.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSActionTransition : CSActionBase
@property (strong) CocoaSplitTransition *selectedTransition;
@end


NS_ASSUME_NONNULL_END
