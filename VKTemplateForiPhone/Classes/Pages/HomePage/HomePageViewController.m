//
//  HomePageViewController.m
//  VKTemplateForiPhone
//
//  Created by Vescky on 14/12/3.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "HomePageViewController.h"
#import "CacheManager.h"
#import "MessageManager.h"
#import "PhotoMessageDetailViewController.h"
#import "FreeSearchViewController.h"
#import "AskDoctorViewController.h"
#import "FamousDoctorViewController.h"
#import "HealthWarn_VC.h"
#import "MedicalReportViewController.h"
#import "HealthyFilesViewController.h"
#import "HealthyKnowledgeViewController.h"
#import "VIPPageViewController.h"
#import "RelationShipViewController.h"
#import "NotificationsListViewController.h"
#import "TodayClinicViewController.h"
//for test
#import "SingleChatViewController.h"
#import "UIView+Common.h"
#import "PickAddressActionSheetView.h"
#import "DoctorCalanderViewController.h"
#import "EvaluateDoctorViewController.h"
#import "MyAlertView.h"
#import "Masonry.h"
#import "LoginPageViewController.h"
#import "AutodiagnosisVC.h"
#import "HealthWarnVC.h"
#import "UserCenterViewController.h"
#import "FollowUpListViewController.h"
#import "HeathyProjectViewController.h"
#import "SelfAssessmentVC.h"
#import "CollectionListVC.h"
#import "UserSessionCenter.h"
#import "MedicalProjectDetail_VC.h"
#import "MJRefresh.h"
#import "AppDelegate.h"
//#import"UIImageView+WebCache.h"

#define kScreenWidth   [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface HomePageViewController ()<VKPhotosCycleViewDelegate,PickAddressActionSheetViewDelegate,UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate> {
    PickAddressActionSheetView *pickAddress;
    UIScrollView *_backScrollView;
    UITableView *_tableView;
    NSArray *_dataArray1;
    NSArray *_dataArray2;
    NSArray *_dataArray3;
    NSInteger viewtag;
}
@property (nonatomic, strong) NSMutableArray *allMedicalProjectList;
@property (nonatomic, strong) NSMutableArray *arr;
@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableArray *picArray;
@property (nonatomic, strong) NSMutableArray *HearthMarketArr;
@end

@implementation HomePageViewController
@synthesize disableLoadMore,disableRefresh,isLastPage = _isLastPage;
@synthesize _header,_footer;

- (void)viewDidLoad {
    [super viewDidLoad];
    _arr = [[NSMutableArray alloc]init];
    _HearthMarketArr = [[NSMutableArray alloc]init];
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-65) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   [self initRefreshView];
    self.title = @"1020家庭医生";
      contentView.hidden = YES;
    photoCycleView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0f];
    __weakSelf_(weakSelf);
    [self requestMallProductTypeListWithDepartId:nil targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
        [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
    }];
    [self requestMedicalProjectWithDepartId:nil targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
        [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
    }];
}

- (void)initItems {
 _titleArray = [_arr valueForKey:@"project_title"];
_picArray = [_arr valueForKey:@"project_pic"];
    NSLog(@"%@+++++++11111111++++++",_arr);

    _dataArray1=@[@[@"jbxx.png",@"基本信息"],@[@"glqr.png",@"管理亲人"],@[@"zfk.png",@"充值付款"],@[@"pgbg.png",@"评估报告"],@[@"jkjh.png",@"健康计划"],@[@"sfzd.png",@"随访指导"],@[@"jkjl.png",@"健康记录"],@[@"mzzp.png",@"每周自评"]];
     _dataArray2=@[@[@"jtys.png",@"家庭医生..."],@[@"jkglt.png",@"健康管理..."],@[@"jyj.png",@"基因检测"],@[@"qsnzg.png",@"青少年增高"],@[@"zyjf.png",@"中医减肥"],@[@"bxb.png",@"白血病"],@[@"jzy.png",@"肩周炎"],@[@"1020haoyun.png",@"1020好孕..."],@[@"ygsty.png",@"乙肝三太阳"],@[@"hhb.png",@"黄褐斑"],@[@"yjbt.png",@"月经不调"],@[@"yw.png",@"阳痿"],@[@"sjt.png",@"四季贴"],@[@"yfxtf.png",@"原发性痛风"],@[@"gnq.png",@"更年期综..."]];
    _dataArray3=@[@[@"ysy.png",@"养身茶饮"],@[@"图层-20.png",@"亚麻籽油"],@[@"图层-19.png",@"心宝1号养心茶"]];
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
     _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.tableHeaderView =photoCycleView;
    //设置cell分割线的颜色
    if([_tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_tableView setSeparatorInset:UIEdgeInsetsZero ];
        [_tableView setSeparatorColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
    }
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitleView:titleView];
//    [self customNavigationBarItemWithImageName:@"phone.png" isLeft:NO];
    if (isBigScreen()) {
    }
    else {
        [scView setContentSize:CGSizeMake(scView.frame.size.width, 460)];
    }
    [self refreshPhotos];
    //每个自定义手势必须单独添加，否则最后一个会将前面的顶掉；
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoPublish:)];
//    tapGestureRecognizer.cancelsTouchesInView = NO;
}

