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

@property (nonatomic, copy) void (^refreshBlock)();

// original frame for the control
// depends on type
-(CGRect)calculatedFrame;

// animation routing
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
        [self setup];
    }
    return self;
}

-(id)init {
    if(self = [super init]) {
        _type = JHRefreshControlTypeSlideDown;
        [self setupRefreshControl];
        [self setup];
    }
    return self;
}

-(void) addToScrollView:(UIScrollView *)scrollView withRefreshBlock:(void (^)())refreshBlock {
    self.parentScrollView = scrollView;
    self.refreshBlock = refreshBlock;
    [self.parentScrollView addSubview:self];
    if (self->_type == JHRefreshControlTypeBackground) {
        [self.parentScrollView sendSubviewToBack:self];
    }
    [self.parentScrollView.panGestureRecognizer addTarget:self
                                                   action:@selector(handlePanGestureRecognizer)];
    [self.parentScrollView addObserver:self
                            forKeyPath:@"contentOffset"
                               options:NSKeyValueObservingOptionNew
                               context:nil];
    JHPTR_DEBUG(@"Added refresh control to scroll view.")
    
}

-(void)endRefreshing {
    [self setRefreshing:NO];
}

-(void)forceRefresh {
    JHPTR_DEBUG(@"")
    JHPTR_DEBUG(@"Forced refresh.")
    [self refresh];
}

-(void)resetAnimationView:(UIView *)animationView {
    // should reset UI elements here
    // called after refresh control finishes and is hidden
}

-(void)addSubviewToRefreshAnimationView:(UIView *)subview {
    [self.refreshAnimationView addSubview:subview];
    JHPTR_DEBUG(@"Added subview to refresh animation view.")
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

-(void)setup {
    MustOverride();
}

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
    return 0.0;
}

// PRIVATE 

-(void)setupRefreshControl {
    self.backgroundColor = [UIColor clearColor];
    self.frame = [self calculatedFrame];
    self.animationType = JHRefreshControlAnimationTypeDefault;
    self->animationOptions = 0;
    // setup refresh animation view
    self.anchorPosition = JHRefreshControlAnchorPositionTop;
    self.refreshAnimationView = [[UIView alloc] initWithFrame:self.bounds];
    self.refreshAnimationView.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = YES;
    [self addSubview:refreshAnimationView];
    JHPTR_DEBUG(@"Refresh control is setup")
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

-(void)setScrollViewTopInsets:(CGFloat)offset {
    UIEdgeInsets insets = self.parentScrollView.contentInset;
    insets.top += offset;
    self.parentScrollView.contentInset = insets;
}

-(void)refresh {
    JHPTR_DEBUG(@"Refresh started.")
    [self setRefreshing:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [delegate refreshControlDidStart:self];
    if (self.parentScrollView) {
        self.refreshBlock();
        [UIView animateWithDuration:kPTRAnimationDuration animations:^{
            [self setScrollViewTopInsets: self.height];
        } completion:nil];
    }
    [self animateRefreshView];
}

-(void)resetAnimation {
    JHPTR_DEBUG(@"Refresh ended.")
    [self setRefreshing:NO];
    JHPTR_DEBUG(@"Starting exit animation.")
    [self exitAnimationForRefreshView:self.refreshAnimationView withCompletion:^{
        JHPTR_DEBUG(@"Refresh animation ended")
        JHPTR_DEBUG(@"Resigning refresh control")
        [self.delegate refreshControlDidEnd:self];
        if (self.parentScrollView) {
            [UIView animateWithDuration:kPTRAnimationDuration animations:^{
                [self setScrollViewTopInsets: -self.height];
            } completion:^(BOOL finished) {
                [self.parentScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            }];
        }
        JHPTR_DEBUG(@"Resetting animation view")
        [self performSelector:@selector(resetAnimationView:)
                   withObject:self.refreshAnimationView
                   afterDelay:kPTRAnimationDuration];
    }];
}

-(void)animateRefreshView {
    JHPTR_DEBUG(@"Setting up animation view for new cycle.")
    [self setupRefreshControlForAnimationView:self.refreshAnimationView];
    JHPTR_DEBUG(@"Starting animation cycle.")
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
    [self.delegate refreshControlDidStartAnimationCycle:self];
}

-(void)animateRefreshViewEnded {
    JHPTR_DEBUG(@"Animation cycle ended.")
    [self.delegate refreshControlDidEndAnimationCycle:self];
    if (self.isRefreshing) {
        JHPTR_DEBUG(@"endRefreshing has not been called yet")
        [self animateRefreshView];
    } else {
        JHPTR_DEBUG(@"endRefreshing has been called")
        [self resetAnimation];
    }
}

-(void)defaultAnimation {
    JHPTR_DEBUG(@"Default animation")
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
    JHPTR_DEBUG(@"Keyframe animation")
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
    JHPTR_DEBUG(@"Spring animation")
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

// ScrollView Observations

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"] && object == self.parentScrollView) {
        [self containingScrollViewDidScroll:self.parentScrollView];
    }
}

-(void) handlePanGestureRecognizer {
    if (self.parentScrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self containingScrollViewDidEndDragging:self.parentScrollView];
    }
}

-(void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView {
    CGFloat actualOffset = scrollView.contentOffset.y;
    if(!self.isRefreshing && -actualOffset > self.height) {
        [self refresh];
        if (self.anchorPosition != JHRefreshControlAnchorPositionTop) {
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
    if (self.anchorPosition == JHRefreshControlAnchorPositionMiddle) {
        // give the appearance of stretching
        CGPoint center = CGPointMake(kScreenWidth/2, self.bounds.size.height/2);
        self.refreshAnimationView.center = center;
    } else if (self.anchorPosition == JHRefreshControlAnchorPositionBottom) {
        CGRect bottomFrame = CGRectMake(0, self.frame.size.height-self.height, kScreenWidth, self.height);
        self.refreshAnimationView.frame = bottomFrame;
    }
}


@end
