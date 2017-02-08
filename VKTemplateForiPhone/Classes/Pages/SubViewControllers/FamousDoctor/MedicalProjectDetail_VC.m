//
//  MedicalProjectDetail_VC.m
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/10/24.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import "MedicalProjectDetail_VC.h"
#import "UserSessionCenter.h"
#import "PayModeSelect_View.h"
#import "SingleChatViewController.h"
#import "WXApi.h"
#import "HomePageViewController.h"
#import "VIPPageViewController.h"

@interface MedicalProjectDetail_VC ()<UIWebViewDelegate>{
    BOOL isLoadingFinished;
}

@property (nonatomic, strong) UIButton *oldClickBtn;
@property (nonatomic, strong) NSDictionary *dic;
@property (nonatomic, strong) NSString *tradeNo;
@property (nonatomic, assign) BOOL isPhone;
@end

@implementation MedicalProjectDetail_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customBackButton];
    [self requestMedicalProjectWithProjectId:self.project_id];
}

- (void)refreshData {
    [self initNavItem];
    
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    //html是否加载完成
    isLoadingFinished = NO;
    //这里一定要设置为NO
    [self.webView setScalesPageToFit:NO];
    //第一次加载先隐藏webview
    [self.webView setHidden:YES];
    [self.webView loadHTMLString:OptimizeHtmlString(self.dic[@"desc1"]) baseURL:nil];
    self.webView.delegate = self;

    
//    [self.webView loadHTMLString:OptimizeHtmlString(self.dic[@"desc1"]) baseURL:nil];
    self.homePageBtn.selected = YES;
    self.oldClickBtn = self.homePageBtn;
    self.workTimeLabel.text = [NSString stringWithFormat:@"专家咨询 （%@）",self.dic[@"work_time"]];
}

#pragma mark RequestData
- (void)requestMedicalProjectWithProjectId:(NSString *)projectId{
    __weakSelf_(weakSelf);
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:@[ projectId?projectId:@""] forKeys:@[@"project_id"]];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getMedicalProjectInforByAPP.action" param:params onCompletion:^(id jsonResponse) {
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
           
            if (isValidArray(arr)) {
                 weakSelf.dic = arr[0];
                [weakSelf refreshData];
            }else {
                [SVProgressHUD showErrorWithStatus:@"没有找到相关内容"];
            }
        }
 
    } onError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

#pragma mark - Nav

