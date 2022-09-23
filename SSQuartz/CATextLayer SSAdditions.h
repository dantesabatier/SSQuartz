//
//  CATextLayer+SSAdditions.h
//  SSQuartz
//
//  Created by Dante Sabatier on 1/16/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#import <Cocoa/Cocoa.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CATextLayer (SSAdditions)

@property (readonly) CGSize proposedFrameSize;

@end

extern id SSTextLayerGetFont(CATextLayer *self);
extern CGSize SSTextLayerGetProposedFrameSizeFromString(CATextLayer *self, id string);

NS_ASSUME_NONNULL_END
