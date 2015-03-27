//
//  YahooRefreshControl.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 2/26/15.
//  Copyright (c) 2015 jhurray. All rights reserved.
//

#import "YahooRefreshControl.h"

@interface YahooRefreshControl()

@property (strong, nonatomic) UIView *rotatingView;
@property (strong, nonatomic) NSArray *dots;
@property (strong, nonatomic) NSArray *colors;

@end

@implementation YahooRefreshControl

-(CALayer *)targetLayer {
    return self.rotatingView.layer;
}

-(void)setup {
    self.colors = @[[UIColor redColor],
                    [UIColor orangeColor],
                    [UIColor yellowColor],
                    [UIColor greenColor],
                    [UIColor blueColor],
                    [UIColor purpleColor]];
    self.anchorPosition = JHRefreshControlAnchorPositionMiddle;
    self.rotatingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.height, self.height)];
    self.rotatingView.center = CGPointMake(kScreenWidth/2, self.height/2);
    self.backgroundColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.96 alpha:1.0];
    self.rotatingView.backgroundColor = [UIColor clearColor];
    [self addCABasicAnimationWithKeyPath:@"transform.rotation.z" fromValue:0.0 toValue:2*M_PI];
    NSMutableArray *dotz = [NSMutableArray array];
    for (NSInteger idx = 0; idx < 6; idx++) {
        [dotz addObject:[self dotWithIndex:idx]];
        [self.rotatingView addSubview:dotz[idx]];
    }
    self.dots = dotz;
    [self addSubviewToRefreshAnimationView:self.rotatingView];
}

-(UIView *)dotWithIndex:(NSInteger)index {
    static float radians = M_PI/2;
    CGFloat offset = 20.0;
    UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 9, 9)];
    dot.backgroundColor = self.colors[index];
    dot.layer.cornerRadius = dot.bounds.size.width/2;
    dot.center = CGPointMake(self.height/2.0 + offset*cosf(radians), self.height/2.0 + offset*sinf(radians));
    radians += M_PI/3.0;
    return dot;
}


-(void) exitAnimationForRefreshView:(UIView *)animationView withCompletion:(JHCompletionBlock)completion {
    [UIView animateKeyframesWithDuration:1.0 delay:0.0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.00 relativeDuration:0.4 animations:^{
            float radians = M_PI/2;
            CGFloat offset;
            for (NSInteger idx = 0; idx < 6; idx++) {
                if (idx == 0 || idx == 3) {
                    offset = 35.0;
                } else {
                    offset = 50;
                }
                UIView *dot = self.dots[idx];
                dot.center = CGPointMake(self.height/2.0 + offset*cosf(radians), self.height/2.0 + offset*sinf(radians));
                radians += M_PI/3.0;
            }
        }];
        [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.3 animations:^{
            for (NSInteger idx = 0; idx < 6; idx++) {
                UIView *dot = self.dots[idx];
                dot.center = CGPointMake(self.height/2, self.height/2);
            }
        }];
        [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.3 animations:^{
            UIView *dot = self.dots[5];
            dot.transform = CGAffineTransformMakeScale(2*kScreenWidth/dot.bounds.size.height, 4*self.height/dot.bounds.size.height);
        }];
    } completion:^(BOOL finished) {
        self.rotatingView.alpha = 0.0;
        self.backgroundColor = self.colors[5];
        completion();
    }];
}


-(void)handleScrollingOnAnimationView:(UIView *)animationView
                     withPullDistance:(CGFloat)pullDistance
                            pullRatio:(CGFloat)pullRatio
                         pullVelocity:(CGFloat)pullVelocity {
    // used to control UI elements during scrolling
}

-(void) resetAnimationView:(UIView *)animationView {
    float radians = M_PI/2;
    CGFloat offset = 20.0;
    self.rotatingView.alpha = 1.0;
    self.backgroundColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.96 alpha:1.0];
    for (NSInteger idx = 0; idx < 6; idx++) {
        UIView *dot = self.dots[idx];
        dot.center = CGPointMake(self.height/2.0 + offset*cosf(radians), self.height/2.0 + offset*sinf(radians));
        dot.transform = CGAffineTransformIdentity;
        radians += M_PI/3.0;
    }
}

+(CGFloat)height {
    //return the height
    return 90.0;
}

+(NSTimeInterval)animationDuration {
    //return the animation duration
    return 0.9;
}

@end
