//
//  SSSpinningProgressIndicatorLayer.m
//  SSQuartz
//
//  Created by Dante Sabatier on 10/25/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import "SSSpinningProgressIndicatorLayer.h"
#if TARGET_OS_IPHONE
#import <base/SSGeometry.h>
#import <graphics/SSColor.h>
#else
#import <SSBase/SSGeometry.h>
#import <SSGraphics/SSColor.h>
#endif

@interface SSSpinningProgressIndicatorLayer ()

@property (readonly) CGRect finBoundsForCurrentBounds;
@property (readonly) CGPoint finAnchorPointForCurrentBounds;
- (void)advancePosition;
- (void)removeFinLayers;
- (void)createFinLayers;
- (void)setupAnimTimer;
- (void)disposeAnimTimer;

@end

@implementation SSSpinningProgressIndicatorLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        _position = 0;
        _numFins = 12;
        _fadeDownOpacity = 0.0;
        _animating = NO;
        self.foregroundColor = SSColorGetBlackColor();
		self.bounds = SSRectMakeSquare(10.0);
        [self createFinLayers];
    }
    return self;
}

- (void)dealloc {
    CGColorRelease(_foregroundColor);
    //self.foregroundColor = nil;
    [self removeFinLayers];
    [super ss_dealloc];
}

- (void)startAnimation {
    if (_animating) {
        return;
    }
    self.hidden = NO;
    _animating = YES;
    [self setupAnimTimer];
}

- (void)stopAnimation {
    if (!_animating) {
        return;
    }
    _animating = NO;
    [self disposeAnimTimer];
    [self setNeedsDisplay];
}

#pragma mark private methods

- (void)advancePosition {
    _position++;
    
    if (_position >= _numFins) {
        _position = 0;
    }
    CALayer *fin = (CALayer *)_finLayers[_position];
    // Set the next fin to full opacity, but do it immediately, without any animation
    [CATransaction begin];
    [CATransaction setValue:@YES forKey:kCATransactionDisableActions];
    fin.opacity = 1.0;
    [CATransaction commit];
    
    // Tell that fin to animate its opacity to transparent.
    fin.opacity = _fadeDownOpacity;
    
    [self setNeedsDisplay];
}

- (void)setupAnimTimer {
    // Just to be safe kill any existing timer.
    [self disposeAnimTimer];
    
    // Why animate if not visible?  viewDidMoveToWindow will re-call this method when needed.
    _animationTimer = [[NSTimer timerWithTimeInterval:(NSTimeInterval)0.05 target:self selector:@selector(advancePosition) userInfo:nil repeats:YES] ss_retain];
    
    _animationTimer.fireDate = [NSDate date];
    [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
#if !TARGET_OS_IPHONE
    [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSEventTrackingRunLoopMode];
#endif
}

- (void)disposeAnimTimer {
    [_animationTimer invalidate];
    [_animationTimer release];
    _animationTimer = nil;
}

- (void)createFinLayers {
    [self removeFinLayers];
    
    // Create new fin layers
    _finLayers = [[NSMutableArray alloc] initWithCapacity:_numFins];
    
    CGRect finBounds = self.finBoundsForCurrentBounds;
    CGPoint finAnchorPoint = self.finAnchorPointForCurrentBounds;
    CGPoint finPosition = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat finCornerRadius = finBounds.size.width/2;
    
    int i;
    for (i=0; i<_numFins; i++) {
        CALayer *fin = [CALayer layer];
        fin.bounds = finBounds;
        fin.anchorPoint = finAnchorPoint;
        fin.position = finPosition;
        fin.transform = CATransform3DMakeRotation(i*(-6.282185/_numFins), 0.0, 0.0, 1.0);
        fin.cornerRadius = finCornerRadius;
        fin.backgroundColor = _foregroundColor;
        
        // Set the fin's initial opacity
        [CATransaction begin];
        [CATransaction setValue:@YES forKey:kCATransactionDisableActions];
        fin.opacity = _fadeDownOpacity;
        [CATransaction commit];
        
        // set the fin's fade-out time (for when it's animating)
        CABasicAnimation *anim = [CABasicAnimation animation];
        anim.duration = 0.7f;
        
        fin.actions = @{@"opacity": anim};
        
        [self addSublayer:fin];
        [_finLayers addObject:fin];
    }
}

- (void)removeFinLayers {
    [_finLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_finLayers release];
}

- (CGRect)finBoundsForCurrentBounds {
    CGSize size = self.bounds.size;
    CGFloat minSide = MAX(size.width, size.height);
    CGFloat width = minSide * 0.095f;
    CGFloat height = minSide * 0.30f;
    return CGRectMake(0,0,width,height);
}

- (CGPoint)finAnchorPointForCurrentBounds {
    CGSize size = self.bounds.size;
    CGFloat minSide = MAX(size.width, size.height);
    CGFloat height = minSide * 0.30f;
    return CGPointMake(0.5, -0.9*(minSide-height)/minSide);
}

#pragma mark getters & setters

- (void)setBounds:(CGRect)bounds {
    super.bounds = bounds;
    
    // Resize the fins
    CGRect finBounds = self.finBoundsForCurrentBounds;
    CGPoint finAnchorPoint = self.finAnchorPointForCurrentBounds;
    CGPoint finPosition = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat finCornerRadius = finBounds.size.width/2;
    
    // do the resizing all at once, immediately
    [CATransaction begin];
    [CATransaction setValue:@YES forKey:kCATransactionDisableActions];
    for (CALayer *fin in _finLayers) {
        fin.bounds = finBounds;
        fin.anchorPoint = finAnchorPoint;
        fin.position = finPosition;
        fin.cornerRadius = finCornerRadius;
    }
    [CATransaction commit];
}

- (CGColorRef)foregroundColor {
    return _foregroundColor;
}

- (void)setForegroundColor:(CGColorRef)foregroundColor {
    if (CGColorEqualToColor(_foregroundColor, foregroundColor)) {
        return;
    }
    
    SSRetainedTypeSet(_foregroundColor, foregroundColor);
	
    // Update do all of the fins to this new color, at once, immediately
    [CATransaction begin];
    [CATransaction setValue:@YES forKey:kCATransactionDisableActions];
    for (CALayer *fin in _finLayers) {
        fin.backgroundColor = _foregroundColor;
    }
    [CATransaction commit];
}

- (BOOL)isAnimating {
    return _animating;
}

@end

