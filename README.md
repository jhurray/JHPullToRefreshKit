JHPullToRefreshKit
==================

Abstract wrapper to easily create pull to refresh controls 

##Abstract UITableViewController that contains a JHRefreshControl

```objective-c
//
//  JHCustomPTRTableViewController.h
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/14/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "JHPullToRefreshKit.h"
#import "JHRefreshControl.h"
#import <UIKit/UIKit.h>

@interface JHCustomPTRTableViewController : UITableViewController

-(id)initWithRefreshControl:(JHRefreshControl *)refreshControl;
-(id)initWithRefreshControl:(JHRefreshControl *)refreshControl tableViewStyle:(UITableViewStyle)style ;

// Abstract method
// Must override
-(void)tableViewWasPulledToRefresh;

@end

```

##Abstract refresh control

```objective-c
//
//  JHRefreshControl.h
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/14/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "JHPullToRefreshKit.h"
#import <UIKit/UIKit.h>

@class JHRefreshControl;

@protocol JHRefreshControlDelegate <NSObject>

-(void)refreshControlDidStart:(JHRefreshControl *)refreshControl;
-(void)refreshControlDidEnd:(JHRefreshControl *)refreshControl;

@end


typedef NS_ENUM(NSInteger, JHRefreshControlType) {
    JHRefreshControlTypeSlideDown,
    JHRefreshControlTypeBackground
};


@interface JHRefreshControl : UIControl <UIScrollViewDelegate>{
    @public
    JHRefreshControlType _type;
}

// Read only properties
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) NSTimeInterval animationDuration;
@property (nonatomic, readonly) NSTimeInterval animationDelay;

// delegate
@property (weak, nonatomic) id<JHRefreshControlDelegate> delegate;

// Constructors
-(id)initWithType:(JHRefreshControlType)type;

// Instance methods
// manual refresh
-(void)forceRefresh;
// called to end the animation
-(void)endRefreshing;
// called to add a subview to the animation view
-(void)addSubviewToRefreshAnimationView:(UIView *)subview;

// Abstract Instance Methods
// Must be overriden in subclasses

// used to control UI elements during scrolling
-(void)handleScrollingOnAnimationView:(UIView *)animationView
                     withPullDistance:(CGFloat)pullDistance
                        pullRatio:(CGFloat)pullRatio
                         pullVelocity:(CGFloat)pullVelocity;

/*
 Animation Pattern for Refresh Control:
 
 setupRefreshControlForAnimation
 -> animate [ animation cycle ]
    -> completion
        -> if refreshing:
            another cycle
        -> else:
            refreshing ended
 */

// Set refresh animation to correct state before a new cycle begins
-(void)setupRefreshControlForAnimationView:(UIView *)animationView;

// UI changes to be animated each cycle
-(void)animationCycleOnAnimationView:(UIView *)animationView;

// Abstract Class Methods
// Must be overriden in subclasses
+(CGFloat)height;
+(NSTimeInterval)animationDuration;
+(NSTimeInterval)animationDelay;

@end


/*
 COPY AND PASTE TO OVERRIDE functions
 
 -(void)handleScrollingOnAnimationView:(UIView *)animationView
                         withPullDistance:(CGFloat)pullDistance
                         pullRatio:(CGFloat)pullRatio
                         pullVelocity:(CGFloat)pullVelocity {
    // used to control UI elements during scrolling
 }
 
-(void)setupRefreshControlForAnimationView:(UIView *)animationView {
    // Set refresh animation to correct state before a new cycle begins
 }
 
-(void)animationCycleOnAnimationView:(UIView *)animationView {
    // UI changes to be animated each cycle
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

*/


#ifdef JHRefreshControlBaseClass_protected

// this is the class extension, where you define
// the "protected" properties and methods of the class
// add "#define JHRefreshControlBaseClass_protected"
// to the top of your .m file to override these methods.
// only do this if you understand the implementation well.

@interface JHRefreshControl()

// where animations should be done
@property (strong, nonatomic) UIView *refreshAnimationView;

// allows writing to refreshing
@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;

// sends a ValueChanged notification
-(void)refresh;

// override to completely change animation pattern
// (For example conform to CAAnimation with animation delegate as completion)
-(void)animateRefreshView;

// calls refresh control delegate
-(void)resetAnimation;

// Called during initialization.
-(void)setupRefreshControl;

// from UIScrollViewDelegate
-(void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView;
-(void)containingScrollViewDidScroll:(UIScrollView *)scrollView;

// extends frame if offset > height
-(void)setFrameForScrollingWithOffset:(CGFloat)offset;

@end

#endif
```