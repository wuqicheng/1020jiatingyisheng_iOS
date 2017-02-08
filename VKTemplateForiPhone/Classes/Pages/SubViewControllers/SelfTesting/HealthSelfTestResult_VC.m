//
//  HealthSelfTestResult_VC.m
//  jiankangshouhuzhuanjia
//
//  Created by ADUU on 15/12/2.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import "HealthSelfTestResult_VC.h"
#import "HealthTestSession.h"
#import "UserSessionCenter.h"
#import "JSONKit.h"
#import "HealthSelfTest_VC.h"
#import "Masonry.h"
#import "ShareManager.h"

#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"

#import "ShareMenuItemCollectionViewCell.h"
#import "UIImageView+WebCache.h"

#define SnsConfig [NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone,nil]
#define Share_Words @"下载“1020家庭医生，大病风险早知道。"
#define Share_Image [UIImage imageNamed:@"icon.png"]
//#define Share_LinkURL @"http://www.baidu.com"//分享链接

@interface HealthSelfTestResult_VC () <UIWebViewDelegate,UIScrollViewDelegate>{
    BOOL isLoadingFinished;
//    UMSocialData *socialData;
    NSString *URLString;
}
@property (nonatomic, strong) NSDictionary *dic;
@property (nonatomic, strong) NSMutableDictionary *labelDic;
@property (nonatomic, strong) NSMutableDictionary *webViewDic;
@property (nonatomic, strong) NSArray *keyArr;
@property (nonatomic, strong) UIView *preloadView;   //预加载时，遮盖内容

@property (strong, nonatomic)  UIButton *retestBtn;

- (void)retestBtnClick:(UIButton *)sender;
@end

@implementation HealthSelfTestResult_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customBackButton];
    self.title = [HealthTestSession shareInstance].project_title;
    [self initNavItem];
    [self requestResultData];
    
    _preloadView = [[UIView alloc] initWithFrame:self.view.bounds];
    _preloadView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_preloadView];
}


-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSLog(@"123456789");
    CGPoint point = scrollView.contentOffset;
    if (point.x>0) {
        scrollView.contentOffset = CGPointMake(0, point.y);
    }
}

- (void)initRetestBtn {
    BOOL isExist = NO;
    for(UIView *view in self.scroll.subviews) {
        if (view == self.retestBtn) {
            isExist = YES;
        }
    }
    if (isExist == NO) {
        UIImageView *bgimg = [UIImageView new];
        [bgimg setImageWithURL:[NSURL URLWithString:[HealthTestSession shareInstance].bgimage] placeholderImage:[UIImage imageNamed:@"加载失败.png"]];
//        bgimg.frame = CGRectMake(0, 0, Screen_Width, 212);
//        [self.scroll addSubview:bgimg];
        self.retestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [self.retestBtn setTitle:@"重测一次" forState:UIControlStateNormal];
        //        [_retestBtn addTarget:self action:@selector(manBtn:) forControlEvents:UIControlEventTouchUpInside];
        //        [self.retestBtn setBackgroundImage:[UIImage imageNamed:@"icon-体质自测-start.png"] forState:UIControlStateNormal];
//        self.retestBtn.frame = CGRectMake(0, 212, Screen_Width, 202);
        self.retestBtn.frame = CGRectMake(0, 0, Screen_Width, 202);
        [self.scroll addSubview:self.retestBtn];
        
    }
}

