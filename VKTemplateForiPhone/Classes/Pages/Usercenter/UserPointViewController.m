//
//  UserPointViewController.m
//  VKTemplateForiPhone
//
//  Created by Vescky on 15/3/2.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "UserPointViewController.h"
#import "UserSessionCenter.h"

@interface UserPointViewController () {
    NSInteger page;
    NSIndexPath *indexPathToDelete;
}

@end

@implementation UserPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self customBackButton];
    self.title = @"消费记录";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView {
    self.view.backgroundColor = GetColorWithRGB(238, 238, 238);
    [self refreshData];
}

#pragma mark - Data
//need to over write
- (void)refreshData {
    page = 1;
    dataSource = [[NSMutableArray alloc] init];
    [self getData];
}

//need to over write
- (void)loadMoreData  {
    page++;
    [self getData];
}

- (void)getData {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id",@(page),@"page",nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getUserConsumeMoneyList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        
        if ([[jsonResponse objectForKey:@"remain_page"] integerValue] <= 0) {
            self.isLastPage = YES;
        }
        else {
            self.isLastPage = NO;
        }
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            if (isValidArray([jsonResponse objectForKey:@"rows"])) {
                [dataSource addObjectsFromArray:[jsonResponse objectForKey:@"rows"]];
                [tbView reloadData];
            }
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
        
        [self checkIfNeedToShowNoDataView];
        
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        [self checkIfNeedToShowNoDataView];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (void)checkIfNeedToShowNoDataView {
    if (dataSource.count <= 0) {
        [self showNoDataWithTips:@"暂无消费记录"];
        tbView.hidden = YES;
    }
    else {
        [self showNoData:NO];
        tbView.hidden = NO;
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reusedIdentify = @"UserPointRecordCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    //init cell
    if (indexPath.row < dataSource.count) {
        if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
            [cell performSelector:@selector(setCellDataInfo:) withObject:[dataSource objectAtIndex:indexPath.row]];
        }
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select at row:%d",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        indexPathToDelete = indexPath;
//        [self showAlertWithTitle:nil message:@"确定要删除该记录？" cancelButton:@"删除" sureButton:@"取消"];
//    }
//}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (!indexPathToDelete) {
            return;
        }
        NSDictionary *dic = [dataSource objectAtIndex:indexPathToDelete.section];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [dic objectForKey:@"score_trade_id"],@"score_trade_id",
                                       [[UserSessionCenter shareSession] getUserId],@"user_id",nil];
        [SVProgressHUD showWithStatus:@"删除中..."];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"deleteScoreTradeById.action" param:params onCompletion:^(id jsonResponse) {
            if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
                [SVProgressHUD showSuccessWithStatus:@"删除成功!"];
                [dataSource removeObjectAtIndex:indexPathToDelete.row];
                [tbView deleteRowsAtIndexPaths:@[indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"删除失败，请重试!"];
            }
        } onError:^(NSError *error) {
            
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }
}


@end
