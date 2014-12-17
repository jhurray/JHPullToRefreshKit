//
//  YahooViewController.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 2/26/15.
//  Copyright (c) 2015 jhurray. All rights reserved.
//

#import "YahooRefreshControl.h"
#import "YahooViewController.h"

@interface YahooViewController ()

@property (strong, nonatomic) YahooRefreshControl *yahoo;

@end

@implementation YahooViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.yahoo = [[YahooRefreshControl alloc] initWithType:JHRefreshControlTypeSlideDown];
    __weak id weakSelf = self;
    [self.yahoo addToScrollView:self.tableView withRefreshBlock:^{
        [weakSelf tableViewWasPulledToRefresh];
    }];
}

-(void)tableViewWasPulledToRefresh {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.yahoo endRefreshing];
    });
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Yahoo"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Yahoo"];
    }
    cell.textLabel.text = @"Yahoo!!!";
    return cell;
}

@end
