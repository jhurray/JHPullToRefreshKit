//
//  ColorChangeRefreshControl.h
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/15/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "JHRefreshControl.h"

@interface ColorChangeRefreshControl : JHRefreshControl

-(id)initWithType:(JHRefreshControlType)type andColors:(NSArray *)colors;

@end
