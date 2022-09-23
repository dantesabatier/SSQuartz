//
//  SSQuartzDefines.h
//  SSQuartz
//
//  Created by Dante Sabatier on 29/12/18.
//  Copyright © 2018 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#import "SSDisplayLink.h"
#ifndef CADisplayLink
#define CADisplayLink SSDisplayLink
#endif
#endif
