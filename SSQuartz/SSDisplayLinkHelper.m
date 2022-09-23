//
//  SSDisplayLinkHelper.m
//  SSQuartz
//
//  Created by Dante Sabatier on 03/05/16.
//  Copyright © 2016 Dante Sabatier. All rights reserved.
//

#import "SSDisplayLinkHelper.h"
#if TARGET_OS_IPHONE
#import <foundation/NSObject+SSAdditions.h>
#else
#import "SSDisplayLink.h"
#import <SSFoundation/NSObject+SSAdditions.h>
#endif

@interface SSDisplayLinkHelper ()

@property (nonatomic, readwrite, assign) CFTimeInterval fireTime;

@end
@implementation SSDisplayLinkHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [_displayLink release];
    [_executionBlock release];
    [_completionBlock release];
    
    [super ss_dealloc];
}

- (id)displayLink {
    return SSAtomicAutoreleasedGet(_displayLink);
}

- (void)setDisplayLink:(id)displayLink {
    SSAtomicRetainedSet(_displayLink, displayLink);
}

- (SSDisplayLinkHelperExecutionBlock)executionBlock {
    return SSAtomicAutoreleasedGet(_executionBlock);
}

- (void)setExecutionBlock:(SSDisplayLinkHelperExecutionBlock)executionBlock {
    SSAtomicCopiedSet(_executionBlock, executionBlock);
}

- (SSDisplayLinkHelperCompletionBlock)completionBlock {
    return SSAtomicAutoreleasedGet(_completionBlock);
}

- (void)setCompletionBlock:(SSDisplayLinkHelperCompletionBlock)completionBlock {
    SSAtomicCopiedSet(_completionBlock, completionBlock);
}

- (CFTimeInterval)duration {
    return _duration;
}

- (void)setDuration:(CFTimeInterval)duration {
    _duration = duration;
}

- (CFTimeInterval)fireTime {
    return _fireTime;
}

- (void)setFireTime:(CFTimeInterval)fireTime {
    _fireTime = fireTime;
}

#if TARGET_OS_IPHONE
- (void)handleDisplayLink:(CADisplayLink *)sender;
#else
- (void)handleDisplayLink:(SSDisplayLink *)sender;
#endif
{
#if !TARGET_OS_IPHONE
    if (!sender.isValid) {
        return;
    }
#endif
    if (self.fireTime == 0.0) {
        self.fireTime = sender.timestamp;
    }
    
    CFTimeInterval duration = self.duration;
    CFTimeInterval enlapsedTime = sender.timestamp - self.fireTime;
    if (enlapsedTime >= duration) {
        [sender invalidate];
        if (self.executionBlock) {
            self.executionBlock(1.0);
        }
        if (self.completionBlock) {
            self.completionBlock();
        }
        [self autorelease];
    } else {
        self.executionBlock(enlapsedTime/duration);
    }
}

@end

