//
//  CAKeyframeAnimation+SSAdditions.h
//  SSQuartz
//
//  Created by Dante Sabatier on 09/10/14.
//  Copyright (c) 2014 Dante Sabatier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CAKeyframeAnimation (SSAdditions)

+ (instancetype)shakeAnimationWithRect:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
