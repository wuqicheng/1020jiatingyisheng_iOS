//
//  UserHealthWarnResult_VC.m
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/12/2.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import "UserHealthWarnResult_VC.h"
#import "UserSessionCenter.h"
#import "HealthWarn_VC.h"
#import "HealthTestSession.h"
#import "HealthSelfTest_VC.h"
#import "HealthWarnVC.h"

@interface UserHealthWarnResult_VC ()<UIWebViewDelegate>{
     BOOL isLoadingFinished;
}
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) UIButton *collectBtn;
@property (nonatomic, strong) UIView *preloadView;   //预加载时，遮盖内容

@property (nonatomic, strong) NSMutableDictionary *labelDic;
@property (nonatomic, strong) NSMutableDictionary *webViewDic;
@property (nonatomic, strong) NSArray *keyArr;


@property (strong, nonatomic)  UIButton *retestBtn;
- (void)retestBtnClick:(UIButton *)sender;
@end

@implementation UserHealthWarnResult_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customBackButton];
    [self initNavItem];
    [self requestResultData];
    
    _preloadView = [[UIView alloc] initWithFrame:self.view.bounds];
    _preloadView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_preloadView];
}

- (void)initRetestBtn {
    BOOL isExist = NO;
    for(UIView *view in self.scroll.subviews) {
        if (view == self.retestBtn) {
            isExist = YES;
        }
    }
    if (isExist == NO) {
        self.retestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.retestBtn setTitle:@"重测一次" forState:UIControlStateNormal];
        [self.retestBtn setBackgroundImage:[UIImage imageNamed:@"icon-体质自测-start.png"] forState:UIControlStateNormal];
        [self.retestBtn addTarget:self action:@selector(reTest) forControlEvents:UIControlEventTouchUpInside];
        self.retestBtn.frame = CGRectMake((Screen_Width - 182)/2, 0, 182, 44);
        [self.scroll addSubview:self.retestBtn];
    }
}

- (UIWebView *)getWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 1)];
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    webView.scrollView.bounces = NO;
    
    isLoadingFinished = NO;
    //这里一定要设置为NO
    [webView setScalesPageToFit:NO];
    //第一次加载先隐藏webview
    [webView setHidden:YES];
    
    webView.delegate = self;
    [self.scroll addSubview:webView];
    return webView;
}

- (UILabel *)getLabel {
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(8, 0, Screen_Width, 35)];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor grayColor];
    [self.scroll addSubview:label];
    return label;
}

- (void)refreshView {
    UIView *topView = nil;
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
    
    self.scroll.contentSize = CGSizeMake(Screen_Width, CGRectGetMaxY(self.retestBtn.frame) + 30);
}

