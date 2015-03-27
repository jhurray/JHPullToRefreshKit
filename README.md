JHPullToRefreshKit
==================

Abstract base class to easily create pull to refresh controls  
![](./gifs/colors.gif)
<img src="./gifs/bubbles.gif" width="150px"></img>
<div style="width:150px"><img src="./gifs/google.gif"></img></div>
<img src="./gifs/yahoo.gif" style="max-width: 150px"></img>

####Why Another Pull To Refresh Library?
There are lots of PTR libraries out there but none that fit 100% of my needs. PTR controls are awesome when completed but tedious to make. I made this so I would always be able to jump right into the animation, and not having to worry about customization. All you have to do for my implementation is override a few class functions detailing height, animation duration, and what gets run each animation cycle. 

**My implementation provides:**

* [Add to a UITableView or UIScrollView in one line of code](#adding)
* [Customizable height, animation duration, and animation cycles](#subclassing)
* [Optional use of keyframe, spring,](#animation-options) or [CALayer](#calayer) animations
* [Anchoring of the animated view once it is pulled down past its height](#anchor-options)
* [How the PTR control is presented as it is pulled down](#type-options)
* [Exit animations](#exit)

## <a name="adding"></a>Adding to a UIScrollView

You can add the refresh control to a scroll view in one line after you initialize it. The code in the refreshBlock will be called when the scroll view is pulled past its height.

**Important:** You must call  **endRefreshing** to stop the refresh control. A good place to do this is in the callback of a network request.

```objective-c
-(void) viewDidLoad {
	[super viewDidLoad];
	...
	self.myRefreshControl = [[MyRefreshControl alloc] init];
	__weak id weakSelf = self;
	[self.myRefreshControl addToScrollView:self.tableView withRefreshBlock:^{
	     [weakSelf tableViewWasPulledToRefresh];
	}];
	...
}

-(void)tableViewWasPulledToRefresh {
    [self someBigNetworkRequestWithCallback:^{
    	[self.myRefreshControl endRefreshing];
    }];
}
```

##<a name="subclassing"></a>Subclassing JHRefreshControl

**JHRefreshControl** is an abstract base class, which means there are some functions you need to override. The following methods must be implemented or your app will crash. You can find a section of code to copy and paste in *JHRefreshControl.h* with all the methods for your .m file. 

####Abstract Class Methods:

**+(CGFloat)height;** sets the height of the refresh control  
 
**+(NSTimeInterval)animationDuration;**  sets the animation duration of each animation cycle for the refresh control. 

**+(NSTimeInterval)animationDelay;** sets the animation delay for an animation cycle. Defaults to 0.0. Note this **does not** need to be implemented.

####Abstract Instance Methods:

**-(void)setup;** Use this to setup the refresh control. Put setup code here instead of init.  

**-(void)handleScrollingOnAnimationView:(UIView *)animationView
                     withPullDistance:(CGFloat)pullDistance
                        pullRatio:(CGFloat)pullRatio
                         pullVelocity:(CGFloat)pullVelocity;** used to control UI elements during scrolling.
                         
* *pullDistance:* offset of the scroll view
* *pullRatio:* ratio of the offset to the height of the refresh control
* *pullVelocity:* how fast the scroll view is being pulled  

**-(void)setupRefreshControlForAnimationView:(UIView *)animationView;** Set refresh animation to correct state before a new cycle begins.

**-(void)animationCycleForAnimationView:(UIView *)animationView;** UI changes to be animated continuously until **endRefreshing** is called.   

##<a name="under-the-hood"></a>Under The Hood
 
**What is this 'animation cycle' you speak of??**  

An animation cycle is UI code that is repeated inside an animation block. Real life examples are one spin of a yaks head on the yik yak app, or one color change on the snapchat app.

**So Whats really going on??**  

The refresh control has a subview that runs animations. When the refresh control is pulled, it sets up the animation view for a cycle (makes sure the yaks head is at the correct start angle), and then runs the animation (spins the yaks head once.) It then checks to see if **endRefreshing** has been called. If it has, it exits. If it has not, it sets up and then runs the animation again (and continues this pattern until **endRefreshing** is called).  


The process below runs continuously from the time that the scroll view is pulled to refresh to the time that **endRefreshing** is called.  

```
 setupRefreshControlForAnimation
 -> animate [ animation cycle ]
    -> completion [animation cycle finished]
        -> if refreshing:
            recurse (another cycle)
        -> else:
            refreshing ended -> [completion animation]
``` 

##Customization

###Variables

####<a name="type-options"></a> JHRefreshControlType
This is how the refresh control is presented when the scroll view is scrolling down (While offset < height). Must be set in **initWithType:**

* *JHRefreshControlTypeSlideDown:* the refresh control will slide down with the scroll view as it scrolls.
<div>
<img src="./gifs/style-slidedown.gif" style="max-width:200px"></img>
</div>

* *JHRefreshControlTypeBackground:* the refresh control is behind the scroll view and becomes uncovered as the scroll view is scrolled down. 
<div>
<img src="./gifs/style-background.gif" style="max-width:200px; margin:auto"></img>
</div>

```objective-c
MyRefreshControl *refreshControl = [[MyRefreshControl alloc] initWithType:JHRefreshControlTypeSlideDown];
```

####<a name="anchor-options"></a> JHRefreshControlAnchorPosition

This is how the animation view is anchored when the scroll view has been scrolled down past its height. (While offset > height).

* *JHRefreshControlAnchorPositionTop:* The animation view will stick to the top.
<div>
<img src="./gifs/anchor-top.gif" style="max-width: 200px; margin:auto"></img>
</div>

* *JHRefreshControlAnchorPositionMiddle:* The animation view will stretch as the scroll view offset increases and stick in the middle. 
<div>
<img src="./gifs/anchor-middle.gif" style="max-width: 200px; margin:auto"></img>
</div>

* *JHRefreshControlAnchorPositionBottom:* The animation view will stick to the bottom.
<div>
<img src="./gifs/anchor-bottom.gif" style="max-width: 200px; margin:auto"></img>
</div>

```objective-c
self.anchorPosition = JHRefreshControlAnchorPositionTop;
```

####<a name="animation-options"></a> JHRefreshControlAnimationType

This determines the type of animation block that an animation cycle is run in.

* *JHRefreshControlAnimationTypeDefault:* Animation cycle runs inside normal **[UIView animationWithDuration:...]** block.
* *JHRefreshControlAnimationTypeKeyFrame:* Animation cycle runs inside **[UIView animateKeyframesWithDuration:...]** block.
* *JHRefreshControlAnimationTypeSpring:* Animation cycle runs inside **[[UIView animateWithDuration:
                          delay:
                            usingSpringWithDamping: 
                            initialSpringVelocity:...]** block.

```objective-c
self.animationType = JHRefreshControlAnimationTypeDefault;
```

You can also add animation **UIViewAnimationOptions** for these animations. 

```objective-c
self->animationOptions = UIViewAnimationOptionCurveEaseInOut;
```


###<a name="exit"></a> Exit Animations

To add an exit animation like the Yahoo news Digest example I provide, override the following function. The exit animation will be called after **endRefreshing** is called, and before the refresh control is resigned. Make sure to call **completion()** when you are done so the refresh control knows to resign!

**-(void)exitAnimationForRefreshView:(UIView *)animationView withCompletion:(JHCompletionBlock)completion;**  

Below is an example for a *Fade to black* exit animation:

```objective-c
-(void) exitAnimationForRefreshView:(UIView *)animationView withCompletion:(JHCompletionBlock)completion {
    [UIView animateWithDuration:1.0 animations:^{
        self.backgroundColor = [UIColor blackColor];
        self.mySubview.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.mySubview removeFromSuperview];
        completion();
    }];
}

```

##<a name="calayer"></a> CALayer Animations

Some animations are better done using CABasicAnimations. A good example of this is rotating >= 360 degrees. If you want to spin a view 450 degrees, UIView animation blocks will only rotate it 90 degrees. To have a refresh control that performs CABasic Animations you must subclass **JHLayerAnimationRefreshControl** and override one more abstract method. 

**-(CALayer *) targetLayer;** sets the layer that you want animated.  

To add animations to this layer, simply call:  
**-(void)addCABasicAnimationWithKeyPath:(NSString *)keyPath fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue;**  

A good example is in the Yahoo News Digest Example I provided. To spin the dots, I call the above function in **setup**.  

```objective-c
[self addCABasicAnimationWithKeyPath:@"transform.rotation.z" fromValue:0.0 toValue:2*M_PI];
```

This ensures that the layer I return in **targetLayer** will be rotated 360 degrees each animation cycle. 

Note that **setupRefreshControlForAnimationView:** and **animationCycleForAnimationView:** do not need to be overriden when subclassing JHLayerAnimationRefreshControl. You can, however, override thos functions if there are other UIView animations you would like to execute. 

##Contact Info && Contributing

Feel free to email me at [jhurray33@gamil.com](mailto:jhurray33@gmail.com?subject=JHPullToRefreshKit). I'd love to hear your thoughts on this, or see examples where this has been used.

