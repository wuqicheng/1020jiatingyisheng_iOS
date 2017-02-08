//
//  RelationShipViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "RelationShipViewController.h"
#import "NewRelationShipViewController.h"
#import "UserSessionCenter.h"
#import "JPUSHService.h"
#import "RelationShipCell.h"

@interface RelationShipViewController ()<RelationShipCellDelegate> {
    NSMutableArray *dataSource2;
    NSDictionary *accountToLogin;
    UIAlertView *countDownAlertView;
    NSInteger counter;
    NSDictionary *familyUserInfoToDelete;
}

@end

@implementation RelationShipViewController

- (void)viewDidLoad {
    self.disableLoadMore = YES;
    self.disableRefresh = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"管理亲人";
    [self customBackButton];
    [self customNavigationBarItemWithImageName:@"icon_add.png" isLeft:NO];
    
    dataSource2 = [[NSMutableArray alloc] init];
    [self getMonitorList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginRequestResult:) name:NotificationDidRecieveFamilyLoginAnswer object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationDidRecieveFamilyLoginAnswer object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    NewRelationShipViewController *nVc = [[NewRelationShipViewController alloc] init];
    [self.navigationController pushViewController:nVc animated:YES];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return dataSource.count;
    }
    return dataSource2.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reusedIdentify = @"RelationShipCell";
    RelationShipCell *cell = (RelationShipCell*)[tableView dequeueReusableCellWithIdentifier:reusedIdentify];
    if (!cell) {
        cell = (RelationShipCell*)[[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSArray *datas = indexPath.section > 0 ? dataSource2 : dataSource;
    //init cell
    if (indexPath.row < datas.count) {
        [cell setCellDataInfo:[datas objectAtIndex:indexPath.row]];
        cell.delegate = self;
        cell.indexPath = indexPath;
        if (indexPath.section == 0) {
            cell.btn.selected = YES;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return headerView1;
    }
    else {
        return headerView2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return headerView1.frame.size.height + (labelNoData1.hidden?0:40);
    }
    else {
        return headerView2.frame.size.height + (labelNoData2.hidden?0:50);
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    if (indexPath.section == 0) {
        return;
    }
    
    accountToLogin = [dataSource2 objectAtIndex:indexPath.row];
    [self showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"确定要登录%@的账号?",[accountToLogin objectForKey:@"user_nick"]] cancelButton:@"确定" sureButton:@"取消" tag:101];
}

#pragma mark - Data
///获取监护人列表
- (void)getMonitorList {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getMonitorUserFamilyList.action" param:params onCompletion:^(id jsonResponse) {
        dataSource = [NSMutableArray arrayWithArray:[jsonResponse objectForKey:@"rows"]];
        if (isValidArray(dataSource)) {
            labelNoData1.hidden = YES;
        }
        else {
            labelNoData1.hidden = NO;
        }
        [self getFamalyList];
    } onError:^(NSError *error) {
        [self stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
}

///获取亲人列表
- (void)getFamalyList {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getGenerUserFamilyList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        dataSource2 = [NSMutableArray arrayWithArray:[jsonResponse objectForKey:@"rows"]];
        if (isValidArray(dataSource2)) {
            labelNoData2.hidden = YES;
        }
        else {
            labelNoData2.hidden = NO;
        }
        
        [tbView reloadData];
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [tbView reloadData];
        [self stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
}

///请求登陆亲人号
- (void)requestForLogin {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id",[accountToLogin objectForKey:@"party_user_id"],@"party_user_id", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"applyLoginFamilyByUser.action" param:params onCompletion:^(id jsonResponse) {
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            countDownAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录请求已发送，请耐心等候对方的答复!30秒后，将自动登录!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
            countDownAlertView.tag = 102;
            [countDownAlertView show];
            counter = 30;
            [self performSelector:@selector(countDownProcess) withObject:nil afterDelay:1.f];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

///登录到亲人账号
- (void)loginToFamily {
    [SVProgressHUD showWithStatus:String_LoggingIn];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id",[accountToLogin objectForKey:@"party_user_id"],@"party_user_id",@2,@"plat_type", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"appCLoginToSystemAsFamily.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            accountToLogin = nil;
            [SVProgressHUD showSuccessWithStatus:@"登录成功!"];
            //刷新亲人列表
//            [self getMonitorList];
            //处理登陆信息
            [[UserSessionCenter shareSession] setIfIsTmpLogin:YES];
            [[UserSessionCenter shareSession] saveAccountDetailInfo:[jsonResponse objectForKey:@"resultInfos"]];
            app_delegate().sessionId = [jsonResponse objectForKey:@"sessionid"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Login_Success object:nil];
            
            //注册用户的JPush别名
            [JPUSHService setTags:nil alias:[[[UserSessionCenter shareSession] getAccountDetailInfo] objectForKey:@"user_code"] callbackSelector:@selector(setTagsAndAliasCallback) object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

///处理亲人登陆回复
- (void)handleLoginRequestResult:(NSNotification*)aNotification {
    //取消倒计时
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(countDownProcess) object:nil];
    
    NSDictionary *pInfo = [aNotification object];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[pInfo objectForKey:@"message_id"],@"message_id", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getApplyLoginResultByUser.action" param:params onCompletion:^(id jsonResponse) {
        NSArray *arr = [jsonResponse objectForKey:@"rows"];
        if (isValidArray(arr)) {
            NSDictionary *dic = [arr firstObject];
            if (isValidDictionary(dic)) {
                [countDownAlertView dismissWithClickedButtonIndex:0 animated:YES];
                if ([[dic objectForKey:@"result"] integerValue] == 1) {
                    //同意
                    [SVProgressHUD showSuccessWithStatus:[dic objectForKey:@"content"]];
                    [self performSelector:@selector(loginToFamily) withObject:nil afterDelay:1.f];
                }
                else {
                    //拒绝
                    [SVProgressHUD showErrorWithStatus:[dic objectForKey:@"content"]];
                }
            }
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (void)deleteFamilyMember {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id",[familyUserInfoToDelete objectForKey:@"family_id"],@"family_id", nil];
    [SVProgressHUD showWithStatus:String_Submitting];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"deleteUserFamilyById.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        familyUserInfoToDelete = nil;
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:@"已删除"];
            
            [self getMonitorList];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        familyUserInfoToDelete = nil;
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 102 && counter > 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(countDownProcess) object:nil];
        return;
    }
    if (buttonIndex == 0) {
        if (alertView.tag == 101) {
            [self requestForLogin];
        }
        else if (alertView.tag == 200) {
            [self deleteFamilyMember];
        }
    }
}

- (void)countDownProcess {
    if (counter <= 0) {
        [countDownAlertView dismissWithClickedButtonIndex:0 animated:YES];
        //30秒后自动登录
        [self loginToFamily];
    }
    else {
        counter--;
        countDownAlertView.message = [NSString stringWithFormat:@"登录请求已发送，请耐心等候对方的答复!%@秒后，将自动登录!",@(counter)];
        [self performSelector:@selector(countDownProcess) withObject:nil afterDelay:1.f];
    }
}

#pragma mark - 
- (void)relationShipCell:(RelationShipCell*)cell buttonDidClickAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section > 0) {
        familyUserInfoToDelete = [dataSource2 objectAtIndex:indexPath.row];
        [self showAlertWithTitle:@"提示" message:@"确定解除关系?" cancelButton:@"解除" sureButton:@"取消" tag:200];
    }
    else {
        familyUserInfoToDelete = [dataSource objectAtIndex:indexPath.row];
        [self showAlertWithTitle:@"提示" message:@"确定解除监护人?" cancelButton:@"解除" sureButton:@"取消" tag:200];
    }
    
}

@end
