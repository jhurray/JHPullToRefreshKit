//
//  ColorPTRTableViewController.h
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/15/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "ColorChangeRefreshControl.h"
#import "JHCustomPTRTableViewController.h"

@interface ColorPTRTableViewController : UITableViewController

@property (strong, nonatomic) ColorChangeRefreshControl *colorControl;

@end
