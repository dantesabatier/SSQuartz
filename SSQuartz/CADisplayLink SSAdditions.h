//
//  CADisplayLink+SSAdditions.h
//  SSQuartz
//
//  Created by Dante Sabatier on 16/02/16.
//  Copyright © 2016 Dante Sabatier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CADisplayLink (SSAdditions)

#if NS_BLOCKS_AVAILABLE
+ (instancetype)displayLinkWithDuration:(CFTimeInterval)duration execution:(void (^)(CGFloat progress))execution completion:(void(^__nullable)(void))completion;
+ (instancetype)displayLinkWithDuration:(CFTimeInterval)duration execution:(void (^)(CGFloat progress))execution;
#endif

@end

NS_ASSUME_NONNULL_END
