//
//  ViewController.m
//  JHPullToRefreshExampleProj
//
//  Created by Jeff Hurray on 12/14/14.
//  Copyright (c) 2014 jhurray. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *viewControllers;

@end

@implementation ViewController

-(id)initWithViewControllers:(NSArray *)vcs {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.viewControllers = vcs;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewControllers.count;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return !section ? @"Cool examples" : @"Examples of customization options";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)self.viewControllers[section]).count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [[self.viewControllers objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"vcs"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"vcs"];
    }
    
    UIViewController *vc = [[self.viewControllers objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = vc.title;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
