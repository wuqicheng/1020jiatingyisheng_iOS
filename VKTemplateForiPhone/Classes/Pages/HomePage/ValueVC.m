//
//  ValueVC.m
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/8/30.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import "ValueVC.h"
#import "UIView+frame.h"
#import "MyAlertView.h"
#import "UserSessionCenter.h"
#import "SegmentViewController.h"
#import "SelfAssessmentVC.h"


@interface ValueVC ()<UIWebViewDelegate>{
    NSMutableArray *dataSource;
    BOOL isLoadingFinished;
    NSString *planContent;
    NSInteger n;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, copy) NSString *titleStr;
//@property (nonatomic,strong) UIWebView *webView;
@end

@implementation ValueVC

- (instancetype)initWithIndex:(NSInteger)index title:(NSString *)title
{
    self = [super init];
    if (self) {
        _titleStr = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 10)];
    _webView.backgroundColor = [UIColor whiteColor];
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    //html是否加载完成
    isLoadingFinished = NO;
    //这里一定要设置为NO
    [self.webView setScalesPageToFit:NO];
    //第一次加载先隐藏webview
    [self.webView setHidden:YES];
    _webView.delegate =self;
    [_webView loadHTMLString:OptimizeHtmlString(planContent) baseURL:nil];
}

- (void) getUserProfileSuccess: (NSNotification*) aNotification
{
    NSLog(@"%@***",[aNotification valueForKey:@"object"]);
    n = [[aNotification valueForKey:@"object"] integerValue];
    [self updateForm];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Data
- (void)getDataFromServerShowIndicator:(bool)on {
    if (on) {
        [SVProgressHUD showWithStatus:String_Loading];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];//,@(pageNoForServer),@"page"
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getHealthPlanListByUser.action" param:params onCompletion:^(id jsonResponse) {
        if (on) {
            [SVProgressHUD dismiss];
        }
        NSLog(@"----++++++++++++++&&&&&&+++++++++++++++++%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
              dataSource = [[NSMutableArray alloc] init];
            [dataSource removeAllObjects];
            [dataSource addObjectsFromArray:[jsonResponse objectForKey:@"rows"]];
            
            NSLog(@"----+++++++++++++++++++++++++++++++%@",self->dataSource);
            
            [self updateForm];
        }
        else {
            if (on) {
                //                [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
            }
        }
        
        if (!isValidArray(dataSource)) {
            //            [self showNoDataWithTips:@"1、健康计划是1020家庭医生为VIP会员制订的执行计划，各个计划内容由1020家庭医生负责维护和更新。\n2、VIP会员点击其中的任一计划，可以查看计划的详细内容。\n 3、VIP会员需要每周日给自己打分（从左向右拖动彩色圆点即可），没有打分，系统即默认为没有执行。您的健康顾问、监护人会根据您的打分判断您的配合与执行情况。"];
            
        }
        else {
            
        }
    } onError:^(NSError *error) {
        if (on) {
            [SVProgressHUD dismiss];
        }
    } defaultErrorAlert:on isCacheNeeded:NO method:nil];
}

//更新视图数据
- (void)updateForm {
    if (_pageNoForView < 1) {
        _pageNoForView = 1;
        return;
    }
    if (_pageNoForView > dataSource.count) {
        _pageNoForView = dataSource.count > 1 ? dataSource.count : 1;
        return;
    }
    //设置标题
    NSDictionary *pInfo = [dataSource objectAtIndex:dataSource.count-(n)];
    if (pInfo == nil) {
        return;
    }else{
    NSLog(@"%ldwwwwwwww",_pageNoForView-1);
    if (self.view.tag == 0) {
        planContent = [pInfo objectForKey:@"nutri_plan"];
        NSLog(@"%@######^^^&&&&",[pInfo objectForKey:@"nutri_plan"]);
    }else if (self.view.tag == 1){
        planContent = [pInfo objectForKey:@"body_health_plan"];
    }else if (self.view.tag == 2){
        planContent = [pInfo objectForKey:@"medical_plan"];
    }else if (self.view.tag == 3){
        planContent = [pInfo objectForKey:@"sport_plan"];
    }
//    wView.scrollView.scrollEnabled = YES;
    [self.webView loadHTMLString:OptimizeHtmlString(planContent) baseURL:nil];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat cHeight = webView.scrollView.contentSize.height;
//    setViewFrameSizeHeight(webView, cHeight);
    
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
                                              html:OptimizeHtmlString(planContent)
                                           webView:webView];
    
    //设置为已经加载完成
    isLoadingFinished = YES;
    //加载实际要现实的html
    [self.webView loadHTMLString:html baseURL:nil];
    
    
    
    
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'";
    [_webView stringByEvaluatingJavaScriptFromString:str];
    
    //获取到webview的高度
    CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue]+20;
    self.webView.frame = CGRectMake(self.webView.frame.origin.x,self.webView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, height+100);
        self.webView.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, height+64+74);
     [self.view addSubview:_webView];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserProfileSuccess:) name:@"Notification_GetUserProfileSuccess" object:nil];
    if (![app_delegate() checkIfLogin]) {
        [app_delegate() presentLoginViewIn:self];
        return;
    }
    _pageNoForView = 1;
    _pageNoForServer = 1;
  
    [self getDataFromServerShowIndicator:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
