//
//  ColorPTRTableViewController.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/15/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "ColorPTRTableViewController.h"

@implementation ColorPTRTableViewController

-(void)tableViewWasPulledToRefresh {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"colors"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"colors"];
    }
    cell.textLabel.text = @"colors!!!";
    return cell;
}

@end