- (void)initNavItem {
    self.title = self.dic[@"project_title"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
    NSForegroundColorAttributeName:[UIColor whiteColor]}];
   
    UIButton *collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    collectBtn.frame = CGRectMake(10, 0, 30, 30);
    [collectBtn setImage:[UIImage imageNamed:@"title_un_collect"] forState:UIControlStateNormal];
    [collectBtn setImage:[UIImage imageNamed:@"title_collect"] forState:UIControlStateSelected];
    if (self.dic[@"collect_project_id"] && [self.dic[@"collect_project_id"] integerValue] > 0) {
        collectBtn.selected = YES;
    }
    [collectBtn addTarget:self action:@selector(collectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *collectItem= [[UIBarButtonItem alloc] initWithCustomView:collectBtn];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(-10, 4, 26, 26);
    [closeBtn setImage:[UIImage imageNamed:@"title_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeItem= [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
   
    self.navigationItem.rightBarButtonItems = @[closeItem, collectItem];
}
#pragma mark - Action
//导航栏左键响应函数
- (void)leftBarButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)closeBtnClick:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)collectBtnClick:(UIButton *)sender {
    if (!self.dic) {
        return;
    }
    if (![app_delegate() checkIfLogin]) {
        [app_delegate() presentLoginViewIn:self];
        return;
    }
    
    __weakSelf_(weakSelf);
    NSString *action = @"saveOrUpdateCollectProjectInfos.action";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:app_delegate().sessionId forKey:@"sessionid"];
    if (sender.selected) {
        //取消收藏
        action = @"deleteCollectProjectByProjectId.action";
        [params setObject:self.dic[@"project_id"] forKey:@"project_id"];
        if (isValidString([[UserSessionCenter shareSession] getUserId])) {
            [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"user_id"];
        }
        if (isValidString(ApplicationDelegate.sessionId)) {
            [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
        }
    }
    else {
        //加入收藏
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"user_id"];
        [params setObject:self.dic[@"project_id"] forKey:@"project_id"];
    }
    
    [SVProgressHUD showWithStatus:String_Submitting];
    [[AppsNetWorkEngine shareEngine] submitRequest:action param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:sender.selected?@"已取消收藏":@"已收藏"];
            sender.selected = !sender.selected;
            if (weakSelf.collectChangeBlock) {
                weakSelf.collectChangeBlock(sender.selected);
            }
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (IBAction)showBtnClick:(UIButton *)sender {
    _oldClickBtn.selected = NO;
    sender.selected = YES;
    _oldClickBtn = sender;
    
    NSString *str = [NSString stringWithFormat:@"desc%ld", (long)(sender.tag-99)];
    [self.webView loadHTMLString:self.dic[str] baseURL:nil];
}

- (IBAction)imgOrTextConsultBtnClik:(UIButton *)sender {
    if (!self.dic) {
        return;
    }
    //图文咨询
    if (![app_delegate() checkIfLogin]) {
        [app_delegate() presentLoginViewIn:self];
        return;
    }
    
    __weakSelf_(__self);
    [SVProgressHUD showWithStatus:@"查询中..."];
    //查询是否咨询中，是调到对话，否调到支付
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   [[UserSessionCenter shareSession] getUserId],@"cs_user_id",
                                   [self.dic objectForKey:@"doctor_user_id"],@"doctor_user_id",nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"checkUserDoctorCommentStatus.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        
        NSString *conversationId = getString([jsonResponse objectForKey:@"conversation_id"]);
        NSString *consultFee = getString([jsonResponse objectForKey:@"consume_fee"]);
        NSString *consultNo = getString([jsonResponse objectForKey:@"consume_no"]);
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 0) {
            //新会话
            __self.tradeNo = [jsonResponse objectForKey:@"consume_no"];
            NSString *tradePrice = [jsonResponse objectForKey:@"consume_fee"];
            if ([tradePrice floatValue] <= 0) {
                //免费
                [self jumpToConversationWithConversationId:conversationId];
            }
            else {
                [self showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"本次咨询需付咨询费（微信支付）:%@元",consultFee] cancelButton:String_Sure sureButton:String_Cancel tag:1000];
                __self.isPhone = NO; //判断是电话咨询还是图文咨询
            }
        }
        else if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            //老会话
             [self jumpToConversationWithConversationId:conversationId];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

//跳转图文咨询
- (void)jumpToConversationWithConversationId:(NSString *)str {
    SingleChatViewController *sVc = [[SingleChatViewController alloc] init];
    sVc.conversationId = str;
    [self.navigationController pushViewController:sVc animated:YES];
}

- (IBAction)phoneConsultBtnClick:(UIButton *)sender {
//    if (!self.dic) {
//        return;
//    }
//    //电话咨询
//    if (![app_delegate() checkIfLogin]) {
//        [app_delegate() presentLoginViewIn:self];
//        return;
//    }
//    if (self.dic[@"hotline"] && ![self.dic[@"hotline"] isEqualToString:@""]) {
//        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",self.dic[@"hotline"]];
//        UIWebView * callWebview = [[UIWebView alloc] init];
//        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//        [self.view addSubview:callWebview];
//    }
    
    VIPPageViewController *payVC = [VIPPageViewController new];
    [self.navigationController pushViewController:payVC animated:YES];
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (alertView.tag == 1000) {
            [self payWithWechat];
        }
    }
}

#pragma mark - Pay For Wechat
//微信支付
- (void)payWithWechat {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_tradeNo,@"consume_no", nil];
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