- (void)setIsLastPage:(bool)isLastPage {
    _isLastPage = isLastPage;
    if (!disableLoadMore) {
        _footer.isLastPage = isLastPage;
    }
}

- (void)initRefreshView {
    if (!disableLoadMore) {
        _footer = [MJRefreshFooterView footer];
        _footer.scrollView = _tableView;
        _footer.delegate = self;
    }
    if (!disableRefresh) {
        _header = [MJRefreshHeaderView header];
        _header.scrollView = _tableView;
        _header.delegate = self;
    }
}

- (void)stopRefreshing{
    [_header endRefreshing];
    [_footer endRefreshing];
}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView {
    if (refreshView == _header) {
        //刷新
        [self refreshData];
    }
    else {
        //加载更多
        [self loadMoreData];
    }
}

//need to over write
- (void)refreshData {
    __weakSelf_(weakSelf);
    //        _projectPage = 1;
    [self requestMedicalProjectWithDepartId:nil targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
        [weakSelf.allMedicalProjectList removeAllObjects];
        [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
        //            weakSelf.projectIsEnd = index;
    }];
}

//need to over write
- (void)loadMoreData  {
    __weakSelf_(weakSelf);
    [self requestMallProductTypeListWithDepartId:nil targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
//                    weakSelf.projectPage++;
        [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
        //            weakSelf.projectIsEnd = index;
    }];
}

