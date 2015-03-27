//
//  GoogleRefreshControl.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/17/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#define JHRefreshControlBaseClass_protected
#import "GoogleRefreshControl.h"

@interface GoogleRefreshControl() {
    CGFloat startPercent;
    CGFloat endPercent;
    CGFloat fillPercent;
    CGFloat radius;
    CGFloat rotation;
    CGFloat rotationIncrement;
    NSInteger colorIndex;
    BOOL filling;
}

@property (strong, nonatomic) UIBezierPath *arc;
@property (strong, nonatomic) UIView *circleView;
@property (strong, nonatomic) CAShapeLayer *arcLayer;
@property (strong, nonatomic) NSArray *colors;

-(CGColorRef)colorFromCurrentColorIndex;

@end

@implementation GoogleRefreshControl

-(CGColorRef)colorFromCurrentColorIndex {
    if (colorIndex >= self.colors.count){
        colorIndex = 0;
    }
    return ((UIColor *)self.colors[colorIndex]).CGColor;
}

-(void)setup {
    self.backgroundColor = [UIColor whiteColor];
    self.animationType = JHRefreshControlAnimationTypeKeyFrame;
    startPercent = (M_PI/8.0)/(2*M_PI);
    endPercent = (13*M_PI/8.0)/(2*M_PI);
    fillPercent = endPercent-startPercent;
    rotation = 0;
    rotationIncrement = 14*M_PI/8.0;
    radius = 15.0;
    filling = NO;
    CGPoint animationViewCenter = CGPointMake(kScreenWidth/2, self.height/2);
    colorIndex = 0;
    self.colors = @[[UIColor blueColor],
                    [UIColor redColor],
                    [UIColor orangeColor],
                    [UIColor greenColor]];
    self.circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius*2, radius*2)];
    self.circleView.center = animationViewCenter;
    self.circleView.backgroundColor = [UIColor clearColor];
    [self addSubviewToRefreshAnimationView:self.circleView];
    CGPoint circleViewCenter = CGPointMake(radius, radius);
    self.arc = [UIBezierPath bezierPathWithArcCenter:circleViewCenter radius:radius startAngle:-M_PI endAngle:M_PI clockwise:YES];
    self.arcLayer = [[CAShapeLayer alloc] init];
    self.arcLayer.path = self.arc.CGPath;
    self.arcLayer.strokeColor = [self colorFromCurrentColorIndex];
    self.arcLayer.fillColor = [UIColor clearColor].CGColor;
    self.arcLayer.lineWidth =  0.1*radius*2;
    self.arcLayer.strokeStart = 0.0;
    self.arcLayer.strokeEnd = startPercent;
    self.arcLayer.frame = self.circleView.bounds;
    [self.circleView.layer insertSublayer:self.arcLayer atIndex:0];
}

-(void)handleScrollingOnAnimationView:(UIView *)animationView
                     withPullDistance:(CGFloat)pullDistance
                            pullRatio:(CGFloat)pullRatio
                         pullVelocity:(CGFloat)pullVelocity {
    CGFloat startPullRatio = 0.5;
    CGFloat startPullRatioMultiplier = (pullRatio-startPullRatio)*(1/startPullRatio);
    if (pullRatio > startPullRatio) {
        self.arcLayer.strokeEnd = startPullRatioMultiplier*pullRatio*fillPercent + startPercent;
    }
    rotation = M_PI*pullDistance/self.height*0.75;
    self.circleView.transform = CGAffineTransformMakeRotation(rotation);
}

-(void)resetAnimationView:(UIView *)animationView {
    rotation = 0;
    [self.circleView setAlpha:1.0];
    self.circleView.transform = CGAffineTransformMakeRotation(rotation);
    colorIndex = 0;
    self.arcLayer.strokeEnd = startPercent;
    [self.arcLayer removeAllAnimations];
}

-(void)setupRefreshControlForAnimationView:(UIView *)animationView {
    self.arcLayer.strokeEnd = self->filling ? endPercent : startPercent;
    if (filling) {
        colorIndex++;
        self.arcLayer.strokeColor = [self colorFromCurrentColorIndex];
    }
}

-(void)animateRefreshView {
    [self setupRefreshControlForAnimationView:self.refreshAnimationView];
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        self->filling = !self->filling;
        [self.arcLayer removeAnimationForKey:@"google"];
        rotation += rotationIncrement;
        rotationIncrement = self->filling ? M_PI*5/8.0 : M_PI*15/8.0;
        [self animateRefreshViewEnded];
    }];
    
    CGFloat strokeStartVal = self->filling ? startPercent : endPercent;
    CGFloat strokeEndVal = self->filling ? endPercent : startPercent;
    
    CABasicAnimation *animateStrokeFill = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeFill.fromValue = [NSNumber numberWithFloat:strokeStartVal];
    animateStrokeFill.toValue = [NSNumber numberWithFloat:strokeEndVal];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:rotation];
    rotationAnimation.toValue = [NSNumber numberWithFloat:rotation+rotationIncrement];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    [animationGroup setAnimations:@[animateStrokeFill, rotationAnimation]];
    [animationGroup setDuration:self.animationDuration];
    [animationGroup setRemovedOnCompletion:NO];
    [animationGroup setFillMode:kCAFillModeForwards];
    
    [self.arcLayer addAnimation:animationGroup forKey:@"google"];
    [CATransaction commit];
}

-(void)exitAnimationForRefreshView:(UIView *)animationView withCompletion:(JHCompletionBlock)completion {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.circleView setAlpha:0];
        [self.arcLayer removeAnimationForKey:@"google"];
        completion();
    }];
    CGFloat strokeStartVal = _arcLayer.strokeEnd;
    CGFloat strokeEndVal = 0;
    CABasicAnimation *animateStrokeFill = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeFill.fromValue = [NSNumber numberWithFloat:strokeStartVal];
    animateStrokeFill.toValue = [NSNumber numberWithFloat:strokeEndVal];
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:rotation];
    rotationAnimation.toValue = [NSNumber numberWithFloat:rotation+rotationIncrement];
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    [animationGroup setAnimations:@[animateStrokeFill, rotationAnimation, opacityAnimation]];
    [animationGroup setDuration:self.animationDuration];
    [animationGroup setRemovedOnCompletion:NO];
    [animationGroup setFillMode:kCAFillModeForwards];
    [self.arcLayer addAnimation:animationGroup forKey:@"google"];
    [CATransaction commit];
}

+(CGFloat)height {
    //return the height
    return 60.0;
}

+(NSTimeInterval)animationDuration {
    //return the animation duration
    return 0.6;
}

+(NSTimeInterval)animationDelay {
    //return the animation delay
    return 0.0;
}

@end
