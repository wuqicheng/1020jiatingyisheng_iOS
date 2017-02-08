//
//  ChatBoxViewController.m
//  VKTemplateForiPhone
//
//  Created by NPHD on 15/7/27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "ChatBoxViewController.h"
#import "MessageManager.h"
#import "CacheManager.h"
#import "NotificationsListViewController.h"
#import "SingleChatViewController.h"
#import "UserSessionCenter.h"
#import "CallListCell.h"
#import "PhoneCallViewController.h"
#import "EvaluateDoctorViewController.h"

@interface ChatBoxViewController ()<CallListDelegate>{
    NSMutableArray *chatDataSource,*callDatasource;
    bool isChatMode;
    NSInteger chatPage,callPage;
}
@end

@implementation ChatBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isChatMode = YES;
    btn1.selected = YES;
    view1.hidden = NO;
    chatPage = 1;
    callPage = 1;
    [self customBackButton];
    self.title = @"咨询记录";
    //推送通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveNewChatMessage) name:NotificationDidRecieveNewChatMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveNewPushMessage) name:Notification_Did_Recieve_Remote_Notification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if (isValidDictionary([[MessageManager defaultManager] getNewChatMessage]) || isValidDictionary([[CacheManager defaultManager] getPushMessageInfo])) {
//        [self customNavigationBarItemWithImageName:@"icon_message_unread.png" isLeft:YES];
//    }
//    else {
//        [self customNavigationBarItemWithImageName:@"icon_message.png" isLeft:YES];
//    }
    
    [self refreshData];
//    [self checkPushTag];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
    
    //    [self performSelector:@selector(checkIfNeedToAutoJump) withObject:nil afterDelay:0.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationDidRecieveNewChatMessage object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notification_Did_Recieve_Remote_Notification object:nil];
}

//-(void)checkPushTag
//{
//    
//    NSDictionary *pushInfo = [[[UserSessionCenter shareSession ] getUserLoginTag] objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
//    if (isValidDictionary(pushInfo)) {
//        [app_delegate() handleRemoteNotificationFromBackground:pushInfo];
//    }
//    
//    [[UserSessionCenter shareSession] destroyLoginTag];
//}

#pragma mark - Private
//导航栏左键响应函数，重写此函数，响应点击事件；此函数与上面的goback区分
//- (void)leftBarButtonAction {
//    NotificationsListViewController *nlVc = [[NotificationsListViewController alloc] init];
//    [self.navigationController pushViewController:nlVc animated:YES];
//    
//}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    NSDictionary *cInfo = [[CacheManager defaultManager] getCompanyInfo];
    if (isValidDictionary(cInfo) && isValidString([cInfo objectForKey:@"phone"])) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[cInfo objectForKey:@"phone"]]]];
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",[cInfo objectForKey:@"phone"]];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"服务热线尚未开通"];
    }
}

#pragma mark -
- (void)didRecieveNewPushMessage {
    [self customNavigationBarItemWithImageName:@"icon_message_unread.png" isLeft:YES];
}

- (void)didRecieveNewChatMessage {
    chatPage = 1;
    chatDataSource = [[NSMutableArray alloc] init];
    
}

- (void)resetButtonStatus {
    btn1.selected = NO;
    btn2.selected = NO;
   
}
- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == 101) {
        
        if (sender.selected) {
            return;
        }
        isChatMode = YES;
        tbView.hidden = NO;
        labelNoData.hidden = YES;
        view1.hidden  = NO;
        view2.hidden = YES;
        [self resetButtonStatus];
        sender.selected = YES;
        
        if (isValidArray(chatDataSource)) {
            [tbView reloadData];
        }
        else {
            [self refreshData];
        }
    }
    else if (sender.tag == 102) {
        
        if (sender.selected) {
            return;
        }
        tbView.hidden = NO;
        labelNoData.hidden = YES;
        view2.hidden = NO;
        view1.hidden = YES;
        isChatMode = NO;
        [self resetButtonStatus];
        sender.selected = YES;
        
        if (isValidArray(callDatasource)) {
            [tbView reloadData];
        }
        else {
            [self refreshData];
        }
    }
}

#pragma mark - Load data
- (void)refreshData {
    if (isChatMode) {
        chatPage = 1;
        chatDataSource = [[NSMutableArray alloc] init];
        [self getData:YES];
    }
    else {
        callPage = 1;
        callDatasource = [[NSMutableArray alloc] init];
        [self loadData];
    }
    
}

- (void)loadMoreData  {
    if (isChatMode) {
        chatPage++;
        [chatDataSource removeAllObjects];
        [self getData:YES];
    }
    else {
        callPage++;
        [callDatasource removeAllObjects];
        [self loadData];
    }
    
}

