//
//  MedicalReportViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "MedicalReportViewController.h"
#import "MedicalReportAddNewViewController.h"
#import "MedicalReportDetailViewController.h"
#import "UserSessionCenter.h"

#import "MyAlertView.h"

@interface MedicalReportViewController () {
    NSInteger currentPage1,currentPage2;
    NSMutableArray *dataSource2;
    NSIndexPath *indexPathToDelete;
}

@end

@implementation MedicalReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"健康记录";
    [self customBackButton];
    [self customNavigationBarItemWithImageName:@"icon_add.png" isLeft:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    MedicalReportAddNewViewController *mAddNewVc = [[MedicalReportAddNewViewController alloc] init];
    [self.navigationController pushViewController:mAddNewVc animated:YES];
}

#pragma mark - Button Action
- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == 100) {
        if (btn1.selected) {
            return;
        }
        [btnButtom setTitle:@"我的病历是什么?" forState:UIControlStateNormal];
        btn1.selected = YES;
        cursor1.hidden = NO;
        btn2.selected = NO;
        cursor2.hidden = YES;
        [self refreshData];
    }
    else if (sender.tag == 101) {
        if (btn2.selected) {
            return;
        }
        [btnButtom setTitle:@"健康活动记录是什么？" forState:UIControlStateNormal];
        btn1.selected = NO;
        cursor1.hidden = YES;
        btn2.selected = YES;
        cursor2.hidden = NO;
        [self refreshData];
    }
    else if (sender.tag == 102) {
        MyAlertView *myAlert = [[MyAlertView alloc] initWithTitle:@"健康活动记录" alertContent:@"请按医嘱及时将您的血压、血糖、心率等测量数据以及、用药、饮食运动等健康资料上传，便于后台医生和监护人随时了解您的健康状况，以提供更精准周到的服务。"  style:MyAlertViewStyleI_Know];
        
        if (btn1.selected) {
            myAlert = [[MyAlertView alloc] initWithTitle:@"我的病历" alertContent:@"我的病历是永久保存病历的超强神器。你可以随时随地自己（或委托后台医生帮您）上传和删减病历、化验单等资料，方便自己调阅，也可供后台医生查看分析。"  style:MyAlertViewStyleI_Know];
        }
        
        [myAlert show];
    }
}

#pragma mark - Load Data
//need to over write
- (void)refreshData {
    if (btn1.selected) {
        currentPage1 = 1;
        dataSource = [[NSMutableArray alloc] init];
        [self getMedicalReports];
    }
    else {
        currentPage2 = 1;
        dataSource2 = [[NSMutableArray alloc] init];
        [self getHealthyRecords];
    }
}

//need to over write
- (void)loadMoreData  {
    if (btn1.selected) {
        currentPage1++;
        [self getMedicalReports];
    }
    else {
        currentPage2++;
        [self getHealthyRecords];
    }
}

- (void)getMedicalReports {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(currentPage1),@"page",
                                   [[UserSessionCenter shareSession] getUserId],@"user_id",nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getMedicalRecordList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        if ([[jsonResponse objectForKey:@"remain_page"] integerValue] <= 0) {
            self.isLastPage = YES;
        }
        else {
            self.isLastPage = NO;
        }
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (isValidArray(arr)) {
                [self showNoData:NO];
                [dataSource addObjectsFromArray:arr];
                [tbView reloadData];
            }
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
        
        if (!isValidArray(dataSource)) {
            [self showNoData:YES];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        if (!isValidArray(dataSource)) {
            [self showNoData:YES];
        }
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (void)getHealthyRecords {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(currentPage2),@"page",
                                   [[UserSessionCenter shareSession] getUserId],@"user_id",nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getUserHealthActiveList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        if ([[jsonResponse objectForKey:@"remain_page"] integerValue] <= 0) {
            self.isLastPage = YES;
        }
        else {
            self.isLastPage = NO;
        }
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (isValidArray(arr)) {
                [self showNoData:NO];
                [dataSource2 addObjectsFromArray:arr];
                [tbView reloadData];
            }
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
        
        if (!isValidArray(dataSource2)) {
            [self showNoData:YES];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        if (!isValidArray(dataSource2)) {
            [self showNoData:YES];
        }
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (void)showNoData:(bool)showOn {
    labelNoData.hidden = !showOn;
    tbView.hidden = showOn;
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return btn1.selected ? dataSource.count : dataSource2.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reusedIdentify = @"MedicalReportCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    //init cell
    NSArray *arr = btn1.selected ? dataSource : dataSource2;
    if (indexPath.row < arr.count) {
        if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
            [cell performSelector:@selector(setCellDataInfo:) withObject:[arr objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //解决蛋疼的边线问题
    if (indexPath.row == (btn1.selected ? dataSource.count-1 : dataSource2.count-1)) {
        return 59.f;
    }
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select at row:%d",indexPath.row);
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    MedicalReportDetailViewController *mDetailVc = [[MedicalReportDetailViewController alloc] init];
    mDetailVc.isReport = btn1.selected ? YES : NO;
    mDetailVc.detailInfo = btn1.selected ? [dataSource objectAtIndex:indexPath.row] : [dataSource2 objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:mDetailVc animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        indexPathToDelete = indexPath;
        [self showAlertWithTitle:nil message:@"确定要删除该记录？" cancelButton:@"删除" sureButton:@"取消"];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        NSString *action = @"";
        
        if (btn1.selected) {
            action = @"deleteMedicalRecordById.action";
            NSDictionary *dic = [dataSource objectAtIndex:indexPathToDelete.row];
            [params setObject:[dic objectForKey:@"medical_record_id"] forKey:@"medical_record_id"];
        }
        else {
            action = @"deleteUserHealthActiveById.action";
            NSDictionary *dic = [dataSource2 objectAtIndex:indexPathToDelete.row];
            [params setObject:[dic objectForKey:@"health_active_id"] forKey:@"health_active_id"];
        }
        [SVProgressHUD showWithStatus:@"正在删除..."];
        [[AppsNetWorkEngine shareEngine] submitRequest:action param:params onCompletion:^(id jsonResponse) {
            [SVProgressHUD dismiss];
            if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                [self performSelector:@selector(refreshData) withObject:nil afterDelay:0.5];
            }
            else {
                [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
            }
            [self refreshData];
        } onError:^(NSError *error) {
            [SVProgressHUD dismiss];
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
        
    }
}

@end
