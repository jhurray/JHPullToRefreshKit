//
//  GooglePTRTableViewController.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/17/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "GooglePTRTableViewController.h"

@implementation GooglePTRTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.googleControl = [[GoogleRefreshControl alloc] initWithType:JHRefreshControlTypeBackground];
    __weak id weakSelf = self;
    [self.googleControl addToScrollView:self.tableView withRefreshBlock:^{
        [weakSelf tableViewWasPulledToRefresh];
    }];
}

-(void)tableViewWasPulledToRefresh {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.googleControl endRefreshing];
    });
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Google"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Google"];
    }
    cell.textLabel.text = @"Google!!!";
    return cell;
}

@end
