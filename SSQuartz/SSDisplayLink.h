//
//  SSDisplayLink.h
//  SSQuartz
//
//  Created by Dante Sabatier on 03/05/16.
//  Copyright © 2016 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSScreen.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSDisplayLink : NSObject {
@private
    void *_reserved;
    id _target;
    SEL _action;
    CFTimeInterval _timestamp;
    CFTimeInterval _duration;
    BOOL _valid;
}

@property (readonly) CFTimeInterval timestamp;
@property (readonly) CFTimeInterval duration;
@property (getter=isPaused) BOOL paused;
@property (readonly, getter=isValid) BOOL valid;
+ (instancetype)displayLinkWithScreen:(NSScreen *)screen target:(id)target selector:(SEL)selector;
+ (instancetype)displayLinkWithTarget:(id)target selector:(SEL)selector;
#if NS_BLOCKS_AVAILABLE
+ (instancetype)displayLinkWithScreen:(NSScreen *)screen duration:(CFTimeInterval)duration execution:(void (^)(CGFloat progress))execution completion:(void(^__nullable)(void))completion;
+ (instancetype)displayLinkWithDuration:(CFTimeInterval)duration execution:(void (^)(CGFloat progress))execution completion:(void(^__nullable)(void))completion;
+ (instancetype)displayLinkWithDuration:(CFTimeInterval)duration execution:(void (^)(CGFloat progress))execution;
#endif
- (void)addToRunLoop:(NSRunLoop *)runloop forMode:(NSRunLoopMode)mode;
- (void)removeFromRunLoop:(NSRunLoop *)runloop forMode:(NSRunLoopMode)mode;
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
