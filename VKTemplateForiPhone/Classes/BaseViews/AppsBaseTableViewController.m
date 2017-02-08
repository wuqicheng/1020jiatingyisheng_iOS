//
//  AppsBaseTableViewController.m
//  BanJi
//
//  Created by Vescky on 14-8-8.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "AppsBaseTableViewController.h"

@interface AppsBaseTableViewController ()<MJRefreshBaseViewDelegate> {
    
}
@end

@implementation AppsBaseTableViewController
@synthesize dataSource;
@synthesize disableLoadMore,disableRefresh,isLastPage = _isLastPage;
@synthesize _header,_footer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dataSource = [[NSMutableArray alloc] init];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setIsLastPage:(bool)isLastPage {
    _isLastPage = isLastPage;
    if (!disableLoadMore) {
        _footer.isLastPage = isLastPage;
    }
}

- (void)initRefreshView {
    if (!disableLoadMore) {
        _footer = [MJRefreshFooterView footer];
        _footer.scrollView = tbView;
        _footer.delegate = self;
       
    }
    if (!disableRefresh) {
        _header = [MJRefreshHeaderView header];
        _header.scrollView = tbView;
        _header.delegate = self;
    }
}

- (void)stopRefreshing{
    [_header endRefreshing];
    [_footer endRefreshing];
}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView {
    if (refreshView == _header) {
        //刷新
        [self refreshData];
    }
    else {
        //加载更多
        [self loadMoreData];
    }
}

//need to over write
- (void)refreshData {
    
}

//need to over write
- (void)loadMoreData  {
    
}



@end
