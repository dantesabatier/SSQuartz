//
//  SSSpinningProgressIndicatorLayer.h
//  SSQuartz
//
//  Created by Dante Sabatier on 10/25/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SSSpinningProgressIndicatorLayer : CALayer {
@private
    NSTimer *_animationTimer;
    NSUInteger _position;
    CGColorRef _foregroundColor;
    CGFloat _fadeDownOpacity;
    NSUInteger _numFins;
    NSMutableArray <__kindof CALayer *>*_finLayers;
    BOOL _animating;
}

@property (nonatomic, nullable) CGColorRef foregroundColor;
@property (nonatomic, readonly, getter=isAnimating, assign) BOOL animating;
- (void)startAnimation;
- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
