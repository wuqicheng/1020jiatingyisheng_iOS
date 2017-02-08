//
//  MJRefreshTableFooterView.h
//  weibo
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013年 itcast. All rights reserved.
//  上拉加载更多

#import "MJRefreshBaseView.h"
@interface MJRefreshFooterView : MJRefreshBaseView
@property (nonatomic,assign) bool isLastPage;
@property (nonatomic,strong) NSString *stringPulling,*stringRefreshing,*stringRelease;

+ (id)footer;
@end