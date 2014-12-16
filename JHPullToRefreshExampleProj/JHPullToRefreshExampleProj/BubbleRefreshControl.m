//
//  BubbleRefreshControl.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/16/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//
#import "BubbleRefreshControl.h"

@interface BubbleRefreshControl()

@property (nonatomic, strong) UIView *bubble;

@end

@implementation BubbleRefreshControl

-(id)initWithType:(JHRefreshControlType)type {
    if (self = [super initWithType:type]){
        self.bubble = [[UIView alloc] initWithFrame:CGRectZero];
        self.bubble.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor blueColor];
        [self addSubviewToRefreshAnimationView:self.bubble];
    }
    return self;
}

-(void)handleScrollingOnAnimationView:(UIView *)animationView
                     withPullDistance:(CGFloat)pullDistance
                            pullRatio:(CGFloat)pullRatio
                         pullVelocity:(CGFloat)pullVelocity {
    // used to control UI elements during scrolling
    CGFloat size = self.height*0.6*pullRatio;
    [self.bubble setFrame:CGRectMake(0, 0, size, size)];
    [self.bubble setCenter:CGPointMake(animationView.bounds.size.width/2, animationView.bounds.size.height/2)];
}

-(void)setupRefreshControlForAnimationView:(UIView *)animationView {
    // Set refresh animation to correct state before a new cycle begins
    self.bubble.transform = CGAffineTransformMakeRotation(0);
}

-(void)animationCycleOnAnimationView:(UIView *)animationView {
    // UI changes to be animated each cycle
    self.bubble.transform = CGAffineTransformMakeRotation(M_PI/2);
}

+(CGFloat)height {
    //return the height
    return 90.0;
}

+(NSTimeInterval)animationDuration {
    //return the animation duration
    return 0.4;
}

+(NSTimeInterval)animationDelay {
    //return the animation delay
    return 0.0;
}

@end
