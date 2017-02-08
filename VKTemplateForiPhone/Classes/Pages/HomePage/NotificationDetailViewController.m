//
//  NotificationDetailViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "NotificationDetailViewController.h"

@interface NotificationDetailViewController ()<UIWebViewDelegate>{
     BOOL isLoadingFinished;
     NSString *content;
}

@end

@implementation NotificationDetailViewController
@synthesize detailInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"通知";//[detailInfo objectForKey:@"push_title"]
    [self customBackButton];
    
    wView.scrollView.showsHorizontalScrollIndicator = NO;
    //html是否加载完成
    isLoadingFinished = NO;
    //这里一定要设置为NO
    [wView setScalesPageToFit:NO];
    //第一次加载先隐藏webview
    [wView setHidden:YES];
    [wView loadHTMLString:@"加载中..." baseURL:nil];
    //    wView.scrollView.scrollEnabled = NO;
    wView.delegate = self;
    
//    [wView loadHTMLString:@"加载中..." baseURL:nil];
    [self getDetailData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getDetailData {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[detailInfo objectForKey:@"message_id"],@"message_id", nil];
    
    NSString *action = @"getReplyDisputePushMsgItem.action";
    if ([[detailInfo objectForKey:@"msg_src_type"] integerValue] == 4) {
        action = @"getImmediatePushRecordByUser.action";
    }
    
    [[AppsNetWorkEngine shareEngine] submitRequest:action param:params onCompletion:^(id jsonResponse) {
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSDictionary *msg = [[jsonResponse objectForKey:@"rows"] firstObject];
            if ([[detailInfo objectForKey:@"msg_src_type"] integerValue] == 4) {
                //系统消息
                content = [msg objectForKey:@"msg_content"];
                [wView loadHTMLString:OptimizeHtmlString(content) baseURL:nil];
            }
            else {
                //纠纷回复
                //<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/><style type=\"text/css\">td {border-style: solid;}</style>
                NSString *contentStr = [NSString stringWithFormat:@"投诉内容：<br>%@<br><br>回复内容：<br>%@<br>",[msg objectForKey:@"dispute_content"],[msg objectForKey:@"reply_content"]];
                content = contentStr;
                [wView loadHTMLString:OptimizeHtmlString(content) baseURL:nil];
            }
        }
        else {
            [wView loadHTMLString:OptimizeHtmlString([jsonResponse objectForKey:@"desc"]) baseURL:nil];
        }
    } onError:^(NSError *error) {
        [wView loadHTMLString:@"加载数据失败" baseURL:nil];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
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
        [wView setHidden:NO];
        return;
    }
    
    //js获取body宽度
    NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth "];
    
    int widthOfBody = [bodyWidth intValue];
    //获取实际要显示的html
    NSString *html = [self htmlAdjustWithPageWidth:widthOfBody html:OptimizeHtmlString(content) webView:webView];
    //设置为已经加载完成
    isLoadingFinished = YES;
    //加载实际要现实的html
    [wView loadHTMLString:html baseURL:nil];
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '300%'";
    [wView stringByEvaluatingJavaScriptFromString:str];
    //获取到webview的高度
    CGFloat height = [[wView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue]+20;
    wView.frame = CGRectMake(wView.frame.origin.x,wView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, 452);
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
