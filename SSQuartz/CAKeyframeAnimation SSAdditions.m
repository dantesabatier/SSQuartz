//
//  CAKeyframeAnimation+SSAdditions.m
//  SSQuartz
//
//  Created by Dante Sabatier on 09/10/14.
//  Copyright (c) 2014 Dante Sabatier. All rights reserved.
//

#import "CAKeyframeAnimation+SSAdditions.h"
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

@implementation CAKeyframeAnimation (SSAdditions)

+ (instancetype)shakeAnimationWithRect:(CGRect)rect {
    static NSInteger numberOfShakes = 4;
    static CGFloat vigourOfShake = 0.05;
    
    CGMutablePathRef path = SSAutorelease(CGPathCreateMutable());
    CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y);
    for (NSInteger idx = 0; idx < numberOfShakes; ++idx) {
        CGPathAddLineToPoint(path, NULL, rect.origin.x - rect.size.width * vigourOfShake, rect.origin.y);
        CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width * vigourOfShake, rect.origin.y);
    }
    
    CGPathCloseSubpath(path);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.path = path;
    animation.duration = 0.5;
    
    return animation;
}

@end
