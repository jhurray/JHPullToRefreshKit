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
    NSString *message = [NSString stringWithFormat:@"Added CABasicAnimation with Keypath %@", keyPath];
    JHPTR_DEBUG(message)
}

-(void)animateRefreshView {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [[self targetLayer] removeAnimationForKey:@"groupedRefreshControlAnimation"];
        [self animateRefreshViewEnded];
    }];
    
    // if there are view animations as well
    JHPTR_DEBUG(@"Setting up animation view for new cycle.")
    [self setupRefreshControlForAnimationView:self.refreshAnimationView];
    [UIView animateWithDuration:self.animationDuration animations:^{
       [self animationCycleForAnimationView:self.refreshAnimationView];
    }];
    
    // layer animations
    JHPTR_DEBUG(@"Starting animation cycle.")
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    [animationGroup setAnimations:[self.animations allValues]];
    [animationGroup setDuration:self.animationDuration];
    [animationGroup setRemovedOnCompletion:NO];
    [animationGroup setFillMode:kCAFillModeForwards];
    [[self targetLayer] addAnimation:animationGroup forKey:@"groupedRefreshControlAnimation"];
    [CATransaction commit];
    [self.delegate refreshControlDidStartAnimationCycle:self];
}

// ABSTRACT CLASS METHOD

-(CALayer *) targetLayer {
    MustOverride();
}

#pragma So they do not need to be overriden

-(void)setupRefreshControlForAnimationView:(UIView *)animationView {
    // Set refresh animation to correct state before a new cycle begins
}

-(void)animationCycleForAnimationView:(UIView *)animationView {
    // UI changes to be animated each cycle
    
}

@end