-(void)gotoShare:(UIButton *)button {
    
    NSString *snsName = SnsConfig[button.tag-1];
    NSString *shareTitle = @"1020家庭医生";
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:SHARE_WECHAT_APPID appSecret:SHARE_WECHAT_SECRECT url:URLString];
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:SHARE_QQ_APPID appKey:SHARE_QQ_KEY url:URLString];
    
    //    [[UMSocialControllerService defaultControllerService] setShareText:Share_Words shareImage:[UIImage imageNamed:@"icon_ios7.png"] socialUIDelegate:self];
    
    UMSocialData *socialData = [[UMSocialData alloc] initWithIdentifier:@"iosShare"];
    socialData.title = shareTitle;
    socialData.shareText = Share_Words;
    socialData.shareImage = Share_Image;
    //    socialData.commentText = @"comment text";
    
    switch (button.tag) {
        case 1://微信好友
            socialData.extConfig.wechatSessionData.title = [NSString stringWithFormat:@"%@的健康测试",self.title];
            socialData.extConfig.wechatSessionData.url = URLString;
            break;
        case 2://微信朋友圈
            socialData.extConfig.wechatTimelineData.title = [NSString stringWithFormat:@"%@的健康测试",self.title];
            socialData.extConfig.wechatTimelineData.url = URLString;
            break;
        case 3://新浪微博
            socialData.urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:URLString];
            break;
        case 4://qq
            socialData.extConfig.qqData.title = [NSString stringWithFormat:@"%@的健康测试",self.title];
            socialData.extConfig.qqData.url = URLString;
            socialData.extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
            break;
        case 5://qq空间
            socialData.extConfig.qzoneData.title = [NSString stringWithFormat:@"%@的健康测试",self.title];
            socialData.extConfig.qzoneData.url = URLString;
            break;
        default:
            break;
    }
    [[UMSocialControllerService defaultControllerService] setSocialData:socialData];
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName];
    snsPlatform.snsClickHandler(parrentVc,[UMSocialControllerService defaultControllerService],YES);
    
//    
//    if (button.tag == 1) {
//        //使用UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite分别代表微信好友、微信朋友圈、微信收藏
//        //               [UMSocialData defaultData].extConfig.wechatSessionData.url = Social_Share_Link;
//        
//        [UMSocialData defaultData].extConfig.wechatTimelineData.url = Share_LinkURL;
//        //    //纯文字分享类型没有图片，点击不会跳转
//        //    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeText;
//        
//        //纯图片分享类型没有文字，点击图片可以查看大图
//        //    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
//        
//        //    //标题
//        [UMSocialData defaultData].extConfig.wechatSessionData.title = [NSString stringWithFormat:@"%@的健康测试",self.title];
//        
//        //应用分享类型如果用户已经安装应用，则打开APP，如果为安装APP，则提示未安装或跳转至微信开放平台
//        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
//        
//        //UMShareToWechatSession 微信 UMShareToWechatTimeline朋友圈
//        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:@"下载“1020家庭医生”APP，大病风险早知道" image:Share_Image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
//            if (response.responseCode == UMSResponseCodeSuccess) {
//                NSLog(@"分享成功！");
//            }
//        }];
//        
//        
//    }else if (button.tag == 2) {
//        //使用UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite分别代表微信好友、微信朋友圈、微信收藏
//        [UMSocialData defaultData].extConfig.wechatSessionData.url = Share_LinkURL;
//        
//        //    [UMSocialData defaultData].extConfig.wechatTimelineData.url = Social_Share_Link;
//        //    //纯文字分享类型没有图片，点击不会跳转
//        //    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeText;
//        
//        //纯图片分享类型没有文字，点击图片可以查看大图
//        //    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
//        
//        //    //标题
//        [UMSocialData defaultData].extConfig.wechatTimelineData.title = [NSString stringWithFormat:@"%@的健康测试",self.title];
//        
//        //应用分享类型如果用户已经安装应用，则打开APP，如果为安装APP，则提示未安装或跳转至微信开放平台
//        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
//        
//        //UMShareToWechatSession 微信 UMShareToWechatTimeline朋友圈
//        
//        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:@"下载“1020家庭医生”APP，大病风险早知道" image:Share_Image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
//            if (response.responseCode == UMSResponseCodeSuccess) {
//                NSLog(@"分享成功！");
//            }
//        }];
//        
//    }else if (button.tag == 3) {
//        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToSina] content:@"下载“1020家庭医生”APP，大病风险早知道" image:
//         Share_Image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *shareResponse){
//             if (shareResponse.responseCode == UMSResponseCodeSuccess) {
//                 NSLog(@"分享成功！");
//             }
//         }];
//        
//        
//    }else if (button.tag == 4) {
//        //标题
//        [UMSocialData defaultData].extConfig.qqData.title = [NSString stringWithFormat:@"%@的健康测试",self.title];
//        //点击跳转
//        [UMSocialData defaultData].extConfig.qqData.url = Share_LinkURL;
//        
//        //发送到为qq消息类型
//        [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
//        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:@"下载“1020家庭医生”APP，大病风险早知道" image:Share_Image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
//            if (response.responseCode == UMSResponseCodeSuccess) {
//                NSLog(@"分享成功！");
//            }
//        }];
//        
//        
//    }else{
//        //标题
//        [UMSocialData defaultData].extConfig.qzoneData.title = [NSString stringWithFormat:@"%@的健康测试",self.title];
//        
//        //点击跳转
//        [UMSocialData defaultData].extConfig.qzoneData.url = Share_LinkURL;
//        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQzone] content:@"下载“1020家庭医生”APP，大病风险早知道" image:Share_Image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
//            if (response.responseCode == UMSResponseCodeSuccess) {
//                NSLog(@"分享成功！");
//            }
//        }];
//        
//        
//    }
}

