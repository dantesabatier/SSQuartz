//
//  CALayer+SSAdditions.h
//  SSQuartz
//
//  Created by Dante Sabatier on 7/11/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CALayer(SSAdditions)

@property CGFloat scale;
@property CGFloat rotation;
@property CGSize translation;
@property (readonly) CGSize contentsSize;
- (void)recursivelyRenderInContext:(CGContextRef)ctx;
- (nullable CGImageRef)CGImageForRect:(CGRect)rect;
@property (readonly) CGImageRef CGImage CF_RETURNS_NOT_RETAINED;
- (nullable __kindof CALayer *)sublayerNamed:(NSString *)name NS_SWIFT_NAME(sublayer(named:));
- (NSComparisonResult)sizeCompare:(CALayer *)layer;
- (NSComparisonResult)zPositionCompare:(CALayer *)layer;

@end

@interface NSObject(SSLayerDelegate)

- (BOOL)imageRepresentationShouldIncludeLayer:(CALayer *)layer;

@end

extern void SSLayerAddShadowEdges(CALayer *self);
extern void SSLayerRemoveShadowEdges(CALayer *self);
extern void SSLayerLayoutShadowEdges(CALayer *self, BOOL flipped);
extern void SSFlipLayers(CALayer *front, CALayer *back);

NS_ASSUME_NONNULL_END
