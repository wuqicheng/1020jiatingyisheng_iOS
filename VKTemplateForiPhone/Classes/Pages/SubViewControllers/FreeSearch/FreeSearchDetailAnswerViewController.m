//
//  FreeSearchDetailAnswerViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/19.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "FreeSearchDetailAnswerViewController.h"
#import "UserSessionCenter.h"

@interface FreeSearchDetailAnswerViewController ()<UIWebViewDelegate> {
    bool isCollected;
    BOOL isLoadingFinished;
}

@end

@implementation FreeSearchDetailAnswerViewController
@synthesize detailInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"详情";
    [self customBackButton];
    
    labelTitle.text = [NSString stringWithFormat:@"%@",[detailInfo objectForKey:@"quest_title"]];
    fitLabelHeight(labelTitle, [detailInfo objectForKey:@"quest_title"]);
    setViewFrameSizeHeight(headerView, 2*labelTitle.frame.origin.y+labelTitle.frame.size.height);
    setViewFrameOriginY(contentView, headerView.frame.origin.y+headerView.frame.size.height+8.f);
    setViewFrameSizeHeight(contentView, self.view.frame.size.height-contentView.frame.origin.y);
    

  
    wView.scrollView.showsHorizontalScrollIndicator = NO;
    //html是否加载完成
    isLoadingFinished = NO;
    //这里一定要设置为NO
    [wView setScalesPageToFit:NO];
    //第一次加载先隐藏webview
    [wView setHidden:YES];
    [wView loadHTMLString:OptimizeHtmlString([detailInfo objectForKey:@"quest_desc"]) baseURL:nil];
//    wView.scrollView.scrollEnabled = NO;
     wView.delegate = self;
    
    
    if ([[detailInfo objectForKey:@"collect_quest_id"] integerValue] > 0) {
        [self customNavigationBarItemWithImageName:@"icon_collected.png" isLeft:NO];
        isCollected = YES;
    }
    else {
        [self customNavigationBarItemWithImageName:@"icon_uncollected.png" isLeft:NO];
        isCollected = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    if (![app_delegate() checkIfLogin]) {
        [app_delegate() presentLoginViewIn:self];
        return;
    }
    
    [self customNavigationBarItemWithImageName:@"icon_collected.png" isLeft:NO];
    bool isCancel = NO;
    NSString *action = @"saveOrUpdateCollectQuestInfos.action";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (isCollected) {
        //取消收藏
        isCancel = YES;
        action = @"deleteCollectQuestById.action";
        NSLog(@"%@****&&&^^",detailInfo);
        [params setObject:[detailInfo objectForKey:@"quest_id"] forKey:@"collect_quest_id"];
    }
    else {
        //加入收藏
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"user_id"];
        [params setObject:[detailInfo objectForKey:@"quest_id"] forKey:@"quest_id"];
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

//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    CGFloat cHeight = webView.scrollView.contentSize.height;
////    if (cHeight < 50.f) {
////        cHeight = 50.f;
////    }
////    if (cHeight > self.view.frame.size.height - contentView.frame.origin.y) {
////        cHeight = self.view.frame.size.height - contentView.frame.origin.y;
////    }
////    
////    setViewFrameSizeHeight(contentView, cHeight);
//    setViewFrameSizeHeight(webView, cHeight);
//    scView.contentSize = CGSizeMake(scView.frame.size.width, webView.frame.origin.y+cHeight);
//}

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
        [wView setHidden:NO];
        return;
    }
    
    //js获取body宽度
    NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth "];
    
    int widthOfBody = [bodyWidth intValue];
    NSLog(@"%@qqqqqqq",[detailInfo objectForKey:@"quest_desc"]);
    //获取实际要显示的html
    NSString *html = [self htmlAdjustWithPageWidth:widthOfBody html:OptimizeHtmlString([detailInfo objectForKey:@"quest_desc"]) webView:webView];
    //设置为已经加载完成
    isLoadingFinished = YES;
    //加载实际要现实的html
    [wView loadHTMLString:html baseURL:nil];
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '300%'";
    [wView stringByEvaluatingJavaScriptFromString:str];
    //获取到webview的高度
    CGFloat height = [[wView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue]+20;
    wView.frame = CGRectMake(wView.frame.origin.x,wView.frame.origin.y+30, [UIScreen mainScreen].bounds.size.width, 452);
    //    wView.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, height+64+74);
    [self.view addSubview:wView];
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
