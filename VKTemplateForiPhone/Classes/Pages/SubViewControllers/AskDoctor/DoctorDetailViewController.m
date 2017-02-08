//
//  DoctorDetailViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/19.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DoctorDetailViewController.h"
#import "UIImageView+MJWebCache.h"
#import "UserSessionCenter.h"
#import "SingleChatViewController.h"
#import "DoctorCalanderViewController.h"
#import "WXApi.h"
#import "PhoneCallViewController.h"

@interface DoctorDetailViewController () {
    NSInteger currentPage;
    NSString *conversationId,*consultFee,*consultNo,*phoneCallId,*phoneNo,*phoneFee;
    bool isCollected,isPhone;
    
    NSString *tradeNo,*tradePrice;
}

@end

@implementation DoctorDetailViewController
@synthesize detailInfo;

- (void)viewDidLoad {
    self.disableRefresh = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"医生详情";
    [self customBackButton];
    [self initView];
    [self refreshData];
    
    //测试，默认选中微信支付
    btnWechat.selected = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechatPayResultRespond:) name:Notification_WechatPay_Result_Notification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notification_WechatPay_Result_Notification object:nil];
}


#pragma mark - Private
- (void)initView {
    //头像
    imgvAvatar.layer.cornerRadius = imgvAvatar.frame.size.width / 2.f;
    if (isValidString([detailInfo objectForKey:@"photo"])) {
        [imgvAvatar setImageURLStr:[detailInfo objectForKey:@"photo"] placeholder:Defualt_Avatar_Image];
    }
    //名称
    labelDoctorName.text = [detailInfo objectForKey:@"user_name"];
    phoneTitle.textColor = GetColorWithRGB(42, 217, 2);
    //费用
    labelCost.text = [NSString stringWithFormat:@"￥%@元/次",[detailInfo objectForKey:@"comment_fee"]];
    labelCallCost.text = [NSString stringWithFormat:@"￥%@元/次",[detailInfo objectForKey:@"phone_comment_fee"]];
    fitLabelHeight(labelCost, labelCost.text);
    fitLabelHeight(labelCallCost, labelCallCost.text);
    //在线状态
    if ([[detailInfo objectForKey:@"work_status"] integerValue] != 1) {
        btnIsOnline.hidden = YES;
    }
    if ([[detailInfo objectForKey:@"phone_line"] integerValue] != 1) {
        phoneStatus.hidden = YES;
    }
    
    //医生简介
    NSString *descString = [detailInfo objectForKey:@"doctor_desc"];
    if (isValidString(descString)) {
        labelDesc.text = [detailInfo objectForKey:@"doctor_desc"];
        fitLabelHeight(labelDesc, [detailInfo objectForKey:@"doctor_desc"]);
        setViewFrameSizeHeight(viewFace, labelDesc.frame.origin.y+labelDesc.frame.size.height+53.f);
    }
    
    
    //收藏按钮
    if ([[detailInfo objectForKey:@"collect_doctor_id"] integerValue] > 0) {
        //已收藏
        [self customNavigationBarItemWithImageName:@"icon_collected.png" isLeft:NO];
        isCollected = YES;
    }
    else {
        //未收藏
        [self customNavigationBarItemWithImageName:@"icon_uncollected.png" isLeft:NO];
        isCollected = NO;
    }
    
    [tbView reloadData];
    
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    if (![app_delegate() checkIfLogin]) {
        [app_delegate() presentLoginViewIn:self];
        return;
    }
    
    bool isCancel = NO;
    NSString *action = @"saveOrUpdateCollectDoctorInfos.action";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (isCollected) {
        //取消收藏
        isCancel = YES;
        action = @"deleteCollectDoctorById.action";
        [params setObject:[detailInfo objectForKey:@"collect_doctor_id"] forKey:@"collect_doctor_id"];
    }
    else {
        //加入收藏
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"user_id"];
        [params setObject:[detailInfo objectForKey:@"user_id"] forKey:@"doctor_user_id"];
    }
    
    [SVProgressHUD showWithStatus:String_Submitting];
    [[AppsNetWorkEngine shareEngine] submitRequest:action param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:isCancel?@"已取消收藏":@"已收藏"];
            [self customNavigationBarItemWithImageName:isCancel?@"icon_uncollected.png":@"icon_collected.png" isLeft:NO];
            isCollected = !isCancel;
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (void)jumpToConversation {
    SingleChatViewController *sVc = [[SingleChatViewController alloc] init];
    sVc.conversationId = conversationId;
    [self.navigationController pushViewController:sVc animated:YES];
}

