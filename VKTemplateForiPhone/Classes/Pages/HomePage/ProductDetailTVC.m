//
//  ProductDetailTVC.m
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/9/6.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import "ProductDetailTVC.h"
#import "Masonry.h"
#import "UILabel+ContentSize.h"
#import "VIPPaymentViewController.h"

@interface ProductDetailTVC ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>{
    BOOL isLoadingFinished;
    
}
@property (nonatomic,strong) UIView *backView;
@end

@implementation ProductDetailTVC
@synthesize detailInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:58.0/255.0 green:209.0/255.0 blue:104.0/255.0 alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self customBackButton];
    self.title = detailInfo[@"name"];
    
//    self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0f];
    _webView = [UIWebView new];
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 10)];
    _webView.scrollView.scrollEnabled = NO;
   
    //html是否加载完成
    isLoadingFinished = NO;
    //这里一定要设置为NO
    [self.webView setScalesPageToFit:NO];
    //第一次加载先隐藏webview
    [self.webView setHidden:YES];
    _webView.delegate =self;
    [_webView loadHTMLString:OptimizeHtmlString([detailInfo objectForKey:@"product_desc"]) baseURL:nil];

    UIImageView *bigImage = [UIImageView new];
    bigImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:detailInfo[@"pic"]]]];
    if (bigImage.image == nil) {
        bigImage.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 210);
    }else{
    bigImage.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:detailInfo[@"pic"]]]].size.height/([UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:detailInfo[@"pic"]]]].size.width)*[UIScreen mainScreen].bounds.size.width);
    }
//    bigImage.contentMode = UIViewContentModeScaleAspectFit;
   
    self.tableView.tableHeaderView = bigImage;
   NSLog(@"rect1: %@", NSStringFromCGRect(bigImage.frame));
    
    _backView = [UIView new];
    _backView.backgroundColor = [UIColor whiteColor];
    _backView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 10);
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = self.title;
    titleLabel.frame = CGRectMake(10, 12, [UIScreen mainScreen].bounds.size.width, 14);
    titleLabel.font = [UIFont systemFontOfSize:15];
    [_backView addSubview:titleLabel];
    //    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.mas_equalTo(10);
    //        make.top.mas_equalTo(bigPicImageView.mas_bottom).offset(12);
    //    }];
    
    UILabel *describ = [UILabel new];
    describ.frame = CGRectMake(10, 32, [UIScreen mainScreen].bounds.size.width-20, 12);
    describ.numberOfLines = 0;
    describ.font = [UIFont systemFontOfSize:14];
    describ.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0f];
    describ.textAlignment = NSTextAlignmentLeft;//左对齐方式；
    describ.lineBreakMode = NSLineBreakByWordWrapping;
    describ.text = detailInfo[@"product_describe"];
//    describ.text = @"缝纫工人那个工湖退换货如果若吃的过好今天换个肠粉法国同行和付出果然皇天后土今天和如果人不会太好干年果然果然果然和人哥";//测试数据；
    [describ setFrame: CGRectMake(10, 32, [UIScreen mainScreen].bounds.size.width-20, [describ contentSizeHeight].height)];
    [_backView addSubview:describ];
    //    [desc mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.mas_equalTo(titleLabel);
    //        make.right.mas_equalTo(-10);
    //        make.top.mas_equalTo(titleLabel.mas_bottom).offset(6);
    //    }];
    [_backView setFrame: CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ([describ contentSizeHeight].height)+85-12)];
    NSLog(@"%f+++&&&***",[describ contentSizeHeight].height);
    
    UILabel *priceMark = [UILabel new];
    priceMark.frame = CGRectMake(9, 68, 14, 14);
    priceMark.font = [UIFont systemFontOfSize:18];
    priceMark.textColor = [UIColor colorWithRed:255.0/255.0 green:100.0/255.0 blue:75.0/255.0 alpha:1.0f];
    priceMark.text = @"￥";
    [_backView addSubview:priceMark];
//    [priceMark mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(titleLabel);
//        make.bottom.mas_equalTo(_backView.mas_bottom).offset(-12);
//        make.width.mas_equalTo(14);
//        make.height.mas_equalTo(13);
//    }];
    
    UILabel *priceNum = [UILabel new];
    priceNum.frame = CGRectMake(CGRectGetMaxX(priceMark.frame), 68, 20, 10);
    priceNum.font = [UIFont systemFontOfSize:18];
    priceNum.textColor = [UIColor colorWithRed:255.0/255.0 green:100.0/255.0 blue:75.0/255.0 alpha:1.0f];
    priceNum.text = detailInfo[@"price"];
//    priceNum.text = @"146734346575";
    [priceNum setFrame: CGRectMake(CGRectGetMaxX(priceMark.frame)+5, 68, [priceNum contentSizeWidth].width, 15)];
    [_backView addSubview:priceNum];