-(void)gotoPublish0:(UITapGestureRecognizer *)tap {
    UIViewController *vc = [AskDoctorViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)gotoPublish1:(UITapGestureRecognizer *)tap {
    UIViewController *vc = [AutodiagnosisVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)gotoPublish2:(UITapGestureRecognizer *)tap {
    UIViewController *vc = [HealthWarnVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)gotoPublish3:(UITapGestureRecognizer *)tap {
    UIViewController *vc;
    if (tap.view.tag == 1) { 
        vc = [UserCenterViewController new];
    }else if (tap.view.tag == 2){
        vc = [RelationShipViewController new];
    }else if (tap.view.tag == 3){
        //检查登陆
        if (tap.view.tag == 3) {
            if (![app_delegate() checkIfLogin]) {
                [app_delegate() presentLoginViewIn:self];
                return;
            }
        }
        vc = [VIPPageViewController new];
    }else if (tap.view.tag == 4){
        vc = [HealthyFilesViewController new];
    }else if (tap.view.tag == 5){
        //检查登录
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
            return ;
        }
        vc = [SelfAssessmentVC new];
    }else if (tap.view.tag == 6){
        //检查登录
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
            return ;
        }
        vc = [FollowUpListViewController new];
    }else if (tap.view.tag == 7){
        vc = [MedicalReportViewController new];
    }else if (tap.view.tag == 8){
        vc = [HeathyProjectViewController new];
    }
     [self.navigationController pushViewController:vc animated:YES];
}
-(void)gotoPublish4:(UITapGestureRecognizer *)tap {
   NSDictionary *dic = _arr[tap.view.tag-800];
    MedicalProjectDetail_VC *vc = [[MedicalProjectDetail_VC alloc] init];
    vc.project_id = dic[@"project_id"];
        NSLog(@"%@++++5555",vc.project_id);
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)gotoPublish5:(UITapGestureRecognizer *)tap {
    
    NSDictionary *dic = _HearthMarketArr[tap.view.tag-501];

    CollectionListVC *vc = [CollectionListVC new];
    vc.dic= dic;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)gotoPublishMore:(UITapGestureRecognizer *)tap {
    FamousDoctorViewController *vc = [FamousDoctorViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

//加载特色项目数据
- (void)requestMedicalProjectWithDepartId:(NSString *)departId targetTitle:(NSString *)targetTitle page:(NSInteger)page block:(void(^)(BOOL, NSArray *))block {
    __weakSelf_(weakSelf);
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:@[departId?departId:@"", targetTitle?[targetTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@""] forKeys:@[@"hospital_depart_id", @"target_title"]];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    [params setObject:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
    [params setObject:@(15) forKey:@"rows"];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getMedicalProjectListByAPP.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSMutableArray *array = [jsonResponse objectForKey:@"rows"];
            if (jsonResponse[@"remain_page"] && [[NSString stringWithFormat:@"%@", jsonResponse[@"remain_page"]] integerValue] == 0) {
                weakSelf.isLastPage = YES;
            }else {
                weakSelf.isLastPage = NO;
            }
            if (isValidArray(array)) {
                block(weakSelf.isLastPage, _arr);
                if (page == 1) {
                    [_arr removeAllObjects];
                }
                                [_arr addObjectsFromArray:array];
                NSLog(@"_______________%@+++++++++++++++",_arr);
//                [self.tableView reloadData];
                [weakSelf showNoData:NO];
            }else {
                [weakSelf showNoData:YES];
            }
            [weakSelf initItems];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
       
        [weakSelf stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

//加载健康商城
- (void)requestMallProductTypeListWithDepartId:(NSString *)departId targetTitle:(NSString *)targetTitle page:(NSInteger)page block:(void(^)(BOOL, NSArray *))block {
    __weakSelf_(weakSelf);
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:@[departId?departId:@"", targetTitle?[targetTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@""] forKeys:@[@"hospital_depart_id", @"target_title"]];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    [params setObject:@(1) forKey:@"page"];
    [params setObject:@(200) forKey:@"rows"];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getMallProductTypeList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSMutableArray *array = [jsonResponse objectForKey:@"rows"];
            NSLog(@"_______________%@++++++&*&*&*&*&*&*&*&+++++++++",array);
            
            if (jsonResponse[@"remain_page"] && [[NSString stringWithFormat:@"%@", jsonResponse[@"remain_page"]] integerValue] == 0) {
                weakSelf.isLastPage = YES;
            }else {
                weakSelf.isLastPage = NO;
            }
            if (isValidArray(array)) {
                block(weakSelf.isLastPage, array);
                if (page == 1) {
                    [_HearthMarketArr removeAllObjects];
                }
                    [_HearthMarketArr addObjectsFromArray:array];
                ;
                //                [self.tableView reloadData];
                [weakSelf showNoData:NO];
            }else {
                [weakSelf showNoData:YES];
            }
            [weakSelf initItems];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
        [weakSelf stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

//设置_tableView的cell分割线居左顶格
-(void)viewDidLayoutSubviews {
    _backScrollView.contentSize=CGSizeMake(_HearthMarketArr.count*kScreenWidth/2,160);
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    if (_arr.count == 0) {
//        return 0;
//    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    }else if (section==1){
        return 3;
    }else if (section==2){
        return 6;
    }else {
        return 2;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==1 || section==2 || section==3) {
        return 5;
    }else{
        return 0.1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 146;
    }else {
        if (indexPath.row == 0) {
            return 50;
        }else if(indexPath.section == 3&&indexPath.row == 1){
            return 160;
        }else{
            return 70;
        }
    }
//
//    if (indexPath.section == 0) {
//return 146;
//    }else if (indexPath.section == 1){
//        if ((indexPath.row == 0)) {
//            return 50;
//        }else{
//            return 70;
//        }
//    }else if (indexPath.section == 2){
//        if ((indexPath.row == 0)) {
//            return 50;
//        }else{
//            return 70;
//        }
//        
//    }else{
//        if (indexPath.row == 0) {
//            return 50;
//        }else{
//            return 120;
//        }
//    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section == 3) {
//        UIImageView *image= [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 100)];
//        [image setImage:[UIImage imageNamed:@"bannr.png"]];
//        return image;
//    }else{
//        return nil;
//    }
//}

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
        [self viewWillDisappear:YES];
        [self viewDidLayoutSubviews];
    }else//当页面拉动的时候 当cell存在并且最后一个存在 把它进行删除就出来一个独特的cell我们在进行数据配置即可避免
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    cell.layer.shadowOffset = CGSizeMake(0, 1);
    cell.layer.shadowColor = [UIColor grayColor].CGColor;
    cell.layer.shadowRadius = 1;
    cell.layer.shadowOpacity = .5f;
    CGRect shadowFrame = cell.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    cell.layer.shadowPath = shadowPath;
    if (indexPath.section==0) {
        UIView *firstView = [UIView new];
        [cell.contentView addSubview:firstView ];
        [firstView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(cell);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(kScreenWidth/2);
            make.centerY.mas_equalTo(cell);
        }];
        
        UIImageView *img1 = [UIImageView new];
        [firstView addSubview:img1];
        img1.image = [UIImage imageNamed:@"zjzx.png"];
        [img1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(firstView.mas_top).offset(22);
            make.centerX.mas_equalTo(firstView.mas_centerX);
        }];
        
        UILabel *label1 = [UILabel  new];
        label1.text = @"专家在线";
        label1.font = [UIFont systemFontOfSize:14];
        label1.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
        [firstView addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(img1.mas_centerX);
            make.top.mas_equalTo(img1.mas_bottom).offset(10);
        }];
       
        UILabel *label2 = [UILabel  new];
        label2.text = @"在线咨询没有烦恼";
        label2.font = [UIFont systemFontOfSize:11];
        label2.textColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0];
        [firstView addSubview:label2];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(label1.mas_centerX);
            make.top.mas_equalTo(label1.mas_bottom).offset(10);
        }];
        
        UITapGestureRecognizer *tapGestureRecognizer0 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoPublish0:)];
        tapGestureRecognizer0.cancelsTouchesInView = NO;
        firstView.userInteractionEnabled = YES;
        [firstView addGestureRecognizer:tapGestureRecognizer0];
        
        UIView *line1 = [UIView new];
        line1.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        [cell.contentView addSubview:line1];
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kScreenWidth/2);
            make.width.mas_equalTo(1);
            make.top.mas_equalTo(cell.mas_top);
            make.height.mas_equalTo(cell.mas_height);
        }];
         NSLog(@"%f==1234569999==",cell.frame.size.height);
        
        UIView *line2 = [UIView new];
        line2.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        [cell.contentView addSubview:line2];
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(line1.mas_left).offset(1);
            make.right.mas_equalTo(cell.mas_right);
            make.centerY.mas_equalTo(cell.mas_centerY);
            make.height.mas_equalTo(1);
        }];
        
