//
//  JHLayerAnimationRefreshControl.h
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/19/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "JHRefreshControl.h"

@interface JHLayerAnimationRefreshControl : JHRefreshControl

// Will add a CABasicAnimation to the target layer
// gets grouped in the background
// call in setup function
// If you want to change the animations over time, call again in animationCycleForAnimationView
-(void)addCABasicAnimationWithKeyPath:(NSString *)keyPath fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue;

/**************************************
 Abstract Class Method
 Must be overriden in subclasses
 **************************************/

// return target layer for CAAnimation to be added to
-(CALayer *)targetLayer;

@end

/*
 COPY AND PASTE TO OVERRIDE functions
 
 -(void)setup {
 // use this to setup the refresh control.
 // put setup code here instead of init
 }
 
 -(void)handleScrollingOnAnimationView:(UIView *)animationView
 withPullDistance:(CGFloat)pullDistance
 pullRatio:(CGFloat)pullRatio
 pullVelocity:(CGFloat)pullVelocity {
 // used to control UI elements during scrolling
 }
 
 -(void)resetAnimationView:(UIView *)animationView {
 // should reset UI elements here
 // called after refresh control finishes and is hidden
 }
 
 -(void)setupRefreshControlForAnimationView:(UIView *)animationView {
 // Set refresh animation to correct state before a new cycle begins
 }
 
 -(void)animationCycleFor
 AnimationView:(UIView *)animationView {
 // UI changes to be animated each cycle
 }
 
 -(void)exitAnimationForRefreshView:(UIView *)animationView withCompletion:(JHCompletionBlock)completion {
 // animation for when refreshing is done.
 // does not need to be overridden
 // if empty no animation will be executed
 completion();
 }
 
 +(CGFloat)height {
 //return the height
 }
 
 +(NSTimeInterval)animationDuration {
 //return the animation duration
 }
 
 +(NSTimeInterval)animationDelay {
 //return the animation delay
 }
 
 +(CALayer *)targetLayer {
    // return target layer for CAAnimation to be added to
 }
 
 */