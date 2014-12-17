//
//  JHRefreshControl.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/14/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#define JHRefreshControlBaseClass_protected

#import "JHRefreshControl.h"

@interface JHRefreshControl()

// original frame for the control
// depends on type
-(CGRect)calculatedFrame;

// animation routing
-(void)animateRefreshViewEnded;
-(void)defaultAnimation;
-(void)keyframeAnimation;
-(void)springAnimation;

@end

@implementation JHRefreshControl
// public ish
@synthesize refreshing, delegate;
//private ish
@synthesize refreshAnimationView;

-(id)initWithType:(JHRefreshControlType)type {
    if(self = [super init]) {
        _type = type;
        [self setupRefreshControl];
    }
    return self;
}

-(id)init {
    if(self = [super init]) {
        _type = JHRefreshControlTypeSlideDown;
        [self setupRefreshControl];
    }
    return self;
}

-(void)endRefreshing {
    [self setRefreshing:NO];
}

-(void)forceRefresh {
    [self refresh];
}

-(void)resetAnimationView:(UIView *)animationView {
    // should reset UI elements here
    // called after refresh control finishes and is hidden
}

-(void)addSubviewToRefreshAnimationView:(UIView *)subview {
    [self.refreshAnimationView addSubview:subview];
}

-(CGFloat)height {
    return [[self class] height];
}

-(NSTimeInterval)animationDuration {
    return [[self class] animationDuration];
}

-(NSTimeInterval)animationDelay {
    return [[self class] animationDelay];
}

// INSTANCE ABSTRACTION
// MUST BE OVERRIDDEN

-(void)handleScrollingOnAnimationView:(UIView *)animationView
                        withPullDistance:(CGFloat)pullDistance
                        pullRatio:(CGFloat)pullRatio
                        pullVelocity:(CGFloat)pullVelocity{
    MustOverride();
}

-(void)setupRefreshControlForAnimationView:(UIView *)animationView {
    MustOverride(); 
}

-(void)animationCycleForAnimationView:(UIView *)animationView {
    MustOverride();
}

-(void)exitAnimationForRefreshView:(UIView *)animationView withCompletion:(JHCompletionBlock)completion {
    completion();
}

// CLASS ABSTRACTION
// MUST BE OVERRIDDEN

+(CGFloat)height {
    MustOverride();
}

+(NSTimeInterval)animationDuration {
    MustOverride();
}

+(NSTimeInterval)animationDelay {
    MustOverride();
}

// PRIVATE 

-(void)setupRefreshControl {
    self.backgroundColor = [UIColor clearColor];
    self.frame = [self calculatedFrame];
    self.animationType = JHRefreshControlAnimationTypeDefault;
    self->animationOptions = 0;
    // setup refresh animation view
    self.animationViewStretches = NO;
    self.refreshAnimationView = [[UIView alloc] initWithFrame:self.bounds];
    self.refreshAnimationView.backgroundColor = [UIColor clearColor];
    [self addSubview:refreshAnimationView];
}

-(CGRect)calculatedFrame {
    switch (_type) {
        case JHRefreshControlTypeBackground:
            return CGRectMake(0, 0, kScreenWidth, self.height);
            break;
        case JHRefreshControlTypeSlideDown:
            return CGRectMake(0, -self.height, kScreenWidth, self.height);
            break;
        default:
            return CGRectZero;
            break;
    }
}