-(void)jumpToPhoneCallConversation
{
     PhoneCallViewController *call = [[PhoneCallViewController alloc] init];
     call.phoneCallId = phoneCallId;
     call.phone = self.phone;
     [self.navigationController pushViewController:call animated:YES];
}

- (void)setPaymenViewHidden:(bool)isHidden {
    viewMask.hidden = isHidden;
    viewPayment.hidden = isHidden;
}

- (void)resetPaymentButtons {
    btnAliPay.selected = NO;
    btnUnion.selected = NO;
    btnWechat.selected = NO;
}

#pragma mark - Button Action
- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == 100) {
        //咨询
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
            return;
        }
        [SVProgressHUD showWithStatus:@"查询中..."];
        //查询是否咨询中，是调到对话，否调到支付
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [[UserSessionCenter shareSession] getUserId],@"cs_user_id",
                                       [detailInfo objectForKey:@"user_id"],@"doctor_user_id",nil];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"checkUserDoctorCommentStatus.action" param:params onCompletion:^(id jsonResponse) {
            [SVProgressHUD dismiss];
            
            conversationId = getString([jsonResponse objectForKey:@"conversation_id"]);
            consultFee = getString([jsonResponse objectForKey:@"consume_fee"]);
            consultNo = getString([jsonResponse objectForKey:@"consume_no"]);
            
            if ([[jsonResponse objectForKey:@"status"] integerValue] == 0) {
                //新会话
                tradeNo = [jsonResponse objectForKey:@"consume_no"];
                tradePrice = [jsonResponse objectForKey:@"consume_fee"];
                if ([tradePrice floatValue] <= 0) {
                    //免费
                    [self jumpToConversation];
                }
                else {
                    [self showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"本次咨询需付咨询费:%@元",consultFee] cancelButton:String_Sure sureButton:String_Cancel tag:1000];
                    isPhone =NO;
                }
            }
            else if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
                //老会话
                [self jumpToConversation];
            }
            else {
                [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
            }
        } onError:^(NSError *error) {
            [SVProgressHUD dismiss];
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
        
    }
    else if (sender.tag == 101) {
        //出诊时间
        DoctorCalanderViewController *dcVc = [[DoctorCalanderViewController alloc] init];
        dcVc.doctorInfo = detailInfo;
        [self.navigationController pushViewController:dcVc animated:YES];
        
    }
    else if (sender.tag == 102)
    {
        //电话咨询
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
            return;
        }
        [SVProgressHUD showWithStatus:@"查询中..."];
        //查询是否咨询中，是调到对话，否调到支付
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [[UserSessionCenter shareSession] getUserId],@"cs_user_id",
                                       [detailInfo objectForKey:@"user_id"],@"doctor_user_id",nil];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"checkUserDoctorPhoneCommentStatus.action" param:params onCompletion:^(id jsonResponse) {
            [SVProgressHUD dismiss];
            
            phoneCallId = getString([jsonResponse objectForKey:@"phone_conversation_id"]);
            phoneFee = getString([jsonResponse objectForKey:@"consume_fee"]);
            phoneNo = getString([jsonResponse objectForKey:@"consume_no"]);
            
            if ([[jsonResponse objectForKey:@"status"] integerValue] == 0) {
                //新会话
                tradeNo = [jsonResponse objectForKey:@"consume_no"];
                tradePrice = [jsonResponse objectForKey:@"consume_fee"];
                if ([tradePrice floatValue] <= 0) {
                    //免费
                    [self jumpToPhoneCallConversation];
                }
                else {
                    [self showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"本次电话咨询需付咨询费:%@元",phoneFee] cancelButton:String_Sure sureButton:String_Cancel tag:1000];
                    isPhone = YES;
                }
            }
            else if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
                //老会话
                [self jumpToPhoneCallConversation];
            }
            else {
                [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
            }
        } onError:^(NSError *error) {
            [SVProgressHUD dismiss];
        } defaultErrorAlert:YES isCacheNeeded:NO method:@"GET"];
    }
}

