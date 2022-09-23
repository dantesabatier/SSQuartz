//
//  CALayer+SSAdditions.m
//  SSQuartz
//
//  Created by Dante Sabatier on 7/11/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "CALayer+SSAdditions.h"
#import "CATextLayer+SSAdditions.h"
#if TARGET_OS_IPHONE
#import <graphics/SSGraphics.h>
#import <foundation/NSValue+SSAdditions.h>
#import <foundation/NSArray+SSAdditions.h>
#else
#import <SSGraphics/SSGraphics.h>
#import <SSFoundation/NSArray+SSAdditions.h>
#endif

#define kSSBookshelfKitLayerShadowEdges @"kSSBookshelfKitLayerShadowEdges"

@implementation CALayer(SSAdditions)

- (CGFloat)scale {
    return [[self valueForKeyPath:@"transform.scale"] floatValue];
}

- (void)setScale:(CGFloat)scale {
    [self setValue:@(scale) forKeyPath:@"transform.scale"];
}

- (CGFloat)rotation {
	return [[self valueForKeyPath:@"transform.rotation"] floatValue];
}

- (void)setRotation:(CGFloat)rotation {
    [self setValue:@(rotation) forKeyPath:@"transform.rotation"];
}

- (CGSize)translation {
	return [[self valueForKeyPath:@"transform.translation"] sizeValue];
}

- (void)setTranslation:(CGSize)translation {
    [self setValue:[NSValue valueWithSize:translation] forKeyPath:@"transform.translation"];
}

- (CGSize)contentsSize {
    return SSImageGetSize(SSImageGetCGImage(self.contents));
}

- (void)recursivelyRenderInContext:(CGContextRef)ctx {
    if (self.hidden || ([self.delegate respondsToSelector:@selector(imageRepresentationShouldIncludeLayer:)] && ![(id)self.delegate imageRepresentationShouldIncludeLayer:self])) {
        return;
    }
    
    [self layoutIfNeeded];
	
	CGRect bounds = self.bounds;
    if (!CGRectIntersectsRect(bounds, CGContextGetClipBoundingBox(ctx))) {
        return;
    }
    
    CGContextSaveGState(ctx);
    
	CGFloat opacity = self.opacity;
	if (opacity < 1.0) {
		CGContextSetAlpha(ctx, opacity);
		CGContextBeginTransparencyLayer(ctx, NULL);
	}
	
	if (self.masksToBounds) {
        CGContextAddRect(ctx, bounds);
		CGContextClip(ctx);
	}
	
	CGColorRef shadowColor = self.shadowColor;
	CGFloat shadowOpacity = self.shadowOpacity;
	if ((shadowOpacity > 0) && shadowColor) {
		CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowRadius, shadowColor);
	}
	
	CGColorRef backgroundColor = self.backgroundColor;
	if (backgroundColor) {
		CGContextSetFillColorWithColor(ctx, backgroundColor);
		CGContextFillRect(ctx, bounds);
	}
    
    if ([self isKindOfClass:[CAShapeLayer class]]) {
        CAShapeLayer *shapeLayer = (CAShapeLayer *)self;
        CGColorRef fillColor = shapeLayer.fillColor;
        CGColorRef strokeColor = shapeLayer.strokeColor;
        CGFloat lineWidth = shapeLayer.lineWidth;
        CGPathRef path = shapeLayer.path;
        if (!path) {
            path = SSAutorelease(SSPathCreateWithRoundedRect(bounds, shapeLayer.cornerRadius, NULL));
        }
        
        if (fillColor != NULL) {
            CGContextAddPath(ctx, path);
            CGContextSetFillColorWithColor(ctx, fillColor);
            CGContextFillPath(ctx);
        }
        
        if (strokeColor != NULL) {
            CGContextAddPath(ctx, path);
            CGContextSetStrokeColorWithColor(ctx, strokeColor);
            CGContextSetLineWidth(ctx, lineWidth);
            CGContextStrokePath(ctx);
        }
    } else if ([self isKindOfClass:[CATextLayer class]]) {
		CATextLayer *textLayer = (CATextLayer *)self;
		id string = textLayer.string;
		if ([string isKindOfClass:[NSAttributedString class]])
			string = [string string];
		
		if ([string length]) {
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_11)) || (TARGET_OS_IPHONE && defined(__IPHONE_9_0)))
            CTTextAlignment textAlignment = kCTTextAlignmentNatural;
            NSString *alignmentMode = textLayer.alignmentMode;
            if (alignmentMode == kCAAlignmentLeft) {
                textAlignment = kCTTextAlignmentLeft;
            } else if (alignmentMode == kCAAlignmentRight) {
                textAlignment = kCTTextAlignmentRight;
            } else if (alignmentMode == kCAAlignmentCenter) {
                textAlignment = kCTTextAlignmentCenter;
            } else if (alignmentMode == kCAAlignmentJustified) {
                textAlignment = kCTTextAlignmentJustified;
            }