//        UIView *secondView = [UIView new];
//        [cell.contentView addSubview:secondView];
//        [secondView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(kScreenWidth/2);
//            make.right.mas_equalTo(0);
//            make.top.mas_equalTo(0);
//            make.bottom.mas_equalTo(22);
//        }];
//        [cell.contentView addSubview:firstView ];
        
        UIView *secondView = [UIView new];
        [cell.contentView addSubview:secondView ];
        [secondView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(78);
            make.left.mas_equalTo(kScreenWidth/2);
            make.width.mas_equalTo(kScreenWidth/2);
            make.top.mas_equalTo(cell);
        }];
        
        UIImageView *img2 = [UIImageView new];
        img2.image = [UIImage imageNamed:@"xbzz.png"];
        [cell.contentView addSubview:img2];
        [img2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(line1.mas_left).offset(24);
            make.centerY.mas_equalTo(secondView.mas_centerY);
        }];
        
        UILabel *label3 = [UILabel  new];
        label3.text = @"小病自诊";
        label3.font = [UIFont systemFontOfSize:14];
        label3.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
        [cell.contentView addSubview:label3];
        [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(img2.mas_right).offset(14);
            make.centerY.mas_equalTo(img2.mas_centerY);
        }];
        
        UIView *tapview = [UIView new];
        tapview.frame = secondView.frame;
        [cell.contentView addSubview:tapview];
        
        UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoPublish1:)];
        tapGestureRecognizer1.cancelsTouchesInView = NO;
        secondView.userInteractionEnabled = YES;
        [secondView addGestureRecognizer:tapGestureRecognizer1];

        UIView *thirdView = [UIView new];
        [cell.contentView addSubview:thirdView];
        [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(78);
            make.left.mas_equalTo(kScreenWidth/2);
            make.width.mas_equalTo(kScreenWidth/2);
            make.bottom.mas_equalTo(cell);
        }];
        UIImageView *img3 = [UIImageView new];
        img3.image = [UIImage imageNamed:@"jkyj.png"];
        [thirdView addSubview:img3];
        [img3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(img2.mas_centerX);
            make.centerY.mas_equalTo(thirdView.mas_centerY);
        }];
        
        UILabel *label4 = [UILabel  new];
        label4.text = @"健康预警";
        label4.font = [UIFont systemFontOfSize:14];
        label4.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
        [thirdView addSubview:label4];
        [label4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(label3.mas_centerX);
            make.centerY.mas_equalTo(img3.mas_centerY);
        }];
        
        UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoPublish2:)];
        tapGestureRecognizer2.cancelsTouchesInView = NO;
        thirdView.userInteractionEnabled = YES;
        [thirdView addGestureRecognizer:tapGestureRecognizer2];
    }else if(indexPath.section==1)  {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"个人中心";
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor colorWithRed:58/255.0 green:209/255.0 blue:104/255.0 alpha:1.0];
        }else {
            for (int j=1; j<=2; j++) {
                if (indexPath.row == j) {
            for (int i=1; i<=4; i++) {
                UIView *V = [UIView new];
                V.frame = CGRectMake(kScreenWidth/4 * (i-1), 0, kScreenWidth/4, 70);
                [cell.contentView addSubview:V];
                V.tag = (j-1)*4+i;
                
                UIView *line =[UIView new];
                line.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
                line.frame = CGRectMake(kScreenWidth/4, 0, 1, V.frame.size.height);
                [V addSubview:line];
                
                NSArray *array=_dataArray1[i-1+(j-1)*4];
                UIImageView *cimg = [UIImageView new];
                cimg.image = [UIImage imageNamed:array[0]];
                [V addSubview:cimg];
                [cimg mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(V.mas_centerX);
                    make.centerY.mas_equalTo(V.mas_top).offset(28);
                }];
                
                UILabel *clabel = [UILabel new];
                clabel.textAlignment = NSTextAlignmentCenter;
                clabel.text = array[1];
                clabel.font = [UIFont systemFontOfSize:13];
                [V addSubview:clabel];
                clabel.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
                [clabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(cimg.mas_centerX);
                    make.bottom.mas_equalTo(V.mas_bottom).offset(-5);
                }];
                
                UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoPublish3:)];
                tapGestureRecognizer3.cancelsTouchesInView = NO;
                [V addGestureRecognizer:tapGestureRecognizer3];
                    }
                }
            }
        }
    }else if (indexPath.section==2){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"特色项目";
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor colorWithRed:58/255.0 green:209/255.0 blue:104/255.0 alpha:1.0];
            cell.detailTextLabel.text=@"more+";
            cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica Normal" size:13];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:43/255.0 green:95/255.0 blue:59/255.0 alpha:1.0];
            UITapGestureRecognizer *tapMore = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoPublishMore:)];
            tapMore.cancelsTouchesInView = NO;
            [cell.contentView addGestureRecognizer:tapMore];
        }else{
            for (int j=1; j<=5; j++) {
                if (indexPath.row == j) {
                for (int i=1; i<=3; i++) {
                    UIView *cview=[UIView new];
                    cview.frame = CGRectMake(kScreenWidth/3 * (i-1), 0, kScreenWidth/3, 70);
                    cview.tag = 800+i-1+(j-1)*3;
                    [cell.contentView addSubview:cview];
                    
                    UIView *line =[UIView new];
                    [cview addSubview:line];
                    line.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
                    line.frame = CGRectMake(kScreenWidth/3, 0, 1, cview.frame.size.height);
                    
                    NSArray *array=_dataArray2[i-1+(j-1)*3];
                    UIImageView *cimg = [UIImageView new];
                    cimg.layer.cornerRadius = 22;
                    cimg.layer.masksToBounds = YES;
                    [cimg setImageWithURL:[NSURL URLWithString:_picArray[i-1+(j-1)*3]] placeholderImage:[UIImage imageNamed:@"加载失败.png"]];
//                    cimg.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_picArray[i-1+(j-1)*3]]]];
//                    if (!cimg.image) {
//                        cimg.image = [UIImage imageNamed:@"加载失败.png"];
//                    }
//                    cimg.layer.cornerRadius = 20;
                    [cell.contentView addSubview:cimg];
                    [cimg mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(cview.mas_centerX);
                        make.centerY.mas_equalTo(cview.mas_top).offset(25);
                        make.width.mas_equalTo(44);
                        make.height.mas_equalTo(44);
                    }];
                    
                    UILabel *clabel = [UILabel new];
                    clabel.textAlignment = NSTextAlignmentCenter;
                    clabel.text = _titleArray[i-1+(j-1)*3];
                    clabel.font = [UIFont systemFontOfSize:13];
                    [cell.contentView addSubview:clabel];
                    clabel.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
                    [clabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.mas_equalTo(cimg.mas_centerX);
                        make.bottom.mas_equalTo(cview.mas_bottom).offset(-3);
                        make.width.mas_equalTo(90);
                    }];
                    
                    UITapGestureRecognizer *tapGestureRecognizer4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoPublish4:)];
                    tapGestureRecognizer4.cancelsTouchesInView = NO;
                    [cview addGestureRecognizer:tapGestureRecognizer4];
                    }
                }
            }
        }
    }else{
        if (indexPath.row == 0) {
            cell.textLabel.text = @"健康商城";
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor colorWithRed:58/255.0 green:209/255.0 blue:104/255.0 alpha:1.0];
        }else{
            _backScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 160)];
            _backScrollView.contentSize=CGSizeMake(_HearthMarketArr.count*kScreenWidth/2,160);
            _backScrollView.userInteractionEnabled=YES;
            _backScrollView.directionalLockEnabled=YES;
            _backScrollView.pagingEnabled=NO;
            _backScrollView.bounces=NO;
            _backScrollView.showsHorizontalScrollIndicator=YES;
            _backScrollView.showsVerticalScrollIndicator=NO;
            [cell.contentView addSubview:_backScrollView];
            for (int i=1; i<=_HearthMarketArr.count; i++) {
                UIView *cview=[UIView new];
                cview.tag = 500+i;
                [_backScrollView addSubview:cview];
                [cview mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.left.mas_equalTo(kScreenWidth/_HearthMarketArr.count * (i-1));
                    make.left.mas_equalTo(kScreenWidth/2*(i-1)+10);
                    make.top.mas_equalTo(0);
//                    make.width.mas_equalTo(kScreenWidth/_HearthMarketArr.count);
                    make.width.mas_equalTo(kScreenWidth/2);
                    make.height.mas_equalTo(cell);
                }];
                NSMutableArray *_HearthMarketPicArr = [[NSMutableArray alloc]init];
                _HearthMarketPicArr = [_HearthMarketArr valueForKey:@"pic"];
                
                 NSLog(@"_______________%@++++++&*&*&*&111111*&*&*&*&+++++++++",_HearthMarketPicArr);
                UIImageView *cimg = [UIImageView new];
                [cimg setImageWithURL:[NSURL URLWithString:_HearthMarketPicArr[i-1]] placeholderImage:[UIImage imageNamed:@"加载失败.png"]];
                [cview addSubview:cimg];
                [cimg mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(0);
                    make.top.mas_equalTo(30);
//                    make.width.mas_equalTo(kScreenWidth/_HearthMarketArr.count);
                     make.width.mas_equalTo(kScreenWidth/2-20);
                    make.height.mas_equalTo(130);
                }];
                
                NSMutableArray *_HearthMarketTitleArr = [[NSMutableArray alloc]init];
                _HearthMarketTitleArr = [_HearthMarketArr valueForKey:@"name"];
                UILabel *clabel = [UILabel new];
                clabel.text = _HearthMarketTitleArr[i-1];
                clabel.font = [UIFont systemFontOfSize:13];
                [cview addSubview:clabel];
                clabel.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
                [clabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(10);
                    make.top.mas_equalTo(6);
                }];
                
