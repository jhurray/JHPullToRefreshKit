//
//  JHLayerAnimationRefreshControl.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/19/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#define JHRefreshControlBaseClass_protected

#import "JHLayerAnimationRefreshControl.h"

@interface JHLayerAnimationRefreshControl()

@property (strong, nonatomic) NSMutableDictionary *animations;
@property (strong, nonatomic) CALayer *targetLayer;

@end

@implementation JHLayerAnimationRefreshControl

-(void)setupRefreshControl {
    [super setupRefreshControl];
    self.animations = [[NSMutableDictionary alloc] init];
}

// Will add a CABasicAnimation to the target layer
// gets grouped in the background
-(void)addCABasicAnimationWithKeyPath:(NSString *)keyPath fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    [self.animations setObject:animation forKey:keyPath];
}

-(void)animateRefreshView {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self animateRefreshViewEnded];
        [[[self class] targetLayer] removeAnimationForKey:@"groupedRefreshControlAnimation"];
    }];
    
    [self animationCycleForAnimationView:self.refreshAnimationView];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    [animationGroup setAnimations:[self.animations allValues]];
    [animationGroup setDuration:self.animationDuration];
    [animationGroup setRemovedOnCompletion:NO];
    [animationGroup setFillMode:kCAFillModeForwards];
    [[[self class] targetLayer] addAnimation:animationGroup forKey:@"groupedRefreshControlAnimation"];
    
    [CATransaction commit];
}

// ABSTRACT CLASS METHOD

+(CALayer *) targetLayer {
    MustOverride();
}

@end
