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

/**************************************
 Abstract Instance Method
 Must be overriden in subclasses
 **************************************/
-(void)tableViewWasPulledToRefresh;

@end