//                UIView *line =[UIView new];
//                line.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
//                [cview addSubview:line];
//                [line mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.left.mas_equalTo(0);
//                    make.top.mas_equalTo(0);
//                    make.width.mas_equalTo(1);
//                    make.height.mas_equalTo(cell);
//                }];
                
                UITapGestureRecognizer *tapGestureRecognizer5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoPublish5:)];
                tapGestureRecognizer5.cancelsTouchesInView = NO;
                [cview addGestureRecognizer:tapGestureRecognizer5];
            }
        }
    }
    cell.accessoryType=UITableViewCellAccessoryNone;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getCompanyPhoneNumber];
    [self getCompanyPhotos];
    if (isValidDictionary([[MessageManager defaultManager] getNewChatMessage]) || isValidDictionary([[CacheManager defaultManager] getPushMessageInfo])) {
        [self customNavigationBarItemWithImageName:@"icon_message_unread.png" isLeft:YES];
    }
    else {
        [self customNavigationBarItemWithImageName:@"icon_message.png" isLeft:YES]; 
    }
    [self customNavigationBarItemWithImageName:@"phone.png" isLeft:NO];
    //推送通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveNewMessage) name:NotificationDidRecieveNewChatMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveNewMessage) name:Notification_Did_Recieve_Remote_Notification object:nil];
 }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _backScrollView.contentSize=CGSizeMake(_HearthMarketArr.count*kScreenWidth/2,160);
   [self performSelector:@selector(checkIfNeedToAutoJump) withObject:nil afterDelay:0.1];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationDidRecieveNewChatMessage object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notification_Did_Recieve_Remote_Notification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
