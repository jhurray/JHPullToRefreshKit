//
//  BubbleRefreshControl.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/16/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//
#import "BubbleRefreshControl.h"

@interface BubbleRefreshControl()

@property (nonatomic, strong) UIView *bubble1;
@property (nonatomic, strong) UIView *bubble2;
@property (nonatomic, strong) UIView *bubble3;

@end

@implementation BubbleRefreshControl

-(id)initWithType:(JHRefreshControlType)type {
    if (self = [super initWithType:type]){
        self.bubble1 = [self setupBubble];
        self.bubble2 = [self setupBubble];
        self.bubble3 = [self setupBubble];
        self.backgroundColor = [UIColor blueColor];
        self.animationType = JHRefreshControlAnimationTypeKeyFrame;
        self.animationViewStretches = YES;
        self->animationOptions = UIViewKeyframeAnimationOptionCalculationModeLinear;
    }
    return self;
}

-(UIView *)setupBubble {
    UIView *bubble = [[UIView alloc] initWithFrame:CGRectZero];
    bubble.backgroundColor = [UIColor whiteColor];
    CGFloat size = self.height*0.3;
    [bubble setFrame:CGRectMake(0, 0, size, size)];
    bubble.layer.cornerRadius = size/2;
    [self addSubviewToRefreshAnimationView:bubble];
    return bubble;
}

-(void)resetAnimationView:(UIView *)animationView {
    self.bubble1.alpha = 1.0;
    self.bubble2.alpha = 1.0;
    self.bubble3.alpha = 1.0;
}

-(void)handleScrollingOnAnimationView:(UIView *)animationView
                     withPullDistance:(CGFloat)pullDistance
                            pullRatio:(CGFloat)pullRatio
                         pullVelocity:(CGFloat)pullVelocity {
    // used to control UI elements during scrolling
    self.bubble1.transform = CGAffineTransformMakeScale(pullRatio, pullRatio);
    self.bubble2.transform = CGAffineTransformMakeScale(pullRatio, pullRatio);
    self.bubble3.transform = CGAffineTransformMakeScale(pullRatio, pullRatio);
    CGFloat yCenter = animationView.bounds.size.height/2;
    [self.bubble1 setCenter:CGPointMake(kScreenWidth/3, yCenter)];
    [self.bubble2 setCenter:CGPointMake(kScreenWidth*3/6, yCenter)];
    [self.bubble3 setCenter:CGPointMake(kScreenWidth*2/3, yCenter)];
}

-(void)setupRefreshControlForAnimationView:(UIView *)animationView {
    // Set refresh animation to correct state before a new cycle begins
    self.bubble1.transform = CGAffineTransformMakeScale(1.0, 1.0);
    self.bubble2.transform = CGAffineTransformMakeScale(1.0, 1.0);
    self.bubble3.transform = CGAffineTransformMakeScale(1.0, 1.0);
}

-(void)animationCycleForAnimationView:(UIView *)animationView {
    [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.3 animations:^{
        self.bubble1.transform = CGAffineTransformMakeScale(1.8, 1.8);
    }];
    [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.3 animations:^{
        self.bubble1.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.bubble2.transform = CGAffineTransformMakeScale(1.8, 1.8);
    }];
    [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.3 animations:^{
        self.bubble2.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.bubble3.transform = CGAffineTransformMakeScale(1.8, 1.8);
    }];
    [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
        self.bubble3.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

-(void)exitAnimationForRefreshView:(UIView *)animationView withCompletion:(JHCompletionBlock)completion {
    [UIView animateKeyframesWithDuration:0.7 delay:0.0 options:0 animations:^{
        __block CGFloat yCenter = animationView.bounds.size.height/2;
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.4 animations:^{
            [self.bubble1 setCenter:CGPointMake(kScreenWidth/2, yCenter)];
            [self.bubble3 setCenter:CGPointMake(kScreenWidth/2, yCenter)];
            self.bubble2.transform = CGAffineTransformMakeScale(2.5, 2.5);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.3 animations:^{
            self.bubble1.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.bubble2.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.bubble3.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.bubble1.alpha = 0.0;
            self.bubble2.alpha = 0.0;
            self.bubble3.alpha = 0.0;
        }];
        
    } completion:^(BOOL finished) {
        completion();
    }];
}

+(CGFloat)height {
    //return the height
    return 80.0;
}

+(NSTimeInterval)animationDuration {
    //return the animation duration
    return 1.0;
}

+(NSTimeInterval)animationDelay {
    //return the animation delay
    return 0.0;
}

@end