- (void)presentShareViewIn:(UIViewController*)mainVc withContent:(NSString*)sContent image:(UIImage*)sImage shareUrl:(NSString*)shareUrl {
    if (!sImage) {
        sImage = Share_Image;
    }
    
    //[UMSocialConfig hiddenNotInstallPlatforms:SnsConfig];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:SHARE_WECHAT_APPID appSecret:SHARE_WECHAT_SECRECT url:shareUrl];
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:SHARE_QQ_APPID appKey:SHARE_QQ_KEY url:shareUrl];
    
    [UMSocialSnsService presentSnsIconSheetView:mainVc
                                         appKey:UMSHARE_KEY
                                      shareText:sContent
                                     shareImage:sImage
                                shareToSnsNames:SnsConfig
                                       delegate:nil];
}

- (void)presentShareAppDownloadLinkViewIn:(UIViewController*)mainVc {
    [self presentShareViewIn:mainVc withContent:Share_Words image:nil shareUrl:URLString];
}


#pragma mark - 结果回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        //        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"分享到%@成功!",[[response.data allKeys] objectAtIndex:0]]];
    }
    else if (response.responseCode == UMSResponseCodeBaned) {
        [SVProgressHUD showErrorWithStatus:@"分享失败，您的账户已被封禁！"];
    }
    else if (response.responseCode == UMSResponseCodeShareRepeated) {
        [SVProgressHUD showErrorWithStatus:@"分享失败：发送内容为空！"];
    }
    else if (response.responseCode == UMSResponseCodeGetNoUidFromOauth) {
        [SVProgressHUD showErrorWithStatus:@"分享失败：分享内容重复！"];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"分享失败"];
    }
    
    NSLog(@"%d",response.responseCode);
}

- (UIWebView *)getWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 1)];
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    webView.scrollView.bounces = NO;
    
    
    isLoadingFinished = NO;
    
    //这里一定要设置为NO
    [webView setScalesPageToFit:NO];
    
    //    [webView loadHTMLString:currentMail.htmlBody baseURL:nil];
    
    //第一次加载先隐藏webview
    [webView setHidden:YES];
    
    webView.delegate = self;
    
    [self.scroll addSubview:webView];
    return webView;
}

- (UILabel *)getLabel {
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(8, 1, Screen_Width, 35)];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor grayColor];
    [self.scroll addSubview:label];
    return label;
}

