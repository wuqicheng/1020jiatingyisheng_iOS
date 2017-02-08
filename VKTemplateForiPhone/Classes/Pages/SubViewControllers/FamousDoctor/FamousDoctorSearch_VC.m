//
//  FamousDoctorSearch_VC.m
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/10/24.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import "FamousDoctorSearch_VC.h"
#import "FreeSearchResultCategoryCell.h"
#import "MedicalProjectDetail_VC.h"
#import "UserSessionCenter.h"
#import "SearchTextField.h"
@interface FamousDoctorSearch_VC ()
@property (nonatomic, strong) SearchTextField *searchTextField;
@property (nonatomic, assign) NSInteger page;
@end

@implementation FamousDoctorSearch_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavItem];
    _page = 1;
    self.dataSource = [NSMutableArray array];
    [tbView registerNib:[UINib nibWithNibName:@"FreeSearchResultCategoryCell" bundle:nil] forCellReuseIdentifier:@"FreeSearchResultCategoryCell"];
    
    [self rightBarButtonAction];
}

#pragma mark - Nav

- (void)initNavItem {
    self.title = @"";
    [self customBackButton];
    [self customNavigationBarItemWithTitleName:@"搜索" isLeft:NO];
    _searchTextField = [[SearchTextField alloc] initWithFrame:CGRectMake(40, 22, Screen_Width - 100, 30)];
    _searchTextField.placeholder = @"病名";
    _searchTextField.delegate = self;
    self.navigationItem.titleView = _searchTextField;
    _searchTextField.text = self.searchStr;
}

//导航栏左键响应函数
- (void)leftBarButtonAction {
    [self.searchTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

//导航栏右键响应函数
- (void)rightBarButtonAction {
    [self.searchTextField resignFirstResponder];
    if ([self.searchTextField.text isEqualToString:@""]) {
        return;
    }
    self.searchStr = self.searchTextField.text;
    _page = 1;
    [self requestMedicalProjectWithDepartId:nil targetTitle:self.searchStr page:_page];
}

#pragma mark RequestData
- (void)requestMedicalProjectWithDepartId:(NSString *)departId targetTitle:(NSString *)targetTitle page:(NSInteger)page{
    __weakSelf_(weakSelf);
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:@[departId?departId:@"", targetTitle?targetTitle:@""] forKeys:@[@"hospital_depart_id", @"target_title"]];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    [params setObject:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getMedicalProjectListByAPP.action" param:params onCompletion:^(id jsonResponse) {
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (jsonResponse[@"remain_page"] && [[NSString stringWithFormat:@"%@", jsonResponse[@"remain_page"]] integerValue] == 0) {
                weakSelf.isLastPage = YES;
            }else {
                weakSelf.isLastPage = NO;
            }
            if (isValidArray(arr)) {
                if (page == 1) {
                    [weakSelf.dataSource removeAllObjects];
                }
                weakSelf.page++;
                [weakSelf.dataSource addObjectsFromArray:arr];
                [tbView reloadData];
                [weakSelf showNoData:NO];
            }else {
                [SVProgressHUD showErrorWithStatus:@"没有找到相关内容，请您再次输入关键字查找"];
                [weakSelf showNoData:YES];
            }
        }
        [weakSelf stopRefreshing];
    } onError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
        [weakSelf showNoData:YES];
        [weakSelf stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

#pragma mark 上下拉刷新
//need to over write
- (void)refreshData {
    NSLog(@"下拉");
    _page = 1;
    [self requestMedicalProjectWithDepartId:nil targetTitle:self.searchStr page:_page];
}

//need to over write
- (void)loadMoreData  {
    NSLog(@"上拉");
    [self requestMedicalProjectWithDepartId:nil targetTitle:self.searchStr page:_page+1];
}

#pragma mark - Private
- (void)showNoData:(bool)showOn {
    self.notFoundDataView.hidden = !showOn;
    tbView.hidden = showOn;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FreeSearchResultCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FreeSearchResultCategoryCell" forIndexPath:indexPath];
    NSDictionary *dic = self.dataSource[indexPath.row];
    cell.labelTitle.text = dic[@"project_title"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchTextField resignFirstResponder];
    NSDictionary *dic = self.dataSource[indexPath.row];
    MedicalProjectDetail_VC *vc = [[MedicalProjectDetail_VC alloc] init];
    vc.project_id = dic[@"project_id"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
