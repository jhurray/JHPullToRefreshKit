//
//  ColorChangeRefreshControl.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/15/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "ColorChangeRefreshControl.h"

@interface ColorChangeRefreshControl(){
    int index;
}

@property (nonatomic, strong) NSArray *colors;

@end

@implementation ColorChangeRefreshControl

-(id)initWithType:(JHRefreshControlType)type andColors:(NSArray *)colors {
    if (self = [super initWithType:type]){
        self.colors = colors;
    }
    return self;
}

-(void)setup {
    self->index = 0;
    self.backgroundColor = (UIColor *)[self.colors objectAtIndex:index];
}

-(void)handleScrollingOnAnimationView:(UIView *)animationView
                     withPullDistance:(CGFloat)pullDistance
                            pullRatio:(CGFloat)pullRatio
                         pullVelocity:(CGFloat)pullVelocity {
    // used to control UI elements during scrolling
}

-(void)setupRefreshControlForAnimationView:(UIView *)animationView {
    // Set refresh animation to correct state before a new cycle begins
    index++;
    if (index == self.colors.count) {
        index = 0;
    }
}

-(void)animationCycleForAnimationView:(UIView *)animationView {
    // UI changes to be animated each cycle
    self.backgroundColor = (UIColor *)[self.colors objectAtIndex:index];
}

+(CGFloat)height {
    //return the height
    return 70.0;
}

+(NSTimeInterval)animationDuration {
    //return the animation duration
    return 0.3;
}

@end
