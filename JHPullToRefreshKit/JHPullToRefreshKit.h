//
//  Header.h
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/15/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#ifndef JHPullToRefreshExampleProj_Header_h
#define JHPullToRefreshExampleProj_Header_h

// For abstract classes
#define MustOverride() @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil]

// Screen dimensions
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

// Animation duration
#define kPTRAnimationDuration 0.3

#endif