- (void)getData:(bool)animated {
    if (animated) {
        [SVProgressHUD showWithStatus:String_Loading];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];//,@(currentPage),@"page"
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getCommentSessionListByAppUser.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        
            if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [chatDataSource addObjectsFromArray:[jsonResponse objectForKey:@"rows"]];
            [tbView reloadData];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
        
        if (!isValidArray(chatDataSource)) {
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
        if (!isValidArray(chatDataSource)) {
            //无数据？
            tbView.hidden = YES;
            labelNoData.hidden = NO;
        }
        else {//有数据
            tbView.hidden = NO;
            labelNoData.hidden = YES;
        }
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

-(void)loadData
{
    NSString *userId = [[UserSessionCenter shareSession] getUserId];
    NSString *sessionId = ApplicationDelegate.sessionId;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userId,@"user_id",sessionId,@"sessionid", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getPhoneCommnetSessionListByUser.action" param:params onCompletion:^(id jsonResponse)
     {
         [SVProgressHUD dismiss];
         [self stopRefreshing];
         if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
             [callDatasource addObjectsFromArray:[jsonResponse objectForKey:@"rows"]];
             [tbView reloadData];
         }
         else {
             [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
         }
         
         if (!isValidArray(callDatasource)) {
             //无数据？
             tbView.hidden = YES;
             labelNoData.hidden = NO;
         }
         else {//有数据
             tbView.hidden = NO;
             labelNoData.hidden = YES;
         }
     }onError:^(NSError *error){
         [SVProgressHUD dismiss];
         [self stopRefreshing];
         if (!isValidArray(callDatasource)) {
             //无数据？
             tbView.hidden = YES;
             labelNoData.hidden = NO;
         }
         else {//有数据
             tbView.hidden = NO;
             labelNoData.hidden = YES;
         }

         NSLog(@"3333333");
     }
    defaultErrorAlert:NO  isCacheNeeded:NO method:@"GET"];
//    [tbView reloadData];
}

- (void)checkIfNeedToShowNoDataView {
    if (isChatMode && chatPage <= 1) {
        [self showNoData:YES];
    }
    else if (!isChatMode && callPage <= 1) {
        [self showNoData:YES];
    }
}

- (void)showNoData:(bool)showOn {
    [super showNoData:showOn];
    tbView.hidden = showOn;
}


#pragma mark -
#pragma mark - CallListDelegate

-(void)setPhoneCallId:(NSString *)phoneId btnClickType:(btnClickType)clickTye
{
   //电话咨询
    if (clickTye == phoneCallBtnClick) {
        
//        PhoneCallViewController *call = [[PhoneCallViewController alloc] init];
//        call.phoneCallId = phoneId;
//         NSLog(@"%@",phoneId);
//        [self.navigationController pushViewController:call animated:YES];
        
        
//        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                                       phoneId,@"phone_conversation_id",app_delegate().sessionId,@"sessionid",nil];
//        [[AppsNetWorkEngine shareEngine] submitRequest:@"callPhoneByUser.action" param:params onCompletion:^(id jsonResponse) {
//            [SVProgressHUD dismiss];
//            
//            if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
//                
//                [self showAlertWithTitle:nil message:@"电话咨询请求成功，请耐心等待拨入电话！" cancelButton:String_Sure sureButton:nil];
//                
//            }
//            else {
//                [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
//            }
//        } onError:^(NSError *error) {
//            [SVProgressHUD dismiss];
//        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
        
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:0516-82181020"];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
    }
    //图文资讯
    else if(clickTye == chatBtnClick)
    {
        
         NSLog(@"%@",phoneId);
        SingleChatViewController *chat = [[SingleChatViewController alloc] init];
        chat.conversationId = phoneId;
        [self.navigationController pushViewController:chat animated:YES];
    }
    //评论
    else if (clickTye == commentBtnClick)
    {
        EvaluateDoctorViewController *evaluate = [[EvaluateDoctorViewController alloc] init];
        evaluate.phoneCallId = phoneId;
         NSLog(@"%@",phoneId);
        [self.navigationController pushViewController:evaluate animated:YES];
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return isChatMode ? chatDataSource.count : callDatasource.count;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //图文咨询
    if (isChatMode) {
        NSString *reusedIdentify = @"ChatListCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:reusedIdentify];
        
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        if (indexPath.row < chatDataSource.count) {
            if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
                [cell performSelector:@selector(setCellDataInfo:) withObject:[chatDataSource objectAtIndex:indexPath.row]];
            }
        }
        
        return cell;
    }
    //电话咨询
    else
    {
        NSString *reusedIdentify = @"CallListCell";
        CallListCell *cell = (CallListCell*)[tableView dequeueReusableCellWithIdentifier:reusedIdentify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        
        if (indexPath.row < callDatasource.count) {
            if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
                [cell performSelector:@selector(setCellDataInfo:) withObject:[callDatasource objectAtIndex:indexPath.row]];
            }
        }
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isChatMode) {
        return 70;
    }
    else {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select at row:%d",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isChatMode) {
        SingleChatViewController *sVc = [[SingleChatViewController alloc] init];
        
        sVc.conversationId = [[chatDataSource objectAtIndex:indexPath.row] objectForKey:@"conversation_id"];
        NSLog(@"%@~~~",sVc.conversationId);
        [self.navigationController pushViewController:sVc animated:YES];
    }
    
//    if (!isValidString([[callDatasource objectAtIndex:indexPath.row] objectForKey:@"doctor_cfg_time"])) {
//        SetTimeViewController *setTime = [[SetTimeViewController alloc] init];
//        setTime.phoneConversationId = [[callDatasource objectAtIndex:indexPath.row] objectForKey:@"phone_conversation_id"];
//        NSLog(@"%@",setTime.phoneConversationId);
//        [self.navigationController pushViewController:setTime animated:YES];
//    }
    
}

@end
