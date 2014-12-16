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

-(CGRect)calculatedFrame;

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

-(void)animationCycleOnAnimationView:(UIView *)animationView {
    MustOverride();
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
    // setup refresh animation view
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
    [self.delegate refreshControlDidEnd:self];
}

-(void)animateRefreshView {
    [self setupRefreshControlForAnimationView:self.refreshAnimationView];
    [UIView animateWithDuration:self.animationDuration delay:self.animationDelay options:0 animations:^{
        [self animationCycleOnAnimationView:self.refreshAnimationView];
    } completion:^(BOOL finished) {
        if (self.isRefreshing) {
            [self animateRefreshView];
        } else {
            [self resetAnimation];
        }
    }];
}

-(void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView {
    NSLog(@"%f, %f", scrollView.contentOffset.y, self.height);
    if(-scrollView.contentOffset.y >
       self.height /* + navheight */) {
        [self refresh];
    }
}

-(void)containingScrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat actualOffset = scrollView.contentOffset.y /* + navheight */;
    [self setFrameForScrollingWithOffset:actualOffset];
    if (!self.isRefreshing) {
        CGFloat pullDistance = MAX(0.0, -actualOffset);
        CGFloat pullRatio = MIN(MAX(0.0, pullDistance), self.height)/self.height;
        CGFloat velocity = [scrollView.panGestureRecognizer velocityInView:scrollView].y;
        [self handleScrollingOnAnimationView:self.refreshAnimationView
                            withPullDistance:pullDistance
                                   pullRatio:pullRatio
                                pullVelocity:velocity];
    }
    
}

-(void)setFrameForScrollingWithOffset:(CGFloat)offset {
    // offset is a negative value
    if (-offset > self.height) {
        CGRect newFrame = CGRectMake(0, offset, kScreenWidth, ABS(offset));
        self.frame = newFrame;
        self.bounds = CGRectMake(0, 0, kScreenWidth, ABS(offset));
        //NSLog(@"new frame : %@", NSStringFromCGRect(newFrame));
    }
    else {
        CGFloat newY = offset;
        if (_type == JHRefreshControlTypeSlideDown) {
            newY = -self.height;
        }
        self.frame = CGRectMake(0, newY, kScreenWidth, self.height);
        self.bounds = CGRectMake(0, 0, kScreenWidth, self.height);
        // NSLog(@"calculated frame : %@", NSStringFromCGRect([self calculatedFrame]));
    }
    // IF SAME SIZE AS CONTROL
    //self.refreshAnimationView.frame = self.bounds;
    self.refreshAnimationView.frame = CGRectMake(0, 0, kScreenWidth, self.height);
}


@end
