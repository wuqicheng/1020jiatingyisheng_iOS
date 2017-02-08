//
//  SearchDoctorViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/17.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "SearchDoctorViewController.h"
#import "UserSessionCenter.h"
#import "DoctorDetailViewController.h"

@interface SearchDoctorViewController () {
    bool isFinalResultLevel;
    NSMutableArray *dataSourceLevel2;
    NSInteger pageLevel1,pageLevel2;
    NSDictionary *currentCategory;
}

@end

@implementation SearchDoctorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self customBackButton];
    self.title = @"搜索";
    
    
    [tfSearch becomeFirstResponder];
    
    dataSource = [[NSMutableArray alloc] init];
    dataSourceLevel2 = [[NSMutableArray alloc] init];
    pageLevel1 = 0;
    pageLevel2 = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

//自定义样式的导航栏item -- 用标题
- (void)customNavigationBarItemWithTitleName:(NSString*)titleName isLeft:(bool)isLeft {
    if (titleName && titleName.length > 0) {
        UIButton* jumpButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30+((titleName.length-2)*10), 40)];//微调
        [jumpButton setTitle:titleName forState:UIControlStateNormal];
        [jumpButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [jumpButton.titleLabel setTextAlignment:2];
        [jumpButton addTarget:self action:@selector(searchTagAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* actionItem= [[UIBarButtonItem alloc] initWithCustomView:jumpButton];
        if (isLeft) {
            [self.navigationItem setLeftBarButtonItem:actionItem];
        }
        else {
            [self.navigationItem setRightBarButtonItem:actionItem];
        }
    }
}

- (void)goBack {
    if (isFinalResultLevel) {
        isFinalResultLevel = NO;
        [self showNoData:NO];
        [tbView reloadData];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)searchAction:(UIButton*)sender {
    if (tfSearch.text.length > 0) {
        [tfSearch resignFirstResponder];
        pageLevel1 = 1;
        dataSource = [[NSMutableArray alloc] init];
        [self loadCategories];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"请输入关键字"];
    }
}

#pragma mark - Load Data
//need to over write
- (void)refreshData {
    if (isFinalResultLevel) {
        pageLevel2 = 1;
        dataSourceLevel2 = [[NSMutableArray alloc] init];
        [self loadRecords];
    }
    else {
        pageLevel1 = 1;
        dataSource = [[NSMutableArray alloc] init];
        [self loadCategories];
    }
}

//need to over write
- (void)loadMoreData  {
    if (isFinalResultLevel) {
        pageLevel2++;
        [self loadRecords];
    }
    else {
        pageLevel1++;
        [self loadCategories];
    }
}

- (void)loadCategories {
    if (tfSearch.text.length <= 0) {
        return;
    }
    [SVProgressHUD showWithStatus:String_Searching];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tfSearch.text,@"target_title",
                                   @1,@"target_range",@1,@"status",@(pageLevel1),@"page",nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getSearchTargetList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        
        if ([[jsonResponse objectForKey:@"remain_page"] integerValue] <= 0) {
            self.isLastPage = YES;
        }
        else {
            self.isLastPage = NO;
        }
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [dataSource addObjectsFromArray:[jsonResponse objectForKey:@"rows"]];
            if (isValidArray(dataSource)) {
                [self showNoData:NO];
                [tbView reloadData];
            }
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
        
        if (!isValidArray(dataSource)) {
            [SVProgressHUD showErrorWithStatus:@"没有找到相关内容，请您再次输入关键字查找"];
            [self showNoData:YES];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        if (!isValidArray(dataSource)) {
            [self showNoData:YES];
        }
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (void)loadRecords {
    [SVProgressHUD showWithStatus:String_Searching];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[currentCategory objectForKey:@"target_id"],@"target_id",@(pageLevel2),@"page",nil];
    
    if ([[UserSessionCenter shareSession] getUserId]) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getDUserListByApp.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        
        if ([[jsonResponse objectForKey:@"remain_page"] integerValue] <= 0) {
            self.isLastPage = YES;
        }
        else {
            self.isLastPage = NO;
        }
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [dataSourceLevel2 addObjectsFromArray:[jsonResponse objectForKey:@"rows"]];
            if (isValidArray(dataSource)) {
                [self showNoData:NO];
                [tbView reloadData];
            }
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@""] cancelButton:String_Sure sureButton:nil];
        }
        
        if (!isValidArray(dataSourceLevel2)) {
            [self showNoData:YES];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        if (!isValidArray(dataSourceLevel2)) {
            [self showNoData:YES];
        }
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (void)showNoData:(bool)showOn {
    noRecordView.hidden = !showOn;
    tbView.hidden = showOn;
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    return 10;//dataSource.count;
    return isFinalResultLevel ? dataSourceLevel2.count : dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reusedIdentify = isFinalResultLevel ? @"DoctorCell" : @"FreeSearchResultCategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    //init cell
    NSMutableArray *data = isFinalResultLevel ? dataSourceLevel2 : dataSource;
    if (indexPath.row < data.count) {
        if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
            [cell performSelector:@selector(setCellDataInfo:) withObject:[data objectAtIndex:indexPath.row]];
        }
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isFinalResultLevel) {
        return 79.f-(indexPath.row>=dataSourceLevel2.count-1 ? 1.f : 0.f);
    }
    else {
        return 44.f-(indexPath.row>=dataSource.count-1 ? 1.f : 0.f);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    if (isFinalResultLevel) {
        DoctorDetailViewController *dVc = [[DoctorDetailViewController alloc] init];
        dVc.detailInfo = [dataSourceLevel2 objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:dVc animated:YES];
    }
    else {
        isFinalResultLevel = YES;
        currentCategory = [dataSource objectAtIndex:indexPath.row];
        [self refreshData];
    }
}


@end
