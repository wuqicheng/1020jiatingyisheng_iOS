//
//  UserHealthWarn_VC.m
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/12/2.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import "UserHealthWarn_VC.h"
#import "UserHealthWarn_Cell.h"
#import "UserSessionCenter.h"
#import "UserHealthWarnResult_VC.h"
@interface UserHealthWarn_VC () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) NSInteger page;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@end

@implementation UserHealthWarn_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customBackButton];
    self.title = @"我的健康预警";
    [tbView registerNib:[UINib nibWithNibName:@"UserHealthWarn_Cell" bundle:nil] forCellReuseIdentifier:@"UserHealthWarn_Cell"];
    [self showNoData:NO];
    _page = 1;
    [self requestData];
}

#pragma mark - Private
- (void)showNoData:(bool)showOn {
    self.noDataLabel.hidden = !showOn;
    tbView.hidden = showOn;
}

#pragma mark RequestData
- (void)requestData {
    __weakSelf_(weakSelf);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(_page) forKey:@"page"];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getExamResultListByAPP.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (jsonResponse[@"remain_page"] && [[NSString stringWithFormat:@"%@", jsonResponse[@"remain_page"]] integerValue] == 0) {
                weakSelf.isLastPage = YES;
            }else {
                weakSelf.isLastPage = NO;
            }
            
            if (weakSelf.page == 1) {
                [weakSelf.dataSource removeAllObjects];
            }
            if (isValidArray(arr)) {
                [weakSelf.dataSource addObjectsFromArray:arr];
                [tbView reloadData];
                [weakSelf showNoData:NO];
                weakSelf.page++;
            }else {
                [weakSelf showNoData:YES];
            }
        }
    } onError:^(NSError *error) {
        [weakSelf showNoData:YES];
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
        [weakSelf stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}


#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserHealthWarn_Cell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserHealthWarn_Cell"];
    NSDictionary *dic = dataSource[indexPath.row];
    cell.titleLabel.text = dic[@"project_title"];
    cell.timeLabel.text = dic[@"create_date"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserHealthWarnResult_VC *vc = [[UserHealthWarnResult_VC alloc] init];
    vc.dic = dataSource[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
    vc.blockCancelCollect = ^() {
        [dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        if (dataSource.count == 0) {
            [self showNoData:YES];
        }
    };
}


#pragma mark 上下拉刷新
//need to over write
- (void)refreshData {
    NSLog(@"下拉");
    self.page = 1;
    [self requestData];
}

//need to over write
- (void)loadMoreData  {
    NSLog(@"上拉");
    [self requestData];
}

@end