- (void)refreshView {
    UIView *topView = nil;
//    CGFloat topY = 212;
     CGFloat topY = 0;
    CGRect rect;
    for (NSInteger i = 0; i<self.keyArr.count ; i++) {
        NSString *key = self.keyArr[i];
        UILabel *label = self.labelDic[key];
        UIWebView *webView = self.webViewDic[key];
        if (label) {
            if (topView) {
                topY = CGRectGetMaxY(topView.frame);
            }
            
            rect = label.frame;
            rect.origin.y = topY;
            label.frame = rect;
            
            rect = webView.frame;
            rect.origin.y = CGRectGetMaxY(label.frame);
            webView.frame = rect;
            
            topView = webView;
        }
    }
    
    rect = self.retestBtn.frame;
    rect.origin.y = CGRectGetMaxY(topView.frame) + 30;
    self.retestBtn.frame = rect;
    
    self.scroll.contentSize = CGSizeMake(Screen_Width, CGRectGetMaxY(self.retestBtn.frame)+132-42-100);
}

#pragma mark - Nav
- (void)initNavItem {
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, 0, 26, 26);
    closeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [closeBtn setImage:[UIImage imageNamed:@"title_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(rightBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeItem= [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.rightBarButtonItem = closeItem;
}

#pragma mark - RequestData
- (void)requestResultData {
    __weakSelf_(weakSelf);
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try {
        [params setObject:[[HealthTestSession shareInstance].selected JSONString] forKey:@"desc_result"];
    }
    @catch (NSException *exception) {
        
    }
    
    [params setObject:[HealthTestSession shareInstance].project_id forKey:@"project_id"];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    
    NSLog(@"111111%@",params);
    URLString = [NSString stringWithFormat:@"http://%@Backend/share/fenxiang.html?title=%@&user_id=%@&project_id=%@&desc_result=%@",SERVER_DATA,[NSString stringWithFormat:@"%@的健康测试",self.title],[[UserSessionCenter shareSession] getUserId],[HealthTestSession shareInstance].project_id,[[HealthTestSession shareInstance].selected JSONString]];
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"saveOrUpdateExamResultInfos.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [_preloadView removeFromSuperview];
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if(isValidArray(arr)) {
                weakSelf.dic = arr[0];
                
                [weakSelf initRetestBtn];
                if(isValidString(self.dic[@"next_option_id"]) && isValidString(self.dic[@"next_question_id"]) && ![self.dic[@"next_option_id"] isEqualToString:@"0"] && ![self.dic[@"next_question_id"] isEqualToString:@"0"]) {
                    [self.retestBtn setTitle:[NSString stringWithFormat:@"下一个%@", weakSelf.title] forState:UIControlStateNormal];
                    [self.retestBtn setBackgroundImage:[UIImage imageNamed:@"icon-体质自测-start.png"] forState:UIControlStateNormal];
                    [self.retestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [self.retestBtn addTarget:self action:@selector(gotoNext) forControlEvents:UIControlEventTouchUpInside];
                    self.retestBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                    self.retestBtn.frame = CGRectMake((Screen_Width - 182)/2, 0, 182, 44);
                    [self.scroll addSubview:self.retestBtn];
                    
                }else{
                    UIButton *weibo = [UIButton new];
                    weibo.tag = 3;
                    [weibo setImage:[UIImage imageNamed:@"eb"] forState:UIControlStateNormal];
                    [weibo addTarget:self action:@selector(gotoShare:) forControlEvents:UIControlEventTouchUpInside];
                    [self.retestBtn addSubview:weibo];
                    [weibo mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(self.view);
                        make.top.mas_equalTo(90);
                    }];
                    //        UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoShare:)];
                    //        tapGestureRecognizer3.cancelsTouchesInView = NO;
                    //        [weibo addGestureRecognizer:tapGestureRecognizer3];
                    
                    UIButton *QQ = [UIButton new];
                    QQ.tag = 4;
                    [QQ setImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
                    [QQ addTarget:self action:@selector(gotoShare:) forControlEvents:UIControlEventTouchUpInside];
                    [self.retestBtn addSubview:QQ];
                    [QQ mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(weibo.mas_centerX).offset(Screen_Width/5);
                        make.top.mas_equalTo(weibo);
                    }];
                    //        UITapGestureRecognizer *tapGestureRecognizer4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoShare:)];
                    //        tapGestureRecognizer4.cancelsTouchesInView = NO;
                    //        [QQ addGestureRecognizer:tapGestureRecognizer4];
                    
                    UIButton *QZone = [UIButton new];
                    QZone.tag = 5;
                    [QZone setImage:[UIImage imageNamed:@"qqkj"] forState:UIControlStateNormal];
                    [QZone addTarget:self action:@selector(gotoShare:) forControlEvents:UIControlEventTouchUpInside];
                    [self.retestBtn addSubview:QZone];
                    [QZone mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(QQ.mas_centerX).offset(Screen_Width/5);
                        make.top.mas_equalTo(weibo);
                    }];
                    //        UITapGestureRecognizer *tapGestureRecognizer5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoShare:)];
                    //        tapGestureRecognizer5.cancelsTouchesInView = NO;
                    //        [QZone addGestureRecognizer:tapGestureRecognizer5];
                    
                    
                    UIButton *pyq = [UIButton new];
                    pyq.tag = 2;
                    [pyq setImage:[UIImage imageNamed:@"pyq"] forState:UIControlStateNormal];
                    [pyq addTarget:self action:@selector(gotoShare:) forControlEvents:UIControlEventTouchUpInside];
                    [self.retestBtn addSubview:pyq];
                    [pyq mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(weibo.mas_centerX).offset(-Screen_Width/5);
                        make.top.mas_equalTo(weibo);
                    }];
                    //        UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoShare:)];
                    //        tapGestureRecognizer2.cancelsTouchesInView = NO;
                    //        [pyq addGestureRecognizer:tapGestureRecognizer2];
                    
                    
                    UIButton *weixin = [UIButton new];
                    weixin.tag = 1;
                    [weixin setImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
                    [weixin addTarget:self action:@selector(gotoShare:) forControlEvents:UIControlEventTouchUpInside];
                    [self.retestBtn addSubview:weixin];
                    [weixin mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(pyq.mas_centerX).offset(-Screen_Width/5);
                        make.top.mas_equalTo(weibo);
                    }];
                    //        UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoShare:)];
                    //        tapGestureRecognizer1.cancelsTouchesInView = NO;
                    //        [weixin addGestureRecognizer:tapGestureRecognizer1];
                    
                    
                    UILabel *wxLabel = [UILabel new];
                    wxLabel.text = @"微信";
                    wxLabel.font = [UIFont systemFontOfSize:12];
                    wxLabel.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0f];
                    [self.retestBtn addSubview:wxLabel];
                    [wxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(weixin);
                        make.top.mas_equalTo(weixin.mas_bottom).offset(10);
                    }];
                    
                    UILabel *pyqLabel = [UILabel new];
                    pyqLabel.text = @"朋友圈";
                    pyqLabel.font = [UIFont systemFontOfSize:12];
                    pyqLabel.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0f];
                    [self.retestBtn addSubview:pyqLabel];
                    [pyqLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(pyq);
                        make.top.mas_equalTo(pyq.mas_bottom).offset(10);
                    }];
                    
                    UILabel *wbLabel = [UILabel new];
                    wbLabel.text = @"微博";
                    wbLabel.font = [UIFont systemFontOfSize:12];
                    wbLabel.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0f];
                    [self.retestBtn addSubview:wbLabel];
                    [wbLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(weibo);
                        make.top.mas_equalTo(weibo.mas_bottom).offset(10);
                    }];
                    
                    UILabel *QQLabel = [UILabel new];
                    QQLabel.text = @"QQ";
                    QQLabel.font = [UIFont systemFontOfSize:12];
                    QQLabel.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0f];
                    [self.retestBtn addSubview:QQLabel];
                    [QQLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(QQ);
                        make.top.mas_equalTo(QQ.mas_bottom).offset(10);
                    }];
                    
                    UILabel *QQZoneLabel = [UILabel new];
                    QQZoneLabel.text = @"QQ空间";
                    QQZoneLabel.font = [UIFont systemFontOfSize:12];
                    QQZoneLabel.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0f];
                    [self.retestBtn addSubview:QQZoneLabel];
                    [QQZoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(QZone);
                        make.top.mas_equalTo(QZone.mas_bottom).offset(10);
                    }];
                    
                    UILabel *shareLabel = [UILabel new];
                    shareLabel.text = @"分享到";
                    shareLabel.font = [UIFont systemFontOfSize:13];
                    shareLabel.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0f];
                    [self.retestBtn addSubview:shareLabel];
                    [shareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(weibo);
                        make.bottom.mas_equalTo(weibo.mas_top).offset(-20);
                    }];
                    
                    //重测一次按钮
                    UIButton *retest = [UIButton buttonWithType:UIButtonTypeCustom];
                    [retest setTitle:@"重测一次" forState:UIControlStateNormal];
                    [retest addTarget:self action:@selector(manBtn) forControlEvents:UIControlEventTouchUpInside];
                    [retest setBackgroundImage:[UIImage imageNamed:@"icon-体质自测-start.png"] forState:UIControlStateNormal];
                    [self.retestBtn addSubview:retest];
                    [retest mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(0);
                        make.centerX.mas_equalTo(self.retestBtn);
                        make.height.mas_equalTo(40);
                        make.width.mas_equalTo(160);
                    }];
                    
                    UIView *line1 = [UIView new];
                    line1.backgroundColor = [UIColor colorWithRed:207.0/255.0 green:207.0/255.0 blue:207.0/255.0 alpha:1.0f];
                    [self.retestBtn addSubview:line1];
                    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(weixin);
                        make.centerY.mas_equalTo(shareLabel);
                        make.height.mas_equalTo(1);
                        make.width.mas_equalTo(120);
                    }];
                    
                    UIView *line2 = [UIView new];
                    line2.backgroundColor = [UIColor colorWithRed:207.0/255.0 green:207.0/255.0 blue:207.0/255.0 alpha:1.0f];
                    [self.retestBtn addSubview:line2];
                    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.right.mas_equalTo(QZone);
                        make.centerY.mas_equalTo(line1);
                        make.height.mas_equalTo(line1);
                        make.width.mas_equalTo(line1);
                    }];
                }
                
                //************************以下部分是建立视图***********************
                weakSelf.webViewDic = [NSMutableDictionary dictionary];
                weakSelf.labelDic = [NSMutableDictionary dictionary];
                
                weakSelf.keyArr = @[@"结果",@"分析",@"建议"];
                NSArray *htmlKeyArr = @[@"desc1", @"desc2", @"desc3"];
                NSArray *labelTextArr = @[@"结果：", @"分析：", @"建议："];
                for (NSInteger i = 0; i<weakSelf.keyArr.count ; i++) {
                    NSString *html = weakSelf.dic[htmlKeyArr[i]];
                    BOOL htmlIsValid = isValidString(html);
                    if (htmlIsValid) {
                        UILabel *label = [weakSelf getLabel];
                        label.text = labelTextArr[i];
                        [weakSelf.labelDic setObject:label forKey:weakSelf.keyArr[i]];
                        
                        UIWebView *webView = [weakSelf getWebView];
                        [webView loadHTMLString:OptimizeHtmlString(html) baseURL:nil];
                        [weakSelf.webViewDic setObject:webView forKey:weakSelf.keyArr[i]];
                    }
                }
                
            }
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

