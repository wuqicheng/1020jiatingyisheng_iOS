//
//  HealthyFilesViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "HealthyFilesViewController.h"
#import "FillInfoViewController.h"
#import "HealthyFileDetailViewController.h"
#import "UserSessionCenter.h"
#import "UIImageView+MJWebCache.h"

#import "MyAlertView.h"

@interface HealthyFilesViewController () {
    NSDictionary *healthRecordInfo;
    NSMutableArray *dataSource;
}

@end

@implementation HealthyFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"评估报告";
    [self customBackButton];
    
    dataSource = [[NSMutableArray alloc] init];
    
    [self getHealthRecord];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    labelName.text = [[UserSessionCenter shareSession] getUserNickName];
    [imgvAvatar setImageURLStr:[[UserSessionCenter shareSession] getUserAvatar] placeholder:Defualt_Avatar_Image];
    imgvAvatar.layer.cornerRadius = imgvAvatar.frame.size.width / 2.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAction:(UIButton*)sender {
    MyAlertView *myAlert = [[MyAlertView alloc] initWithTitle:@"评估报告" alertContent:@"评估报告是1020家庭医生团队为购买相关服务的客户所做的健康评估，便于客户、监护人和后台医生随时查看，配合执行。\n评估报告由1020家庭医生负责维护和更新，客户和监护人无法修改。" style:MyAlertViewStyleI_Know];
    [myAlert show];
}

#pragma mark - Data
///VIP档案
- (void)getHealthRecord {
    [SVProgressHUD showWithStatus:String_Loading];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getHealthRecordByUser.action" param:params onCompletion:^(id jsonResponse) {
        if (isValidArray([jsonResponse objectForKey:@"rows"])) {
            healthRecordInfo = [[jsonResponse objectForKey:@"rows"] firstObject];
        }
        [self getBodyCheckReport];
    } onError:^(NSError *error) {
        [self getBodyCheckReport];
    } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
    
}
///体检报告
- (void)getBodyCheckReport {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getPhysicalReporByUser.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if (isValidArray([jsonResponse objectForKey:@"rows"])) {
            dataSource = [[NSMutableArray alloc] initWithArray:[jsonResponse objectForKey:@"rows"]];
        }
        [tbView reloadData];
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
    //dataSource = @[@{@"report_name":@"检查项目的异常指标及其分析",@"last_update_date":@"2016-01-13"}];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count+2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = cell1;
    }
    else if (indexPath.row == 1) {
        cell = cell2;
    }
    else {
        NSString *reusedIdentify = @"BodyCheckReportCell";
        cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        //init cell
        if (indexPath.row-2 < dataSource.count) {
            if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
                [cell performSelector:@selector(setCellDataInfo:) withObject:[dataSource objectAtIndex:indexPath.row-2]];
            }
        }
        
        
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 100.f;
    }
    else if (indexPath.row == dataSource.count+2-1) {
        //最后一个cell
        return 54.f;
    }
    else {
        return 55.f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    if (indexPath.row == 0) {
        FillInfoViewController *fVc = [[FillInfoViewController alloc] init];
        [self.navigationController pushViewController:fVc animated:YES];
    }
    else {
        HealthyFileDetailViewController *hDetailVc = [[HealthyFileDetailViewController alloc] init];
        
        if (indexPath.row == 1) {
            
            hDetailVc.detailInfo = healthRecordInfo;
        }
        else {
            hDetailVc.detailInfo = [dataSource objectAtIndex:indexPath.row-2];
            hDetailVc.isReport = YES;
        }
        
        if (!isValidDictionary(hDetailVc.detailInfo)) {
            [SVProgressHUD showErrorWithStatus:@"暂无记录"];
            return;
        }
        [self.navigationController pushViewController:hDetailVc animated:YES];
    }
    
}

@end