#else
            CTTextAlignment textAlignment = kCTNaturalTextAlignment;
            NSString *alignmentMode = textLayer.alignmentMode;
            if (alignmentMode == kCAAlignmentLeft) {
                textAlignment = kCTLeftTextAlignment;
            } else if (alignmentMode == kCAAlignmentRight) {
                textAlignment = kCTRightTextAlignment;
            } else if (alignmentMode == kCAAlignmentCenter) {
                textAlignment = kCTCenterTextAlignment;
            } else if (alignmentMode == kCAAlignmentJustified) {
                textAlignment = kCTJustifiedTextAlignment;
            }
#endif
            CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
			SSContextDrawTextAlignedInRect(ctx, (__bridge CFStringRef)string, bounds, textAlignment, (__bridge CTFontRef)SSTextLayerGetFont(textLayer), textLayer.foregroundColor);
		}
	} else {
        CGImageRef image = SSImageGetCGImage(self.contents);
        if (image) {
            NSUInteger ih = (NSUInteger)CGImageGetHeight(image);
            if ((ih < 1) || (ih > 3000))
                image = NULL;
        }
        
		if (image) {
			NSString *contentsGravity = self.contentsGravity;
            if (contentsGravity == kCAGravityResizeAspect) {
                SSContextDrawImage(ctx, image, bounds, SSRectResizingMethodScale);
            } else if (contentsGravity == kCAGravityResizeAspectFill) {
                SSContextDrawImage(ctx, image, bounds, SSRectResizingMethodCrop);
            } else {
                CGContextDrawImage(ctx, bounds, image);
            }
        } else {
            [self drawInContext:ctx];
        }
            
	}
	
	CGFloat borderWidth = self.borderWidth;
	CGColorRef borderColor = self.borderColor;
	if (borderColor && borderWidth) {
		CGContextSetStrokeColorWithColor(ctx, borderColor);
		CGContextStrokeRectWithWidth(ctx, bounds, borderWidth);
	}
	
	NSArray *sublayers = [self.sublayers sortedArrayUsingComparator:^(id layer1, id layer2) {
        return [layer1 zPositionCompare:layer2];
    }];
    
	if (sublayers.count > 0) {
		CATransform3D sublayerTransform = self.sublayerTransform;
		if (!CATransform3DIsIdentity(sublayerTransform)) {
			CGPoint localAnchorPoint = self.anchorPoint;
			CGSize localAnchorOffset = CGSizeMake(bounds.origin.x + localAnchorPoint.x * bounds.size.width, bounds.origin.y + localAnchorPoint.y * bounds.size.height);
			
			CGAffineTransform affineSublayerTransform = CATransform3DGetAffineTransform(sublayerTransform);
			
			CGContextTranslateCTM(ctx, localAnchorOffset.width, localAnchorOffset.height);
			CGContextConcatCTM(ctx, affineSublayerTransform);
			CGContextTranslateCTM(ctx, -localAnchorOffset.width, -localAnchorOffset.height);
		}
        
		for (CALayer *sublayer in sublayers) {
			CGContextSaveGState(ctx);
			
			CGPoint subAnchorPoint = sublayer.anchorPoint; // 0-1 unit coordinate space with 0,0 being bottom left.
			CGRect subBounds = sublayer.bounds;
			CGPoint position = sublayer.position; // position is the coordinate in the superlayer that our anchor point should match.
			CGContextTranslateCTM(ctx, position.x, position.y);
			
			// Transform is applied relative to the anchor point.
			CATransform3D transform = sublayer.transform;
			if (!CATransform3DIsIdentity(transform)) {
				CGAffineTransform affineTransform = CATransform3DGetAffineTransform(transform);
				CGContextConcatCTM(ctx, affineTransform);
			} 
			
			CGContextTranslateCTM(ctx, -(subBounds.origin.x + (subAnchorPoint.x * subBounds.size.width)), -(subBounds.origin.y + (subAnchorPoint.y * subBounds.size.height)));
			
			[sublayer recursivelyRenderInContext:ctx];
			CGContextRestoreGState(ctx);
		}
	}
	
	if (opacity < 1.0) {
		CGContextEndTransparencyLayer(ctx);
	}
	
    CGContextRestoreGState(ctx);
}

