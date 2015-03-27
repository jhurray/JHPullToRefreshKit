//
//  GooglePTRTableViewController.h
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/17/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "GoogleRefreshControl.h"
#import "JHCustomPTRTableViewController.h"

@interface GooglePTRTableViewController : UITableViewController

@property (strong, nonatomic) GoogleRefreshControl *googleControl;

@end
