//
//  BubblesPTRTableViewController.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/16/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "BubblesPTRTableViewController.h"

@implementation BubblesPTRTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if ([self.title containsString:@"SlideDown"]) {
        self.bubbleControl = [[BubbleRefreshControl alloc] initWithType:JHRefreshControlTypeSlideDown];
    } else {
        self.bubbleControl = [[BubbleRefreshControl alloc] initWithType:JHRefreshControlTypeBackground];
    }
    
    if ([self.title containsString:@"Top"]) {
        self.bubbleControl.anchorPosition = JHRefreshControlAnchorPositionTop;
    } else if ([self.title containsString:@"Bottom"]) {
        self.bubbleControl.anchorPosition = JHRefreshControlAnchorPositionBottom;
    } else {
        self.bubbleControl.anchorPosition = JHRefreshControlAnchorPositionMiddle;
    }
    
    __weak id weakSelf = self;
    [self.bubbleControl addToScrollView:self.tableView withRefreshBlock:^{
        [weakSelf tableViewWasPulledToRefresh];
    }];

}

-(void)tableViewWasPulledToRefresh {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.bubbleControl endRefreshing];
    });
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"header title";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"bubbles"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bubbles"];
    }
    cell.textLabel.text = self.title;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}

@end