- (void)refreshPhotos {
    NSDictionary *cInfo = [[CacheManager defaultManager] getCompanyInfo];
    if (isValidDictionary(cInfo)) {
        NSArray *photosArr = [cInfo objectForKey:@"photos"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int i = 0; i < photosArr.count; i++) {
            NSDictionary *dic = [photosArr objectAtIndex:i];
            if (isValidDictionary(dic)) {
                VKPhotosCycleViewItem *item = [[VKPhotosCycleViewItem alloc] initVKPhotosCycleViewItemWithTitle:removeHtmlTags([dic objectForKey:@"title"]) ImageUrl:[dic objectForKey:@"top_pic"] Tag:i+1];
                item.ext = dic;
                [arr addObject:item];
            }
        }
        [photoCycleView setData:arr target:self buttomMaskColor:[UIColor blackColor]];
        [photoCycleView.pageControl setCurrentPageIndicatorTintColor:GetColorWithRGB(0, 184, 0)];
    }
}

- (void)didRecieveNewMessage {
    [self customNavigationBarItemWithImageName:@"icon_message_unread.png" isLeft:YES];
}

///检查是否要自动跳转
- (void)checkIfNeedToAutoJump {
    NSDictionary *pushInfo = [[[CacheManager defaultManager] ifNeedToJumpToNotificationList] objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (isValidDictionary(pushInfo)) {
        [app_delegate() handleRemoteNotificationFromBackground:pushInfo];
    }
}

#pragma mark - 加载数据
- (void)getCompanyPhoneNumber {
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",@"status", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getHomePagePhoneList.action" param:nil onCompletion:^(id jsonResponse) {
        if (isValidArray([jsonResponse objectForKey:@"rows"])) {
            NSDictionary *dic = [[jsonResponse objectForKey:@"rows"] firstObject];
            if (isValidDictionary(dic)) {
                NSMutableDictionary *companyInfo = [NSMutableDictionary dictionaryWithDictionary:[[CacheManager defaultManager] getCompanyInfo]];
                [companyInfo setObject:[dic objectForKey:@"phone"] forKey:@"phone"];
                [[CacheManager defaultManager] saveCompanyInfo:companyInfo];
            }
        }
    } onError:^(NSError *error) {
        
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

- (void)getCompanyPhotos {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",@"status", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getHomePagePhotoList.action" param:params onCompletion:^(id jsonResponse) {
        if (isValidArray([jsonResponse objectForKey:@"rows"])) {
            NSMutableDictionary *companyInfo = [NSMutableDictionary dictionaryWithDictionary:[[CacheManager defaultManager] getCompanyInfo]];
            [companyInfo setObject:[jsonResponse objectForKey:@"rows"] forKey:@"photos"];
            [[CacheManager defaultManager] saveCompanyInfo:companyInfo];
            [self refreshPhotos];
        }
    } onError:^(NSError *error) {
        
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

#pragma mark -
//导航栏左键响应函数，重写此函数，响应点击事件；此函数与上面的goback区分
- (void)leftBarButtonAction {
    //检查登陆
    if (![app_delegate() checkIfLogin]) {
        [app_delegate() presentLoginViewIn:self];
        return;
    }
    NotificationsListViewController *nlVc = [[NotificationsListViewController alloc] init];
    [self.navigationController pushViewController:nlVc animated:YES];
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    NSDictionary *cInfo = [[CacheManager defaultManager] getCompanyInfo];
    if (isValidDictionary(cInfo) && isValidString([cInfo objectForKey:@"phone"])) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[cInfo objectForKey:@"phone"]]]];
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",[cInfo objectForKey:@"phone"]];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"服务热线尚未开通"];
    }
}

- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag != 103) {
        //检查登录
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
            return;
        }
    }
}