- (CGImageRef)CGImageForRect:(CGRect)rect {
    CGImageRef image = NULL;
	
	size_t pixelsWide = (size_t)rect.size.width;
	size_t pixelsHigh = (size_t)rect.size.height;
	size_t bytesPerRow = (size_t)(pixelsWide * 4);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Host);
	if (ctx) {
		CGContextSaveGState(ctx);
		{
            CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
			CGContextTranslateCTM(ctx, -rect.origin.x, -rect.origin.y);
            [self recursivelyRenderInContext:ctx];
		}
		CGContextRestoreGState(ctx);
		
		image = SSAutorelease(CGBitmapContextCreateImage(ctx));
		
		CGContextRelease(ctx);
	}
	CGColorSpaceRelease(colorSpace);
    
    return image;
}

- (CGImageRef)CGImage {
    return [self CGImageForRect:self.bounds];
}

- (nullable __kindof CALayer *)sublayerNamed:(NSString *)name {
    return [self.sublayers firstObjectPassingTest:^BOOL(CALayer * _Nonnull sublayer) {
        return [sublayer.name isEqualToString:name];
    }];
}

- (NSComparisonResult)sizeCompare:(CALayer *)layer {
	return SSSizeCompare(layer.frame.size, self.frame.size);
}

- (NSComparisonResult)zPositionCompare:(CALayer *)layer {
    if (self.zPosition > layer.zPosition) {
        return NSOrderedAscending;
    }
    
    if (self.zPosition < layer.zPosition) {
        return NSOrderedDescending;
    }
	return NSOrderedSame;
}

@end

static void SSLayerAddShadowEdge(CALayer *self, CGImageRef image, NSMutableArray *edges) {
    CALayer *layer = [[CALayer alloc] init];
    if (self.name.length) {
        layer.name = [NSString stringWithFormat:@"%@-shadow-%@", self.name, @(edges.count)];
    }
	layer.delegate = self.delegate;
    layer.needsDisplayOnBoundsChange = NO;
    layer.contents = (__bridge id)image;
    
    [self addSublayer:layer];
	
    [edges addObject:layer];
    [layer release];
}

static struct {
    CGImageRef top;
    CGImageRef bottom;
    CGImageRef left;
    CGImageRef right;
} ShadowImages;

void SSLayerAddShadowEdges(CALayer *self) {
    if ([self valueForKey:kSSBookshelfKitLayerShadowEdges]) {
        return;
    }
    
	NSMutableArray *edges = [NSMutableArray arrayWithCapacity:4];
    static NSBundle *resourcesBundle = nil;
    if (!resourcesBundle) {
#if TARGET_OS_IPHONE
        resourcesBundle = [[NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"SSQuartzResources" withExtension:@"bundle"]] ss_retain];
#else
        resourcesBundle = [[NSBundle bundleWithIdentifier:@"com.sabatiersoftware.SSQuartz"] ss_retain];
#endif
    }
    if (!ShadowImages.top) {
        ShadowImages.top = SSImageCreateWithImageResourceNamedInBundle(resourcesBundle, @"ShadowBorderTop");
    }
        
    if (!ShadowImages.bottom) {
        ShadowImages.bottom = SSImageCreateWithImageResourceNamedInBundle(resourcesBundle, @"ShadowBorderBottom");
    }
        
    if (!ShadowImages.left) {
        ShadowImages.left = SSImageCreateWithImageResourceNamedInBundle(resourcesBundle, @"ShadowBorderLeft");
    }
        
    if (!ShadowImages.right) {
        ShadowImages.right = SSImageCreateWithImageResourceNamedInBundle(resourcesBundle, @"ShadowBorderRight");
    }
    
	SSLayerAddShadowEdge(self, ShadowImages.top, edges);
	SSLayerAddShadowEdge(self, ShadowImages.bottom, edges);
	SSLayerAddShadowEdge(self, ShadowImages.left, edges);
	SSLayerAddShadowEdge(self, ShadowImages.right, edges);
	
