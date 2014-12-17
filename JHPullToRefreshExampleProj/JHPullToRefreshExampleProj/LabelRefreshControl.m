//
//  LabelRefreshControl.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/17/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "LabelRefreshControl.h"

@interface LabelRefreshControl()

@property (strong, nonatomic) UILabel *label;

@end

@implementation LabelRefreshControl

-(id)initWithType:(JHRefreshControlType)type {
    if ([super initWithType:type]){
        self.backgroundColor = [UIColor lightGrayColor];
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
        self.label.adjustsFontSizeToFitWidth = YES;
        [self.label setTextAlignment:NSTextAlignmentCenter];
        self.label.text = @"pull down";
        self.animationViewStretches = YES;
        [self addSubviewToRefreshAnimationView:self.label];
        self->animationOptions = UIViewAnimationOptionAutoreverse;
        self.animationType = JHRefreshControlAnimationTypeSpring;
    }
    return self;
}

-(void)handleScrollingOnAnimationView:(UIView *)animationView
                     withPullDistance:(CGFloat)pullDistance
                            pullRatio:(CGFloat)pullRatio
                         pullVelocity:(CGFloat)pullVelocity {
    // used to control UI elements during scrolling
    self.label.center = CGPointMake(kScreenWidth/2, animationView.bounds.size.height/2);
    if (pullRatio > 0.75) {
        self.label.layer.transform = CATransform3DMakeRotation(M_PI*(pullRatio-0.75)*8, 1, 0, 0);
        if (pullRatio >0.875) {
            self.label.text = @"release to refresh";
        } else {
            self.label.text = @"pull down";
        }
    }
}

-(void)resetAnimationView:(UIView *)animationView {
    // should reset UI elements here
    // called after refresh control finishes and is hidden
    self.label.text = @"pull down";
    self.label.transform = CGAffineTransformMakeScale(1.0, 1.0);
}

-(void)setupRefreshControlForAnimationView:(UIView *)animationView {
    // Set refresh animation to correct state before a new cycle begins
    self.label.transform = CGAffineTransformMakeScale(1.0, 1.0);
    self.label.text = @"refreshing";
}

-(void)animationCycleForAnimationView:(UIView *)animationView {
    // UI changes to be animated each cycle
    self.label.transform = CGAffineTransformMakeScale(1.3, 1.3);
}

-(void)exitAnimationForRefreshView:(UIView *)animationView withCompletion:(JHCompletionBlock)completion {
    // animation for when refreshing is done.
    // does not need to be overridden
    // if empty no animation will be executed
    self.label.text = @"done!";
    [UIView animateWithDuration:0.3 animations:^{
        self.label.transform = CGAffineTransformMakeScale(5.0, 5.0);
    } completion:^(BOOL finished) {
       completion();
    }];
}

+(CGFloat)height {
    //return the height
    return 70.0;
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