- (IBAction)testAction:(UIButton*)sender {
//    pickAddress = [[PickAddressActionSheetView alloc] initWithTitle:@"选择地址" pickerType:PickAddressActionSheetViewTypeDefault];
//    pickAddress.delegate = self;
//    [pickAddress show];
//    
//    return;
//    DoctorCalanderViewController *dcvc = [[DoctorCalanderViewController alloc] init];
//    SingleChatViewController *sVc = [[SingleChatViewController alloc] init];
//    [self.navigationController pushViewController:sVc animated:YES];
//    
//    EvaluateDoctorViewController *eVc = [[EvaluateDoctorViewController alloc] init];
//    [self.navigationController pushViewController:eVc animated:YES];
    
    MyAlertView *myAlert = [[MyAlertView alloc] initWithTitle:@"测试" alertContent:@"测试测试苏丹红佛iasdhfoiashgoahisdgoadhgoasidhgoasdihgalkdshg" defaultStyleWithButtons:@[@"好",@"不好"]];
    myAlert.delegate = self;
    [myAlert show];
}

- (void)pickAddressActionSheetView:(PickAddressActionSheetView*)pv didSelectAddress:(PickAddressItem*)address {
    NSLog(@"%@-%@-%@",address.provinceName,address.cityName,address.districtName);
}