//    [priceNum mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(26);
//        make.top.mas_equalTo(priceMark);
//    }];
    
    UILabel *priceUnit1 = [UILabel new];
    priceUnit1.frame = CGRectMake(CGRectGetMaxX(priceNum.frame)+5, 68, 25, 16);
    priceUnit1.font = [UIFont systemFontOfSize:12];
    priceUnit1.text = @"元／";
    [_backView addSubview:priceUnit1];
    
    UILabel *priceUnit2 = [UILabel new];
    priceUnit2.frame = CGRectMake(CGRectGetMaxX(priceUnit1.frame), 68, [UIScreen mainScreen].bounds.size.width-CGRectGetMaxX(priceUnit1.frame)-120, 16);
    priceUnit2.font = [UIFont systemFontOfSize:12];
    priceUnit2.text = detailInfo[@"df"];
    [_backView addSubview:priceUnit2];
    if (priceUnit2.text.length == 0) {
        priceUnit1.text = @"元";
    }
    
    UIButton *buy = [UIButton new];
    buy.tag = 1000;
    [buy setTitle:@"购买" forState:UIControlStateNormal];
    [buy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buy.titleLabel.font = [UIFont systemFontOfSize:14];
    buy.layer.cornerRadius = 3;
    buy.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:100.0/255.0 blue:75.0/255.0 alpha:1.0f];
    [buy addTarget:self action:@selector(gotoBuy:) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:buy];
    [buy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_backView.mas_bottom).offset(-4);
        make.right.mas_equalTo(-20);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(28);
    }];
    
    UIImageView *line = [UIImageView new];
    line.image = [UIImage imageNamed:@"形状-1-拷贝"];
    [_backView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(buy.mas_top).offset(-4);
        make.right.mas_equalTo(-10);
        make.left.mas_equalTo(10);
        make.height.mas_equalTo(1);
    }];

   
    NSLog(@"%f+++&&&***",_backView.height);
    
 
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) ==NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) *0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) *0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

//自定义样式的返回键
- (void)customBackButton {
    //自定义背景图片
    UIImage* image= [UIImage imageNamed:@"back.png"];
    CGRect frame_1= CGRectMake(0, 0, 20, 44);
    UIView *cView = [[UIView alloc] initWithFrame:frame_1];
    
    //自定义按钮图片
    UIImageView *cImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 11, 20)];
    [cImgView setImage:image];
    [cView addSubview:cImgView];
    
    //覆盖一个大按钮在上面，利于用户点击
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame_1];
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [cView addSubview:backButton];
    
    //创建导航栏按钮UIBarButtonItem
    UIBarButtonItem* backItem= [[UIBarButtonItem alloc] initWithCustomView:cView];
    [self.navigationItem setLeftBarButtonItem:backItem];
}


-(void)gotoBuy:(UIButton *)sender{
        //检查登陆
        if (sender.tag == 1000) {
            if (![app_delegate() checkIfLogin]) {
                [app_delegate() presentLoginViewIn:self];
                return;
            }
        }
    
    VIPPaymentViewController *pVc = [[VIPPaymentViewController alloc] init];
    [self.navigationController pushViewController:pVc animated:YES];
}
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
                                              html:OptimizeHtmlString([detailInfo objectForKey:@"product_desc"])
                                           webView:webView];
    
    //设置为已经加载完成
    isLoadingFinished = YES;
    //加载实际要现实的html
    [self.webView loadHTMLString:html baseURL:nil];
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'";
    [_webView stringByEvaluatingJavaScriptFromString:str];

    //获取到webview的高度
    CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    self.webView.frame = CGRectMake(self.webView.frame.origin.x,self.webView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, height+20);
    [self.tableView reloadData];
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


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
        return 0.01;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }else{
        return 0.01;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        /* 通过webview代理获取到内容高度后,将内容高度设置为cell的高 */
        return _webView.frame.size.height;
    }else{
        return _backView.frame.size.height;
    }
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Tcell=@"3cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
   
    //在cell重用时防止错乱！！！！！！！！！！！！！！！！！！！
    if (!cell) {
        
        if (indexPath.section == 2 && indexPath.row == 0) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Tcell];
            
        }else{
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Tcell];
        }
    }
    else//当页面拉动的时候 当cell存在并且最后一个存在 把它进行删除就出来一个独特的cell我们在进行数据配置即可避免
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    
    
    if (indexPath.section == 0) { NSLog(@"%f==1234565555==",cell.frame.size.height);
        [cell.contentView addSubview:_backView];
        
        
    }
    
    if (indexPath.section == 1) {
         [cell.contentView addSubview:_webView];
    }
    
    cell.accessoryType=UITableViewCellAccessoryNone;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