#if 1
    self.opaque = YES;
    self.backgroundColor = SSColorGetBlackColor();
#endif
	[self setValue:edges forKey:kSSBookshelfKitLayerShadowEdges];
}

void SSLayerRemoveShadowEdges(CALayer *self) {
    NSArray *shadows = [self valueForKey:kSSBookshelfKitLayerShadowEdges];
    if (!shadows.count) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setValue:@YES forKey:kCATransactionDisableActions];
    [shadows makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [CATransaction commit];
    
#if 1
    self.opaque = NO;
    self.backgroundColor = NULL;
#endif
    [self setValue:nil forKey:kSSBookshelfKitLayerShadowEdges];
}

void SSLayerLayoutShadowEdges(CALayer *self, BOOL flipped) {
	NSArray *shadows = [self valueForKey:kSSBookshelfKitLayerShadowEdges];
    if (!shadows.count) {
        return;
    }
    
	CGRect bounds = self.bounds;
	CGFloat shadowSize = MIN(MAX(FLOOR(MIN(bounds.size.width, bounds.size.height)*(CGFloat)0.22), 16.0), 32.0);
    CGPoint topPoint = CGPointMake(FLOOR(CGRectGetMinX(bounds) - (shadowSize*(CGFloat)0.5)), CGRectGetMaxY(bounds));
    CGPoint bottomPoint = CGPointMake(FLOOR(CGRectGetMinX(bounds) - (shadowSize*(CGFloat)0.5)), FLOOR(CGRectGetMinY(bounds) - shadowSize));
    if (flipped) {
        SWAP(topPoint, bottomPoint);
    }
    
    CALayer *top = nil;
    CALayer *bottom = nil;
    CALayer *left = nil;
    CALayer *right = nil;
    
#if __has_feature(objc_arc)
    top = [self sublayerNamed:[NSString stringWithFormat:@"%@-shadow-%@", self.name, @0]];
    bottom = [self sublayerNamed:[NSString stringWithFormat:@"%@-shadow-%@", self.name, @1]];
    left = [self sublayerNamed:[NSString stringWithFormat:@"%@-shadow-%@", self.name, @2]];
    right = [self sublayerNamed:[NSString stringWithFormat:@"%@-shadow-%@", self.name, @3]];
#else
	struct {
		CALayer *top;
		CALayer *bottom;
		CALayer *left;
		CALayer *right;
	} edges;
	
    [shadows getObjects:(id *)&edges range:NSMakeRange(0, shadows.count)];
    
    top = edges.top;
    bottom = edges.bottom;
    left = edges.left;
    right = edges.right;
#endif
    
	top.frame = CGRectMake(topPoint.x, topPoint.y, CGRectGetWidth(bounds) + shadowSize, shadowSize);
	bottom.frame = CGRectMake(bottomPoint.x, bottomPoint.y, CGRectGetWidth(bounds) + shadowSize, shadowSize);
	left.frame = CGRectMake(FLOOR(CGRectGetMinX(bounds) - shadowSize), CGRectGetMinY(bounds), shadowSize, CGRectGetHeight(bounds));
	right.frame = CGRectMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds), shadowSize, CGRectGetHeight(bounds));
}

void SSFlipLayers(CALayer *front, CALayer *back) {
    static CATransform3D frontTransform, backTransform;
    frontTransform = backTransform = CATransform3DIdentity;
    backTransform.m11 = backTransform.m33 = -1;
    
	BOOL isUp = CATransform3DEqualToTransform(front.transform, frontTransform);
	
	front.transform = isUp ? backTransform : frontTransform;
	back.transform = isUp ? frontTransform : backTransform;
}