- (IBAction)menuAction:(UIButton*)sender {
    //检查登陆
    if (sender.tag == 204 || sender.tag == 206 ||sender.tag == 207 || sender.tag == 208) {
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
            return;
        }
    }
    
    if (sender.tag == 207) {
//        if (![app_delegate() checkIfVIP]) {
//            [self showAlertWithTitle:nil message:@"注册成为VIP会员，享受更多服务哦！" cancelButton:String_Sure sureButton:nil];
//            return;
//        }
    }
    UIViewController *vc;
    if (sender.tag == 200) {
        //免费自查
        vc = [[FreeSearchViewController alloc] init];
    }
    else if (sender.tag == 201) {
        //专科特诊
        vc = [[FamousDoctorViewController alloc] init];
    }
    else if (sender.tag == 202) {
        //医生咨询
        vc = [[AskDoctorViewController alloc] init];
    }
    else if (sender.tag == 203) {
        //体质自测
        vc = [[HealthWarn_VC alloc] init];
    }
    else if (sender.tag == 204) {
        //我的病历
        vc = [[MedicalReportViewController alloc] init];
    }
    else if (sender.tag == 205) {
        //健康知识
        vc = [[HealthyKnowledgeViewController alloc] init];
    }
    else if (sender.tag == 206) {
        //成为VIP
        vc = [[VIPPageViewController alloc] init];
    }
    else if (sender.tag == 207) {
        //VIP档案
        vc = [[HealthyFilesViewController alloc] init];
    }
    else if (sender.tag == 208) {
        //管理亲人
        vc = [[RelationShipViewController alloc] init];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld",(long)buttonIndex);
}

#pragma mark - 轮播图点击 VKPhotosCycleView did select
- (void)photosCycleView:(VKPhotosCycleView*)photoCycleView didSelectedItem:(VKPhotosCycleViewItem*)photoItem {
    if ([[photoItem.ext objectForKey:@"is_clinic"] integerValue] == 1) {
        //今日义诊
        TodayClinicViewController *tcVc = [[TodayClinicViewController alloc] init];
        tcVc.detailInfo = photoItem.ext;
        [self.navigationController pushViewController:tcVc animated:YES];
    }
    else {
        //其他新闻
        PhotoMessageDetailViewController *pDetailVc = [[PhotoMessageDetailViewController alloc] init];
        pDetailVc.detailInfo = photoItem.ext;
        [self.navigationController pushViewController:pDetailVc animated:YES];
    }
}
@end