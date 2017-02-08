//
//  NotificationsListViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "NotificationsListViewController.h"
#import "NotificationDetailViewController.h"
#import "UserSessionCenter.h"
#import "SingleChatViewController.h"
#import "CacheManager.h"
#import "MessageManager.h"
#import "HeathyProjectViewController.h"
#import "AppDelegate.h"

@interface NotificationsListViewController () {
    NSInteger currentPage;
    NSDictionary *infoToBeHandled;
}

@end

@implementation NotificationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dataSource = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view from its nib.
    self.title = @"消息";
    [self customBackButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
//    [self.messagelist addEntriesFromDictionary:ApplicationDelegate.messageM];
    NSLog(@"%@12332rwefewfeferg3344",[ApplicationDelegate.messageM objectForKey:@"aps"]);

    [[CacheManager defaultManager] removePushMessageInfo];
    [[MessageManager defaultManager] removeNewChatMessage];
}


#pragma mark - Data
- (void)refreshData {
    currentPage = 1;
    
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
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getPushRecordListNotReadByUser.action" param:params onCompletion:^(id jsonResponse) {
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
            [dataSource addObjectsFromArray:[ApplicationDelegate.messageM objectForKey:@"aps"]];
            
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

- (void)addNewFamilyMember:(bool)isAgree {
    [SVProgressHUD showWithStatus:String_Submitting];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(isAgree),@"is_agree",[infoToBeHandled objectForKey:@"family_id"],@"family_id", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"replyUserApplyFamily.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            if (isAgree) {
                [SVProgressHUD showSuccessWithStatus:@"已添加"];
            }
            else {
                [SVProgressHUD showSuccessWithStatus:@"已拒绝"];
            }
            
            [self performSelector:@selector(refreshData) withObject:nil afterDelay:0.5f];
        }
        else {
            [self showAlertWithTitle:@"提示" message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
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
    
    NSString *reusedIdentify = @"NotificationsListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    //init cell
    if (indexPath.row < dataSource.count) {
        if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
            [cell performSelector:@selector(setCellDataInfo:) withObject:[dataSource objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    //系统消息、好友关系、聊天咨询
    NSDictionary *pInfo = [dataSource objectAtIndex:indexPath.row];
    NSInteger msgType = [[pInfo objectForKey:@"msg_src_type"] integerValue];
    if (msgType == 1) {
        //聊天
        SingleChatViewController *sVc = [[SingleChatViewController alloc] init];
        sVc.conversationId = [pInfo objectForKey:@"conversation_id"];
        [self.navigationController pushViewController:sVc animated:YES];
    }
    else if (msgType == 2) {
        //申请监护人
        infoToBeHandled = pInfo;
        [self showAlertWithTitle:@"提示" message:[pInfo objectForKey:@"push_title"] cancelButton:@"同意" sureButton:@"拒绝" tag:100];
    }
    else if (msgType == 3 || msgType == 4) {
        //系统消息
        NotificationDetailViewController *dVc = [[NotificationDetailViewController alloc] init];
        dVc.detailInfo = pInfo;
        [self.navigationController pushViewController:dVc animated:YES];
    }
    else if (msgType == 5) {
        //亲人登录申请
        [app_delegate() handleFamilyLoginRequest:pInfo];
    }
    else if (msgType == 6) {
        //亲人登录申请的回复
        [SVProgressHUD showWithStatus:String_Loading];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[pInfo objectForKey:@"message_id"],@"message_id", nil];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"getApplyLoginResultByUser.action" param:params onCompletion:^(id jsonResponse) {
            [SVProgressHUD dismiss];
            NSLog(@"%@",jsonResponse);
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (isValidArray(arr) && isValidDictionary([arr firstObject])) {
                NSDictionary *resultInfo = [arr firstObject];
                [self showAlertWithTitle:nil message:[resultInfo objectForKey:@"content"] cancelButton:@"我知道了" sureButton:nil];
            }
        } onError:^(NSError *error) {
            [SVProgressHUD dismiss];
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }
    else if (msgType == 7) {
        //监护人申请结果
        [SVProgressHUD showWithStatus:String_Loading];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[pInfo objectForKey:@"message_id"],@"message_id", nil];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"getApplyTobeFamilResult.action" param:params onCompletion:^(id jsonResponse) {
            [SVProgressHUD dismiss];
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"result"] cancelButton:@"我知道了" sureButton:nil];
        } onError:^(NSError *error) {
            [SVProgressHUD dismiss];
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }
    else if (msgType == 8) {
        //健康计划
        HeathyProjectViewController *hVc = [[HeathyProjectViewController alloc] init];
        [self.navigationController pushViewController:hVc animated:YES];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[pInfo objectForKey:@"message_id"],@"message_id", nil];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"getHealthPlanRefreshResult.action" param:params onCompletion:^(id jsonResponse) {
            NSLog(@"%@",jsonResponse);
        } onError:^(NSError *error) {
            
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
    }
    if (alertView.tag == 100) {
        //加监护人请求
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[infoToBeHandled objectForKey:@"message_id"],@"message_id", nil];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"getFamilyApplyMsgItem.action" param:params onCompletion:^(id jsonResponse) {
            if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
                infoToBeHandled = [[jsonResponse objectForKey:@"rows"] firstObject];
                [self addNewFamilyMember:!buttonIndex];
            }
            else {
                [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
            }
            
        } onError:^(NSError *error) {
            
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
        
    }
}

@end