- (IBAction)paymentViewAction:(UIButton*)sender {
    if (sender.tag == 200) {
        //确定
        [self setPaymenViewHidden:YES];
        [self doPayment];
    }
    else if (sender.tag == 201) {
        //支付宝
        [self resetPaymentButtons];
        sender.selected = YES;
    }
    else if (sender.tag == 202) {
        //银联
        [self resetPaymentButtons];
        sender.selected = YES;
    }
    else if (sender.tag == 203) {
        //微信
        [self resetPaymentButtons];
        sender.selected = YES;
    }
    else if (sender.tag == 210) {
        //关闭
        [self setPaymenViewHidden:YES];
    }
}

#pragma mark - Data
//need to over write
- (void)refreshData {
    currentPage = 1;
    dataSource = [[NSMutableArray alloc] init];
    [self getCommentsList];
}

//need to over write
- (void)loadMoreData  {
    currentPage++;
    [self getCommentsList];
}

- (void)getCommentsList {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(currentPage),@"page",
                                   [detailInfo objectForKey:@"user_id"],@"doctor_user_id",nil];
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getDoctorCommentListByUser.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if (!isValidArray(dataSource)) {
            [self showNoData:YES];
        }
        
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
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (!isValidArray(dataSource)) {
            [self showNoData:YES];
        }
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (void)showNoData:(bool)showOn {
    labelNoData.hidden = !showOn;
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reusedIdentify = @"DoctorDetailCommentCell";
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
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return viewFace;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return viewFace.frame.size.height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    NSDictionary *dic = [dataSource objectAtIndex:indexPath.row];
    SingleChatViewController *sVc = [[SingleChatViewController alloc] init];
    sVc.conversationId = [dic objectForKey:@"conversation_id"];
    [self.navigationController pushViewController:sVc animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (alertView.tag == 1000) {
            [self setPaymenViewHidden:NO];
        }
    }
}

#pragma mark - Payment
- (void)doPayment {
    //立即购买
    if (btnAliPay.selected) {
        [self payWithAli];
    }
    else if (btnUnion.selected) {
        [self payWithUnion];
    }
    else if (btnWechat.selected) {
        [SVProgressHUD showWithStatus:String_Loading];
        [self payWithWechat];
    }
}

- (void)payWithAli {
    [SVProgressHUD showSuccessWithStatus:@"即将开通!"];
}

- (void)payWithUnion {
    [SVProgressHUD showSuccessWithStatus:@"即将开通!"];
}

- (void)wechatPayResultRespond:(NSNotification*)aNotification {
    PayResp *resp = (PayResp*)aNotification.object;
    switch (resp.errCode) {
        case WXSuccess:
            NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
            [SVProgressHUD showSuccessWithStatus:@"支付成功!"];
            if (isPhone) {
                [self performSelector:@selector(jumpToPhoneCallConversation) withObject:nil afterDelay:1.f];
            }
            else
            {
                [self performSelector:@selector(jumpToConversation) withObject:nil afterDelay:1.f];
            }
            
            break;
            
        default:
            
            break;
    }
}


#pragma mark - For Wechat
- (void)payWithWechat {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tradeNo,@"consume_no", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"buildWechatPaySerialNo.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if (isValidString([jsonResponse objectForKey:@"serial_no"])) {
            //获取PrePayId成功，跳过去支付
            NSString *timeStamp = [jsonResponse objectForKey:@"timestamp"];//[self genTimeStamp];//
            
            //构造支付请求
            PayReq *request = [[PayReq alloc]init];
            //服务器签名
            request.openID = [jsonResponse objectForKey:@"appid"];
            request.partnerId = [jsonResponse objectForKey:@"partnerid"];
            request.prepayId = [jsonResponse objectForKey:@"prepayid"];
            request.package = [jsonResponse objectForKey:@"package"];
            request.nonceStr = [jsonResponse objectForKey:@"noncestr"];
            request.timeStamp = (UInt32)[timeStamp longLongValue];
            request.sign = [jsonResponse objectForKey:@"sign"];
            
            [WXApi sendReq:request];
        }
        else {
            [self showAlertWithTitle:nil message:@"获取订单信息失败，请重试!" cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}


@end
