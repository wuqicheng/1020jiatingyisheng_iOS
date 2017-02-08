//
//  ExampleViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/8/29.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import "ExampleViewController.h"
#import "UIView+frame.h"
#import "UserSessionCenter.h"
#import "HealthWarnVC.h"
#import "HealthSelfTestPre_VC.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "RegexKitLite.h"

@interface ExampleViewController ()<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate>{
//    UITableView *tableView;
}

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, strong) NSArray *listdata;
@property (nonatomic, strong) NSArray *titledata;

@end

@implementation ExampleViewController
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
//    HealthWarnVC *vc = [HealthWarnVC new];
//    _dataSource = [[NSMutableArray alloc]init];
//    _dataSource = vc.dataSource2;
    
    NSLog(@"%@=====1===1==1",_dataSource);
    
//     [self requestListData];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setupUI
{
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0f];
    _tableView.separatorStyle = NO;
    _tableView.height = [UIScreen mainScreen ].bounds.size.height - 50-64-10;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置_tableView的cell分割线居左顶格
-(void)viewDidLayoutSubviews {
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!(indexPath.row == 0)) {
        return 130;
    }else{
    return 125;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    HealthWarnVC *vc = [HealthWarnVC new];
    
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Tcell=@"3cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //在cell重用时防止错乱！！！！！！！！！！！！！！！！！！！
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Tcell];
    }
    else//当页面拉动的时候 当cell存在并且最后一个存在 把它进行删除就出来一个独特的cell我们在进行数据配置即可避免
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    NSMutableArray *picArray = [[NSMutableArray alloc]init];
    picArray = [_dataSource valueForKey:@"project_pic"];
    UIImageView *img = [UIImageView new];
    
//    img.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:picArray[indexPath.row]]]];
//    if (!img.image) {
//        img.image = [UIImage imageNamed:@"加载失败.png"];
//    }
     [img setImageWithURL:[NSURL URLWithString:picArray[indexPath.row]] placeholderImage:[UIImage imageNamed:@"加载失败.png"]];
    if (!(indexPath.row == 0)) {
    img.frame = CGRectMake(15, 30, 76, 76);
    
    UIView *topView = [UIView new];
    topView.frame = CGRectMake(0, 0, cell.frame.size.width, 5);
    topView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0f];
    [cell.contentView addSubview:topView];
    }else{
        img.frame = CGRectMake(15,25,76,76);
    }
    [cell.contentView addSubview:img];
    UILabel *cellTitleLabel = [UILabel new];
    NSMutableArray *tArray = [[NSMutableArray alloc]init];
    tArray = [_dataSource valueForKey:@"project_title"];
    cellTitleLabel.text = tArray[indexPath.row];
    [cell.contentView addSubview:cellTitleLabel];
    [cellTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(130);
                make.centerY.mas_equalTo(img.mas_centerY).offset(-26);
            }];
//    cell.textLabel.text = [_titleStr stringByAppendingString:[NSString stringWithFormat:@"-%d",(int)indexPath.row]];
    //    [cell.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(cell.top).offset(10);
//        make.width.mas_equalTo(150);
//        make.left.mas_equalTo(12);
//        make.centerY.mas_equalTo(cell);
//    }];
//    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[_desc1Array[indexPath.row] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//    UILabel *cellTitleLabel = [UILabel new];
//    cell.detailTextLabel.text = @"欢迎你回来";
//    cellTitleLabel.text = _tArray[0];
//    [cell.contentView addSubview:cellTitleLabel];
//    [cellTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(155);
//        make.centerY.mas_equalTo(img);
//    }
    NSString * htmlString = [_dataSource valueForKey:@"desc1"][indexPath.row];
    NSString *regEx = @"<\\s*img\\s+([^>]*)\\s*>";
    NSString * stringWithoutHTML = [htmlString stringByReplacingOccurrencesOfRegex:regEx withString:@""];
    
    NSLog(@"stringWithoutHTML=%@^^^11&&&222",stringWithoutHTML);
    NSString * htmlString1 = stringWithoutHTML;
    NSString *regEx1 = @"<([^>]*)>";
    NSString * stringWithoutHTML1 = [htmlString1 stringByReplacingOccurrencesOfRegex:regEx1 withString:@""];
    NSString *str = [stringWithoutHTML1 stringByReplacingOccurrencesOfRegex:@"&nbsp; " withString:@""];
    NSString *str1 = [str stringByReplacingOccurrencesOfRegex:@"&nbsp;" withString:@""];
     NSLog(@"stringWithoutHTML=%@^^^11&&333&222",str1);
    
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str1];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:8];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str1 length])];
    UILabel *detail = [[UILabel alloc]initWithFrame:CGRectMake(130, 60,  [UIScreen mainScreen].bounds.size.width-150, 80)];
    detail.numberOfLines = 2;
    detail.attributedText = attributedString;
    detail.textColor = [UIColor grayColor];
   [cell.contentView addSubview:detail];
    [detail sizeToFit];
//    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//    UILabel * myLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 40, [UIScreen mainScreen].bounds.size.width-150, 80)];
//    myLabel.numberOfLines = 2;
//    myLabel.attributedText = attrStr;
//    [cell.contentView addSubview:myLabel];
    cell.accessoryType=UITableViewCellAccessoryNone;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HealthSelfTestPre_VC *vc = [[HealthSelfTestPre_VC alloc] init];
    vc.dic = _dataSource[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)requestListData {
//    __weakSelf_(weakSelf);
//    [SVProgressHUD showWithStatus:String_Loading];
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
//        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
//    }
//    if (isValidString(ApplicationDelegate.sessionId)) {
//        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
//    }
//    if (isValidString(ApplicationDelegate.sessionId)) {
////        [params setObject:ApplicationDelegate.sessionId forKey:@"type_id"];
//        [params setObject:@(4) forKey:@"type_id"];
//    }
//    
//    [[AppsNetWorkEngine shareEngine] submitRequest:@"getExamProjectList.action" param:params onCompletion:^(id jsonResponse) {
//        [SVProgressHUD dismiss];
//        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
//            NSLog(@"+++%@***#####++++",jsonResponse);
//            
//            weakSelf.listdata = [jsonResponse objectForKey:@"rows"];
//            weakSelf.titledata = [_listdata valueForKey:@"project_title"];
//            
//            
//            //            [weakSelf initHealthWarnItems];
//        }
//    } onError:^(NSError *error) {
//        [SVProgressHUD dismiss];
//    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
//}
@end