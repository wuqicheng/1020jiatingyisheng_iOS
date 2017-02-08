//
//  AppsBaseTableViewController.h
//  BanJi
//
//  Created by Vescky on 14-8-8.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
//@class MJRefreshHeaderView,MJRefreshFooterView;
@interface AppsBaseTableViewController : AppsBaseViewController {
    IBOutlet UITableView *tbView;
    NSMutableArray *dataSource;
}

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) bool disableRefresh,disableLoadMore;
@property (nonatomic,assign) bool isLastPage;
@property (nonatomic,strong) MJRefreshHeaderView *_header;
@property (nonatomic,strong) MJRefreshFooterView *_footer;

- (void)stopRefreshing;

@end