- (void)wechatPayResultRespond:(NSNotification*)aNotification {
    PayResp *resp = (PayResp*)aNotification.object;
    switch (resp.errCode) {
        case WXSuccess:
            NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
            [SVProgressHUD showSuccessWithStatus:@"支付成功!"];
            if (self.isPhone) {
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

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat cHeight = webView.scrollView.contentSize.height;
    //    setViewFrameSizeHeight(webView, cHeight);
    //    scView.contentSize = CGSizeMake(scView.frame.size.width, webView.frame.origin.y+cHeight);
    
    
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", webView.frame.size.width];
    
    [webView stringByEvaluatingJavaScriptFromString:meta];
    
    //给网页增加utf-8编码
    [webView stringByEvaluatingJavaScriptFromString:
     @"var tagHead =document.documentElement.firstChild;"
     "var tagMeta = document.createElement(\"meta\");"
     "tagMeta.setAttribute(\"http-equiv\", \"Content-Type\");"
     "tagMeta.setAttribute(\"content\", \"text/html; charset=utf-8\");"
     "var tagHeadAdd = tagHead.appendChild(tagMeta);"];
    
    //给网页增加css样式
    [webView stringByEvaluatingJavaScriptFromString:
     @"var tagHead =document.documentElement.firstChild;"
     "var tagStyle = document.createElement(\"style\");"
     "tagStyle.setAttribute(\"type\", \"text/css\");"
     "tagStyle.appendChild(document.createTextNode(\"BODY{padding: 0pt 0pt}\"));"
     "var tagHeadAdd = tagHead.appendChild(tagStyle);"];
    
    //拦截网页图片  并修改图片大小
    [webView stringByEvaluatingJavaScriptFromString:
     @"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function ResizeImages() { "
     "var myimg,oldwidth,oldheight;"
     "var maxwidth=305;" //缩放系数
     "for(i=0;i <document.images.length;i++){"
     "myimg = document.images[i];"
     //     "if(myimg.width > maxwidth){"
     "oldwidth = myimg.width;"
     "oldheight = myimg.height;"
     "myimg.width = maxwidth;"
     "myimg.height = oldheight * (maxwidth/oldwidth);"
     //     "}"
     "}"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];
    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
    
    
    //若已经加载完成，则显示webView并return
    if(isLoadingFinished)
    {
        [self.webView setHidden:NO];
        return;
    }
    
    //js获取body宽度
    NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth "];
    
    int widthOfBody = [bodyWidth intValue];
    //获取实际要显示的html
    NSString *html = [self htmlAdjustWithPageWidth:widthOfBody html:OptimizeHtmlString(self.dic[@"desc1"]) webView:webView];
    //设置为已经加载完成
    isLoadingFinished = YES;
    //加载实际要现实的html
    [self.webView loadHTMLString:html baseURL:nil];
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '300%'";
    [self.webView stringByEvaluatingJavaScriptFromString:str];
    //获取到webview的高度
    CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue]+20;
    self.webView.frame = CGRectMake(self.webView.frame.origin.x,self.webView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, 452);
    //    wView.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, height+64+74);
    [self.view addSubview:self.webView];
}

//获取宽度已经适配于webView的html。这里的原始html也可以通过js从webView里获取
- (NSString *)htmlAdjustWithPageWidth:(CGFloat )pageWidth html:(NSString *)html webView:(UIWebView *)webView
{
    NSMutableString *str = [NSMutableString stringWithString:html];
    //计算要缩放的比例
    CGFloat initialScale = webView.frame.size.width/pageWidth;
    //将</head>替换为meta+head
    NSString *stringForReplace = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\" initial-scale=%f, minimum-scale=0.1, maximum-scale=2.0, user-scalable=yes\"></head>",initialScale];
    
    NSRange range =  NSMakeRange(0, str.length);
    //替换
    [str replaceOccurrencesOfString:@"</head>" withString:stringForReplace options:NSLiteralSearch range:range];
    return str;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError===%@", error);
}

@end