#pragma mark - Nav
- (void)initNavItem {
    NSString *title = @"";
    NSRange range = [self.dic[@"project_title"] rangeOfString:@" "];
    if (range.location != NSNotFound) {
        title = [self.dic[@"project_title"] substringToIndex:range.location];
    }
    self.title =  title;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _collectBtn.frame = CGRectMake(10, 0, 30, 30);
    [_collectBtn setImage:[UIImage imageNamed:@"title_un_collect"] forState:UIControlStateNormal];
    [_collectBtn setImage:[UIImage imageNamed:@"title_collect"] forState:UIControlStateSelected];
    _collectBtn.selected = YES;
    [_collectBtn addTarget:self action:@selector(collectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *collectItem= [[UIBarButtonItem alloc] initWithCustomView:_collectBtn];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(-10, 4, 26, 26);
    [closeBtn setImage:[UIImage imageNamed:@"title_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeItem= [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    
    self.navigationItem.rightBarButtonItems = @[closeItem, collectItem];
}

#pragma mark - RequestData
- (void)requestResultData {
    __weakSelf_(weakSelf);
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_dic[@"result_id"] forKey:@"result_id"];
    [params setObject:_dic[@"project_id"] forKey:@"project_id"];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getExamResultInforByAPP.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [_preloadView removeFromSuperview];
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            weakSelf.dic = arr[0];
            
            [weakSelf initRetestBtn];
            if(isValidString(self.dic[@"next_option_id"]) && isValidString(self.dic[@"next_question_id"]) && ![self.dic[@"next_option_id"] isEqualToString:@"0"] && ![self.dic[@"next_question_id"] isEqualToString:@"0"]) {
                [self.retestBtn setTitle:[NSString stringWithFormat:@"下一个%@", weakSelf.title] forState:UIControlStateNormal];
                [self.retestBtn addTarget:self action:@selector(gotoNext) forControlEvents:UIControlEventTouchUpInside];
                self.retestBtn.titleLabel.font = [UIFont systemFontOfSize:14];
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
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

- (void)reTest {
    [[HealthTestSession shareInstance] clear];
//    [HealthTestSession shareInstance].project_id = self.dic[@"project_id"];
//    [HealthTestSession shareInstance].project_title = self.dic[@"project_title"];
//    [HealthTestSession shareInstance].next_quest_id = self.dic[@"next_question_id"];
//    [HealthTestSession shareInstance].bgimage = self.dic[@"project_pic"];
    HealthWarnVC *vc = [[HealthWarnVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoNext {
//    [[HealthTestSession shareInstance] clear];
//    [HealthTestSession shareInstance].project_title = self.title;
//    [HealthTestSession shareInstance].project_id = self.dic[@"project_id"];
//    HealthSelfTest_VC *vc = [[HealthSelfTest_VC alloc] init];
//    [HealthTestSession shareInstance].next_quest_id = self.dic[@"next_question_id"];
//    [HealthTestSession shareInstance].bgimage = self.dic[@"project_pic"];
//    vc.dicdic = self.dic;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancelCollect {
    __weakSelf_(weakSelf);
    [SVProgressHUD showWithStatus:@"正在取消收藏"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_dic[@"result_id"] forKey:@"result_id"];
    [params setObject:_dic[@"project_id"] forKey:@"project_id"];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"deleteExamResultById.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            weakSelf.collectBtn.selected = NO;
            weakSelf.blockCancelCollect();
            [SVProgressHUD showSuccessWithStatus:@"已取消收藏"];
        }else
        {
            [SVProgressHUD showErrorWithStatus:@"取消收藏失败"];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

#pragma mark Action
- (IBAction)retestBtnClick:(UIButton *)sender {
     if(isValidString(self.dic[@"next_option_id"]) && isValidString(self.dic[@"next_question_id"]) && ![self.dic[@"next_option_id"] isEqualToString:@"0"] && ![self.dic[@"next_question_id"] isEqualToString:@"0"])  {
         [[HealthTestSession shareInstance] clear];
         [HealthTestSession shareInstance].project_title = self.title;
         [HealthTestSession shareInstance].project_id = self.dic[@"project_id"];
         [HealthTestSession shareInstance].next_quest_id = self.dic[@"next_question_id"];
         
         HealthSelfTest_VC *vc = [[HealthSelfTest_VC alloc] init];
         vc.isAutoSkipToNext = YES;
         vc.optionId = self.dic[@"next_option_id"];
         [self.navigationController pushViewController:vc animated:NO];
   
     }else {
         HealthWarn_VC *vc = [[HealthWarn_VC alloc] init];
         [self.navigationController pushViewController:vc animated:YES];
     }
}

- (void)closeBtnClick:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)collectBtnClick:(UIButton *)sender {
    if (sender.selected) {
        [self cancelCollect];
    }else {
        [SVProgressHUD showSuccessWithStatus:@"请重新进行测试"];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CGFloat cHeight = webView.scrollView.contentSize.height;
    //    setViewFrameSizeHeight(webView, cHeight);
    
    CGFloat height = webView.scrollView.contentSize.height;
    CGRect rect = webView.frame;
    rect.size.height = height;
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
