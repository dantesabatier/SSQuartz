//
//  CADisplayLink+SSAdditions.m
//  SSQuartz
//
//  Created by Dante Sabatier on 16/02/16.
//  Copyright © 2016 Dante Sabatier. All rights reserved.
//

#import "CADisplayLink+SSAdditions.h"
#import "SSDisplayLinkHelper.h"

@implementation CADisplayLink (SSAdditions)

#if NS_BLOCKS_AVAILABLE

+ (instancetype)displayLinkWithDuration:(CFTimeInterval)duration execution:(void (^)(CGFloat progress))execution completion:(void(^__nullable)(void))completion {
    SSDisplayLinkHelper *helper = [[SSDisplayLinkHelper alloc] init];
    helper.displayLink = [CADisplayLink displayLinkWithTarget:helper selector:@selector(handleDisplayLink:)];
    helper.executionBlock = execution;
    helper.completionBlock = completion;
    helper.duration = duration;
    return helper.displayLink;
}

+ (instancetype)displayLinkWithDuration:(CFTimeInterval)duration execution:(void (^)(CGFloat progress))execution {
    return [CADisplayLink displayLinkWithDuration:duration execution:execution completion:nil];
}

#endif

@end