-(void)refresh {
    [self setRefreshing:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [delegate refreshControlDidStart:self];
    [self animateRefreshView];
}

-(void)resetAnimation {
    [self setRefreshing:NO];
    [self exitAnimationForRefreshView:self.refreshAnimationView withCompletion:^{
        [self.delegate refreshControlDidEnd:self];
        [self performSelector:@selector(resetAnimationView:)
                   withObject:self.refreshAnimationView
                   afterDelay:kPTRAnimationDuration];
    }];
}

-(void)animateRefreshView {
    [self setupRefreshControlForAnimationView:self.refreshAnimationView];
    switch (self.animationType) {
        case JHRefreshControlAnimationTypeKeyFrame:
            [self keyframeAnimation];
            break;
        case JHRefreshControlAnimationTypeSpring:
            [self springAnimation];
            break;
        default:
            [self defaultAnimation];
            break;
    }
}

-(void)animateRefreshViewEnded {
    if (self.isRefreshing) {
        [self animateRefreshView];
    } else {
        [self resetAnimation];
    }
}

-(void)defaultAnimation {
    [UIView animateWithDuration:self.animationDuration
                          delay:self.animationDelay
                            options:self->animationOptions
                            animations:^{
        [self animationCycleForAnimationView:self.refreshAnimationView];
    } completion:^(BOOL finished) {
        [self animateRefreshViewEnded];
    }];
}
-(void)keyframeAnimation {
    [UIView animateKeyframesWithDuration:self.animationDuration
                                   delay:self.animationDelay
                                    options:self->animationOptions
                                    animations:^{
        [self animationCycleForAnimationView:self.refreshAnimationView];
    } completion:^(BOOL finished) {
        [self animateRefreshViewEnded];
    }];
}
-(void)springAnimation {
    [UIView animateWithDuration:self.animationDuration
                          delay:self.animationDelay
                            usingSpringWithDamping:0.8
                            initialSpringVelocity:1.0
                            options:self->animationOptions
                            animations:^{
        [self animationCycleForAnimationView:self.refreshAnimationView];
    } completion:^(BOOL finished) {
        [self animateRefreshViewEnded];
    }];
}

// from scroll view delegate

-(void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView {
    CGFloat actualOffset = scrollView.contentOffset.y;
    if(!self.isRefreshing && -actualOffset > self.height) {
        [self refresh];
        if (self.animationViewStretches) {
            [UIView animateWithDuration:kPTRAnimationDuration animations:^{
                self.refreshAnimationView.frame = CGRectMake(0, 0, kScreenWidth, self.height);
                [self handleScrollingOnAnimationView:self.refreshAnimationView
                                    withPullDistance:self.height
                                        pullRatio:1.0
                                        pullVelocity:0.0];
            }];
        }
    }
}

-(void)containingScrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat actualOffset = scrollView.contentOffset.y;
    [self setFrameForScrollingWithOffset:actualOffset];
    if (!self.isRefreshing) {
        CGFloat pullDistance = MAX(0.0, -actualOffset);
        CGFloat pullRatio = MIN(MAX(0.0, pullDistance), self.height)/self.height;
        CGFloat velocity = [scrollView.panGestureRecognizer velocityInView:scrollView].y;
        if (pullRatio != 0.0) {
            [self handleScrollingOnAnimationView:self.refreshAnimationView
                                            withPullDistance:pullDistance
                                            pullRatio:pullRatio
                                            pullVelocity:velocity];
        }
    }
    
}

// handling scrolling

-(void)setFrameForScrollingWithOffset:(CGFloat)offset {
    // offset is a negative value
    if (-offset > self.height) {
        CGRect newFrame = CGRectMake(0, offset, kScreenWidth, ABS(offset));
        self.frame = newFrame;
        self.bounds = CGRectMake(0, 0, kScreenWidth, ABS(offset));
    }
    else {
        CGFloat newY = offset;
        if (_type == JHRefreshControlTypeSlideDown) {
            newY = -self.height;
        }
        self.frame = CGRectMake(0, newY, kScreenWidth, self.height);
        self.bounds = CGRectMake(0, 0, kScreenWidth, self.height);
    }
    // set refresh animation view frame
    if (self.animationViewStretches) {
        self.refreshAnimationView.frame = self.bounds;
    } else {
        self.refreshAnimationView.frame = CGRectMake(0, 0, kScreenWidth, self.height);
    }
}


@end