- (void)manBtn {
    [[HealthTestSession shareInstance] clear];
    NSLog(@"%@,%@,%@,%@889999888&&&&",_dicdicdic[@"project_id"],_dicdicdic[@"project_title"],_dicdicdic[@"next_question_id"],self.dicdicdic);
    
    [HealthTestSession shareInstance].project_id = self.dicdicdic[@"project_id"];
    [HealthTestSession shareInstance].project_title = self.dicdicdic[@"project_title"];
    [HealthTestSession shareInstance].next_quest_id = self.dicdicdic[@"next_question_id"];
    [HealthTestSession shareInstance].bgimage = self.dicdicdic[@"project_pic"];
    HealthSelfTest_VC *vc = [[HealthSelfTest_VC alloc] init];
    vc.dicdic = self.dicdicdic;
    vc.types = 1;
    [self.navigationController pushViewController:vc animated:YES];

    //    HealthSelfTest_VC *vc = [[HealthSelfTest_VC alloc] init];
    ////    ApplicationDelegate.types = 1;
    //    vc.dicdic = self.dicdicdic;
    //    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoNext {
    [[HealthTestSession shareInstance] clear];
    [HealthTestSession shareInstance].project_title = self.title;
    [HealthTestSession shareInstance].project_id = self.project_id;
    HealthSelfTest_VC *vc = [[HealthSelfTest_VC alloc] init];
    if ([[HealthTestSession shareInstance].nextQuestionIdArry[self.index] isEqualToString:[[HealthTestSession shareInstance].nextQuestionIdArry lastObject]]) {
        [HealthTestSession shareInstance].next_quest_id = [HealthTestSession shareInstance].nextQuestionIdArry[0];
    }else{
        [HealthTestSession shareInstance].next_quest_id = self.dicdicdic[@"next_question_id"];
        [HealthTestSession shareInstance].bgimage = self.dicdicdic[@"project_pic"];
        vc.dicdic = self.dicdicdic;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goBack {
    [[HealthTestSession shareInstance] rollBack];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonAction:(UIButton *)sender {
    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
}

- (void)retestBtnClick:(UIButton *)sender {
    if(isValidString(self.dic[@"next_option_id"]) && isValidString(self.dic[@"next_question_id"]) && ![self.dic[@"next_option_id"] isEqualToString:@"0"] && ![self.dic[@"next_question_id"] isEqualToString:@"0"]) {
        [HealthTestSession shareInstance].next_quest_id = self.dic[@"next_question_id"];
        [[HealthTestSession shareInstance].selected removeAllObjects];
        
        HealthSelfTest_VC *vc = (HealthSelfTest_VC *)self.navigationController.childViewControllers[3];
        vc.isAutoSkipToNext = YES;
        vc.optionId = self.dic[@"next_option_id"];
        [self.navigationController popToViewController:vc animated:NO];
        
    }else {
        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CGFloat height0 = webView.scrollView.contentSize.height;
    CGRect rect = webView.frame;
    rect.size.height = height0+5;
    webView.frame = rect;
    
    [self refreshView];
    
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
        [webView setHidden:NO];
        return;
    }
    
    //js获取body宽度
    NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth "];
    
    int widthOfBody = [bodyWidth intValue];
    
    //获取实际要显示的html
    NSString *html = [self htmlAdjustWithPageWidth:widthOfBody
                                              html:OptimizeHtmlString(self.dic[@"desc1"])
                                           webView:webView];
    //设置为已经加载完成
    isLoadingFinished = YES;
    //加载实际要现实的html
    [webView loadHTMLString:html baseURL:nil];
    
    NSString *meta1 = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=self.view.frame.size.width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=5.0, user-scalable=yes\""];
    [webView stringByEvaluatingJavaScriptFromString:meta1];
    
    //若已经加载完成，则显示webView并return
    if(isLoadingFinished)
    {
        [webView setHidden:NO];
        return;
    }
    
}
//获取宽度已经适配于webView的html。这里的原始html也可以通过js从webView里获取
- (NSString *)htmlAdjustWithPageWidth:(CGFloat )pageWidth
                                 html:(NSString *)html
                              webView:(UIWebView *)webView
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
