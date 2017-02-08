//
//  TodayClinicViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/4.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "TodayClinicViewController.h"
#import "DoctorDetailViewController.h"

@interface TodayClinicViewController ()<UIWebViewDelegate> {
    NSInteger currentPage;
    BOOL isLoadingFinished;;
}
@end

@implementation TodayClinicViewController

- (void)viewDidLoad {
    self.disableRefresh = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"详情";
    [self customBackButton];
    dataSource = [[NSMutableArray alloc] init];
    currentPage = 1;
    
    labelTime.text = getShortDateTimeForShow([self.detailInfo objectForKey:@"last_update_date"]);
    
    wView.scrollView.showsHorizontalScrollIndicator = NO;
    //html是否加载完成
    isLoadingFinished = NO;
    //这里一定要设置为NO
    [wView setScalesPageToFit:NO];
    //第一次加载先隐藏webview
    [wView setHidden:YES];
    [wView loadHTMLString:OptimizeHtmlString([self.detailInfo objectForKey:@"item_desc"]) baseURL:nil];
    wView.delegate = self;
    
//    [wView loadHTMLString:OptimizeHtmlString([self.detailInfo objectForKey:@"item_desc"]) baseURL:nil];
//    wView.scrollView.scrollEnabled = NO;
    
    tbView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tbView.bounds.size.width, 0.01f)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dataSource = [[NSMutableArray alloc] init];
    [self getDoctorList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data
//need to over write
- (void)loadMoreData  {
    currentPage++;
    [self getDoctorList];
}

- (void)getDoctorList {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(currentPage),@"page",[self.detailInfo objectForKey:@"id"],@"id", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getJoinOneCoinDoctorUserList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"remain_page"] integerValue] <= 0) {
            self.isLastPage = YES;
        }
        else {
            self.isLastPage = NO;
        }
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [dataSource addObjectsFromArray:[jsonResponse objectForKey:@"rows"]];
            [tbView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

//#pragma mark - UIWebViewDelegate
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    CGFloat gap = webView.scrollView.contentSize.height - webView.frame.size.height;
////    [tbView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//    [tbView beginUpdates];
//    setViewFrameSizeHeight(cell1, cell1.frame.size.height+gap);
//    [tbView endUpdates];
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
    //获取实际要显示的html
    NSString *html = [self htmlAdjustWithPageWidth:widthOfBody html:OptimizeHtmlString([self.detailInfo objectForKey:@"item_desc"]) webView:webView];
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
    [tbView beginUpdates];

    [tbView endUpdates];
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


#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return cell1;
    }
    NSString *reusedIdentify = @"DoctorCell";
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
    if (indexPath.section == 0) {
        return cell1.frame.size.height;
    }
    return 79.f;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return headerView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return headerView.frame.size.height+12.f;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    DoctorDetailViewController *doctorDetailVc = [[DoctorDetailViewController alloc] init];
    doctorDetailVc.detailInfo = [dataSource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:doctorDetailVc animated:YES];
}

@end
