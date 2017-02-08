//
//  FollowUpListViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "FollowUpListViewController.h"
#import "FollowUpDetailViewController.h"
#import "UserSessionCenter.h"
#import "MyAlertView.h"

@interface FollowUpListViewController () {
    NSInteger currentPage;
}

@end

@implementation FollowUpListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"随访指导";
    [self customBackButton];
    [self refreshData];
}

- (IBAction)btnAction:(UIButton*)sender {
    MyAlertView *myAlert = [[MyAlertView alloc] initWithTitle:@"随访指导" alertContent:@"随访指导是后台家庭医生团队为您在计划执行过程中提供的药方、健康建议等内容，请及时查看，认真执行。" style:MyAlertViewStyleI_Know];
    [myAlert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data
- (void)refreshData {
    currentPage = 1;
    dataSource = [[NSMutableArray alloc] init];
    [self getData];
}

//need to over write
- (void)loadMoreData  {
    currentPage++;
    [self getData];
}

- (void)getData {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id",@(currentPage),@"page", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getFollowVisitByUser.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        if ([[jsonResponse objectForKey:@"remain_page"] integerValue] <= 0) {
            self.isLastPage = YES;
        }
        else {
            self.isLastPage = NO;
        }
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [dataSource addObjectsFromArray:[jsonResponse objectForKey:@"rows"]];
            [tbView reloadData];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
        
        if (!isValidArray(dataSource)) {
            //无数据？
            tbView.hidden = YES;
            labelNoData.hidden = NO;
        }
        else {//有数据
            tbView.hidden = NO;
            labelNoData.hidden = YES;
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}


#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reusedIdentify = @"FollowUpListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //init cell
    if (indexPath.row < dataSource.count) {
        if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
            [cell performSelector:@selector(setCellDataInfo:) withObject:[dataSource objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select at row:%ld",indexPath.row);
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    FollowUpDetailViewController *fDetailVc = [[FollowUpDetailViewController alloc] init];
    fDetailVc.detailInfo = [dataSource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:fDetailVc animated:YES];
}


@end
