//
//  JHCustomPTRTableViewController.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/14/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#define JHRefreshControlBaseClass_protected

#import "JHCustomPTRTableViewController.h"

@interface JHCustomPTRTableViewController()<UIScrollViewDelegate, JHRefreshControlDelegate>{
    @private
    double resetAnimationDuration;
}

@property (strong, nonatomic) JHRefreshControl *refreshControl;

-(void)setupWithRefreshControl:(JHRefreshControl *)refreshControl;
-(void)setScrollViewTopInsets:(CGFloat)offset;
-(void)scrollTableViewToTop;

@end

@implementation JHCustomPTRTableViewController

@synthesize refreshControl = _refreshControl;

-(id)initWithRefreshControl:(JHRefreshControl *)refreshControl tableViewStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self setupWithRefreshControl:refreshControl];
    }
    return self;
}

-(id)initWithRefreshControl:(JHRefreshControl *)refreshControl {
    if (self = [super init]) {
        [self setupWithRefreshControl:refreshControl];
    }
    return self;
}

-(void)tableViewWasPulledToRefresh {
    MustOverride();
}

// Private

-(void) setupWithRefreshControl:(JHRefreshControl *)refreshControl {
    resetAnimationDuration = 0.3;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _refreshControl = refreshControl;
    _refreshControl.delegate = self;
    [_refreshControl addTarget:self action:@selector(tableViewWasPulledToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    if (_refreshControl->_type == JHRefreshControlTypeBackground) {
        [self.tableView sendSubviewToBack:_refreshControl];
    }
}

-(void)setScrollViewTopInsets:(CGFloat)offset {
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top += offset;
    self.tableView.contentInset = insets;
}

-(void)scrollTableViewToTop {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

// Refresh Control Delegate

-(void)refreshControlDidStart:(JHRefreshControl *)refreshControl {
    __weak id weakSelf = self;
    [UIView animateWithDuration:resetAnimationDuration animations:^{
        [weakSelf setScrollViewTopInsets: refreshControl.height];
    } completion:nil];
}

-(void) refreshControlDidEnd:(JHRefreshControl *)refreshControl {
    __weak id weakSelf = self;
    [UIView animateWithDuration:resetAnimationDuration animations:^{
        [weakSelf setScrollViewTopInsets: -refreshControl.height];
    } completion:^(BOOL finished) {
        [weakSelf scrollTableViewToTop];
    }];
}

// Scroll View Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshControl containingScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshControl containingScrollViewDidEndDragging:scrollView];
}

@end
