//
//  SSDisplayLinkHelper.h
//  SSQuartz
//
//  Created by Dante Sabatier on 03/05/16.
//  Copyright © 2016 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@class SSDisplayLink;
typedef void (^SSDisplayLinkHelperExecutionBlock)(CGFloat progress);
typedef void (^SSDisplayLinkHelperCompletionBlock)(void);

@interface SSDisplayLinkHelper : NSObject {
@private
    id _displayLink;
    SSDisplayLinkHelperExecutionBlock _executionBlock;
    SSDisplayLinkHelperCompletionBlock _completionBlock;
    CFTimeInterval _fireTime;
    CFTimeInterval _duration;
}

#if TARGET_OS_IPHONE
@property (nonatomic, strong) CADisplayLink *displayLink;
#else
@property (nonatomic, strong) SSDisplayLink *displayLink;
#endif
@property (nullable, nonatomic, copy) SSDisplayLinkHelperExecutionBlock executionBlock;
@property (nullable, nonatomic, copy) SSDisplayLinkHelperCompletionBlock completionBlock;
@property (nonatomic, readonly, assign) CFTimeInterval fireTime;
@property (nonatomic, assign) CFTimeInterval duration;
#if TARGET_OS_IPHONE
- (void)handleDisplayLink:(CADisplayLink *)sender;
#else
- (void)handleDisplayLink:(SSDisplayLink *)sender;
#endif

@end

NS_ASSUME_NONNULL_END
