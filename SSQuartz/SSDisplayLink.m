//
//  SSDisplayLink.m
//  SSQuartz
//
//  Created by Dante Sabatier on 03/05/16.
//  Copyright © 2016 Dante Sabatier. All rights reserved.
//

#import "SSDisplayLink.h"
#import "SSDisplayLinkHelper.h"
#import <AppKit/NSWindow.h>
#import <AppKit/NSScreen.h>
#import <CoreVideo/CVDisplayLink.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#import <SSFoundation/NSTimer+SSAdditions.h>

CVReturn SSDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext);

@interface SSDisplayLink ()

@property (nonatomic, readwrite) CFTimeInterval timestamp;
@property (nonatomic, readwrite) CFTimeInterval duration;
@property (nonatomic, readonly, ss_weak) id target;
@property (nonatomic, readonly, assign) SEL action;

@end

@implementation SSDisplayLink

- (instancetype)initWithScreen:(NSScreen *)screen target:(id)target selector:(SEL)selector {
    self = [super init];
    if (self) {
        CVDisplayLinkRef displayLink = NULL;
        if ((CVDisplayLinkCreateWithActiveCGDisplays(&displayLink) == kCVReturnSuccess) && (CVDisplayLinkSetCurrentCGDisplay(displayLink, ((CGDirectDisplayID)[[screen.deviceDescription objectForKey:@"NSScreenNumber"] unsignedIntValue])) == kCVReturnSuccess) && (CVDisplayLinkSetOutputCallback(displayLink, &SSDisplayLinkCallback, (__bridge void *)self) == kCVReturnSuccess) && (CVDisplayLinkStart(displayLink) == kCVReturnSuccess)) {
            _timestamp = 0.0;
            _duration = 0.0;
            _target = target;
            _action = selector;
            _valid = YES;
            _reserved = displayLink;
        }
    }
    return self;
}

- (instancetype)initWithTarget:(id)target selector:(SEL)selector {
    return [self initWithScreen:NSApp.keyWindow.screen target:target selector:selector];
}

+ (instancetype)displayLinkWithScreen:(NSScreen *)screen target:(id)target selector:(SEL)selector {
    return [[[self alloc] initWithScreen:screen target:target selector:selector] autorelease];
}

+ (instancetype)displayLinkWithTarget:(id)target selector:(SEL)selector {
    return [[[self alloc] initWithTarget:target selector:selector] autorelease];
}

#if NS_BLOCKS_AVAILABLE

+ (instancetype)displayLinkWithScreen:(NSScreen *)screen duration:(CFTimeInterval)duration execution:(void (^)(CGFloat progress))execution completion:(void(^__nullable)(void))completion {
    SSDisplayLinkHelper *helper = [[SSDisplayLinkHelper alloc] init];
    helper.executionBlock = execution;
    helper.completionBlock = completion;
    helper.duration = duration;
    helper.displayLink = [SSDisplayLink displayLinkWithScreen:screen target:helper selector:@selector(handleDisplayLink:)];
    return helper.displayLink;
}

+ (instancetype)displayLinkWithDuration:(CFTimeInterval)duration execution:(void (^)(CGFloat progress))execution completion:(void(^__nullable)(void))completion {
    return [SSDisplayLink displayLinkWithScreen:NSApp.keyWindow.screen duration:duration execution:execution completion:completion];
}

+ (instancetype)displayLinkWithDuration:(CFTimeInterval)duration execution:(void (^)(CGFloat progress))execution {
    return [SSDisplayLink displayLinkWithDuration:duration execution:execution completion:nil];
}

#endif

- (void)dealloc {
    _target = nil;
    _action = NULL;
    
    [self invalidate];
    
    [super ss_dealloc];
}

- (void)addToRunLoop:(NSRunLoop *)runloop forMode:(NSRunLoopMode)mode {
    
}

- (void)removeFromRunLoop:(NSRunLoop *)runloop forMode:(NSRunLoopMode)mode {
    
}

- (void)invalidate {
    if (self.isValid && _reserved) {
        if (_reserved) {
            CVDisplayLinkStop(_reserved);
            CVDisplayLinkRelease(_reserved);
            _reserved = NULL;
        }
        self.valid = NO;
    }
}

#pragma mark getters & setters

- (id)target {
    return SSAtomicAutoreleasedGet(_target);
}

- (SEL)action {
    SEL value;
    SSAtomicStruct(value, _action);
    return value;
}

- (CFTimeInterval)timestamp {
    CFTimeInterval value;
    SSAtomicStruct(value, _timestamp);
    return value;
}

- (void)setTimestamp:(CFTimeInterval)timestamp {
    SSAtomicStruct(_timestamp, timestamp);
}

- (CFTimeInterval)duration {
    CFTimeInterval value;
    SSAtomicStruct(value, _duration);
    return value;
}

- (void)setDuration:(CFTimeInterval)duration {
    SSAtomicStruct(_duration, duration);
}

- (BOOL)isValid {
    BOOL value;
    SSAtomicStruct(value, _valid);
    return value;
}

- (void)setValid:(BOOL)valid {
    SSAtomicStruct(_valid, valid);
}

- (BOOL)isPaused {
    return _reserved ? !CVDisplayLinkIsRunning(_reserved) : NO;
}

- (void)setPaused:(BOOL)paused {
    if (!_reserved) {
        return;
    }
    
    if (paused) {
        CVDisplayLinkStop(_reserved);
    } else {
        CVDisplayLinkStart(_reserved);
    }
}

@end

double SSDisplayLinkGetFrameRate(CVDisplayLinkRef displayLink) {
    double frameRate = 60.0;
    CVTime cvtime = CVDisplayLinkGetNominalOutputVideoRefreshPeriod(displayLink);
    if (cvtime.timeValue > 0) {
        frameRate = (double)cvtime.timeScale/(double)cvtime.timeValue;
    }
    frameRate = CVDisplayLinkGetActualOutputVideoRefreshPeriod(displayLink);
    if (frameRate > 0.0) {
        frameRate = 1.0/frameRate;
    } else {
        frameRate = 60.0;
    }
    return frameRate;
}

CVReturn SSDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext) {
    SSDisplayLink *self = (__bridge SSDisplayLink *)displayLinkContext;
    if (self.isValid) {
        self.timestamp += 1.0/SSDisplayLinkGetFrameRate(displayLink);
        self.duration = self.timestamp;
        @autoreleasepool {
            [self.target performSelectorOnMainThread:self.action withObject:self waitUntilDone:NO];
        }
        return kCVReturnSuccess;
    }
    return kCVReturnDisplayLinkNotRunning;
}
