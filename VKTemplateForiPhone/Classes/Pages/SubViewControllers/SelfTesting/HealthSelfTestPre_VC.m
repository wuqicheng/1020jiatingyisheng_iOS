//
//  HealthSelfTestPre_VC.m
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/11/30.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import "HealthSelfTestPre_VC.h"
#import "HealthSelfTest_VC.h"
#import "HealthTestSession.h"
#import "Masonry.h"
@interface HealthSelfTestPre_VC ()<UIWebViewDelegate>
{
    BOOL isLoadingFinished;
}
@property (nonatomic,strong) UIWebView *webView;

@end

@implementation HealthSelfTestPre_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customBackButton];
    [self initRightItem];
    self.title = self.dic[@"project_title"];
//    self.webView.scrollView.bounces = NO;
   
//    //html是否加载完成
//    isLoadingFinished = NO;
//    
//    //这里一定要设置为NO
//    [self.webView setScalesPageToFit:NO];
//    
//    [self.webView loadHTMLString:OptimizeHtmlString(self.dic[@"desc1"]) baseURL:nil];
//    
//    //第一次加载先隐藏webview
//    [self.webView setHidden:YES];
//    
//    self.webView.delegate = self;
//    
////    [self.webView loadHTMLString:OptimizeHtmlString(self.dic[@"desc1"]) baseURL:nil];
    
    _webView = [UIWebView new];
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 960)];
    _webView.backgroundColor = [UIColor whiteColor];
     self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    //html是否加载完成
    isLoadingFinished = NO;
    //这里一定要设置为NO
    [self.webView setScalesPageToFit:NO];
    //第一次加载先隐藏webview
    [self.webView setHidden:YES];
    _webView.delegate =self;
    [_webView loadHTMLString:OptimizeHtmlString(self.dic[@"desc1"]) baseURL:nil];
    
    
     [self.view addSubview:_webView];
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 480-70+20, [UIScreen mainScreen].bounds.size.width, 74)];
    bgView.backgroundColor = [UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1.0f];
    [self.view addSubview:bgView];
    UIButton *startTextBtn = [UIButton new];
    [startTextBtn setBackgroundImage:[UIImage imageNamed:@"icon-体质自测-start.png"] forState:UIControlStateNormal];
    [startTextBtn setTitle:@"开始测试" forState:UIControlStateNormal];
    [startTextBtn setTintColor:[UIColor whiteColor]];
    startTextBtn.titleLabel.font = [UIFont systemFontOfSize:19];
    [startTextBtn addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:startTextBtn];
    [startTextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView);
        make.centerY.mas_equalTo(bgView);
        make.width.mas_equalTo(147);
        make.height.mas_equalTo(42);
    }];
    
   }

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
         CGFloat cHeight = webView.scrollView.contentSize.height;
//        setViewFrameSizeHeight(webView, cHeight);
//        scView.contentSize = CGSizeMake(scView.frame.size.width, webView.frame.origin.y+cHeight);
    
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
    NSString *html = [self htmlAdjustWithPageWidth:widthOfBody
                                              html:OptimizeHtmlString(self.dic[@"desc1"])
                                           webView:webView];
    
    //设置为已经加载完成
    isLoadingFinished = YES;
    //加载实际要现实的html
    [self.webView loadHTMLString:html baseURL:nil];
    
    NSString *meta1 = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=self.view.frame.size.width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=5.0, user-scalable=yes\""];
    [_webView stringByEvaluatingJavaScriptFromString:meta1];
    
    
//    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '400%'";
//    [_webView stringByEvaluatingJavaScriptFromString:str];
    
    //获取到webview的高度
    CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue]+20;
    self.webView.frame = CGRectMake(self.webView.frame.origin.x,self.webView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, height-180-74-44-210-6);
//    self.webView.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, height+64+74);
//    [self.tableView reloadData];
   
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

- (void)initRightItem {
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, 0, 26, 26);
    closeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [closeBtn setImage:[UIImage imageNamed:@"title_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeItem= [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.rightBarButtonItem = closeItem;
}

#pragma mark - Action
- (void)rightBarButtonAction {
     [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
}

- (void)test:(UIButton *)sender {
    //检查登录
    if (![app_delegate() checkIfLogin]) {
        [app_delegate() presentLoginViewIn:self];
        return ;
    }

    [[HealthTestSession shareInstance] clear];
    NSLog(@"%@,%@,%@88888&&&&",_dic[@"project_id"],_dic[@"project_title"],_dic[@"next_question_id"]);
    
    [HealthTestSession shareInstance].project_id = _dic[@"project_id"];
    [HealthTestSession shareInstance].project_title = _dic[@"project_title"];
    [HealthTestSession shareInstance].next_quest_id = _dic[@"next_question_id"];
    [HealthTestSession shareInstance].bgimage = _dic[@"project_pic"];
    HealthSelfTest_VC *vc = [[HealthSelfTest_VC alloc] init];
    vc.dicdic = self.dic;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
