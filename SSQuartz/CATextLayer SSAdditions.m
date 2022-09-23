//
//  CATextLayer+SSAdditions.m
//  SSQuartz
//
//  Created by Dante Sabatier on 1/16/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "CATextLayer+SSAdditions.h"
#import "CALayer+SSAdditions.h"
#if TARGET_OS_IPHONE
#import <graphics/SSString.h>
#else
#import <SSGraphics/SSString.h>
#endif

@implementation CATextLayer (SSAdditions)

- (CGSize)proposedFrameSize {
    return SSTextLayerGetProposedFrameSizeFromString(self, self.string);
}

@end

id SSTextLayerGetFont(CATextLayer *self) {
    id font = (__bridge id)self.font;
    if ([font isKindOfClass:[NSString class]]) {
#if TARGET_OS_IPHONE
        font = [UIFont fontWithName:font size:self.fontSize];
#else
        font = [NSFont fontWithName:font size:self.fontSize];
#endif
    }
    
    if (!font) {
#if TARGET_OS_IPHONE
        font = [UIFont systemFontOfSize:self.fontSize];
#else
        font = [NSFont systemFontOfSize:self.fontSize];
#endif
    }
    return font;
}

CGSize SSTextLayerGetProposedFrameSizeFromString(CATextLayer *self, id string) {
    CGSize stringSize = SSStringGetSizeWithFont(string, SSTextLayerGetFont(self));
    return CGSizeMake(FLOOR(stringSize.width + MAX(self.cornerRadius, (stringSize.height + 2.0)*(CGFloat)0.5)), FLOOR(stringSize.height + 2.0));
}
