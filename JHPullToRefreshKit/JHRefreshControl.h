//
//  JHRefreshControl.h
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/14/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "JHPullToRefreshKit.h"
#import <UIKit/UIKit.h>

/**************************************
            Enums
 **************************************/

typedef NS_ENUM(NSInteger, JHRefreshControlType) {
    JHRefreshControlTypeSlideDown,
    JHRefreshControlTypeBackground
};

typedef NS_ENUM(NSInteger, JHRefreshControlAnimationType) {
    JHRefreshControlAnimationTypeDefault,
    JHRefreshControlAnimationTypeKeyFrame,
    JHRefreshControlAnimationTypeSpring
};

typedef NS_ENUM(NSInteger, JHRefreshControlAnchorPosition) {
    JHRefreshControlAnchorPositionTop,
    JHRefreshControlAnchorPositionMiddle,
    JHRefreshControlAnchorPositionBottom
};


/**************************************
        Delegate
 **************************************/

@class JHRefreshControl;
@protocol JHRefreshControlDelegate <NSObject>

-(void)refreshControlDidStart:(JHRefreshControl *)refreshControl;
-(void)refreshControlDidEnd:(JHRefreshControl *)refreshControl;

@optional
-(void)refreshControlDidStartAnimationCycle:(JHRefreshControl *)refreshControl;
-(void)refreshControlDidEndAnimationCycle:(JHRefreshControl *)refreshControl;

@end

/**************************************
 * * * * * * * * * * * * * * * * * * * *
 *  *  *  *  *  *  *  *  *  *  *  *  *  *
 *   *  JHRefreshControl Interface  *   *
 *  *  *  *  *  *  *  *  *  *  *  *  *  *
 * * * * * * * * * * * * * * * * * * * *
 **************************************/

typedef void (^JHCompletionBlock)(void);


@interface JHRefreshControl : UIControl{
    
    @public
    // type of refresh control
    JHRefreshControlType _type;
    
    @public
    // Depending on type of animation...
    // When Default of Spring:
    //      assign UIViewAnimationOptions
    // When KeyFrame:
    //      assign UIViewKeyframeAnimationOptions
    // Defaults to 0
    NSInteger animationOptions;
}

/**************************************
        Properties
 **************************************/


// Determines refresh animation view position when the tableView is stretched
// When Top / Bottom:
//       Animated refresh view will stick to the Top / Bottom (constant height)
// When Middle:
//       Animated refresh view will stretch with table view (variable height)
// Defaults to Top
@property (nonatomic, assign) JHRefreshControlAnchorPosition anchorPosition;

// Type of animation wrapped around the animation cycle
// When Default:
//      animations will be normal
// When KeyFrame:
//      call [UIView addKeyframeAnimation...]
// When Spring:
//      aniamtions will all have springy properties
@property (nonatomic, assign) JHRefreshControlAnimationType animationType;

// Read only properties
@property (atomic, readonly, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) NSTimeInterval animationDuration;
@property (nonatomic, readonly) NSTimeInterval animationDelay;

// delegate
@property (weak, nonatomic) id<JHRefreshControlDelegate> delegate;

/**************************************
        Constructors
 **************************************/

-(id)initWithType:(JHRefreshControlType)type;

/**************************************
        Instance Methods
 **************************************/

// attach to a UIScrollView
-(void)addToScrollView:(UIScrollView *)scrollView withRefreshBlock:(void(^)())refreshBlock;

// manual refresh
-(void)forceRefresh;
// called to end the animation
-(void)endRefreshing;
// should reset UI elements here
// called after refresh control finishes and is hidden
-(void)resetAnimationView:(UIView *)animationView;
// called to add a subview to the animation view
-(void)addSubviewToRefreshAnimationView:(UIView *)subview;

/**************************************
    Abstract Instance Methods
    Must be overriden in subclasses
**************************************/

// use this to setup the refresh control.
// put setup code here instead of init
-(void)setup;

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
            recurse (another cycle)
        -> else:
            refreshing ended -> [completion animation]
 */

// Set refresh animation to correct state before a new cycle begins
-(void)setupRefreshControlForAnimationView:(UIView *)animationView;

// UI changes to be animated each cycle
-(void)animationCycleForAnimationView:(UIView *)animationView;

// animation for when refreshing is done.
// does not need to be overridden
// if empty no animation will be executed
-(void)exitAnimationForRefreshView:(UIView *)animationView withCompletion:(JHCompletionBlock)completion;

/**************************************
    Abstract Class Methods
    Must be overriden in subclasses
**************************************/

+(CGFloat)height;
+(NSTimeInterval)animationDuration;

// Does NOT need to be overriden but feel free.
// Defaults to 0.0
+(NSTimeInterval)animationDelay;

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

*/


#ifdef JHRefreshControlBaseClass_protected

// this is the class extension, where you define
// the "protected" properties and methods of the class
// add "#define JHRefreshControlBaseClass_protected"
// to the top of your .m file to override these methods.
// only do this if you understand the implementation well.

@interface JHRefreshControl()

// scrollView that the refreshControl is added to
@property (strong, nonatomic) UIScrollView *parentScrollView;

// where animations should be done
@property (strong, nonatomic) UIView *refreshAnimationView;

// allows writing to refreshing
@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;

// sends a ValueChanged notification
-(void)refresh;

// override to completely change animation pattern
// (For example conform to CAAnimation with animation delegate as completion)
-(void)animateRefreshView;

// called when the animation ends
// either recurses or resets and hides
-(void)animateRefreshViewEnded;

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
