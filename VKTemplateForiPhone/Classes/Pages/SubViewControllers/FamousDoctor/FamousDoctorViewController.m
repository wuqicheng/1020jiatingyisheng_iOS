//
//  FamousDoctorViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "FamousDoctorViewController.h"
#import "UserSessionCenter.h"
#import "FamousDoctor_Cell.h"
#import "MedicalProjectDetail_VC.h"
#import "FamousDoctorSearch_VC.h"
@interface FamousDoctorViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn1Text;
@property (weak, nonatomic) IBOutlet UIButton *btn1Icon;
@property (weak, nonatomic) IBOutlet UIButton *btn2Text;
@property (weak, nonatomic) IBOutlet UIButton *btn2Icon;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@property (weak, nonatomic) IBOutlet UIView *departPathView;
@property (weak, nonatomic) IBOutlet UILabel *departNameLabel;
@property (nonatomic, strong) SearchTextField *searchTextField;

@property (nonatomic, strong) NSMutableArray *allMedicalProjectList;
@property (nonatomic, strong) NSMutableArray *allDepartList;
@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, assign) NSInteger selectDepartRow;
//分页页码
@property (nonatomic, assign) NSInteger projectPage;        //特色项目页码
@property (nonatomic, assign) NSInteger departPage;         //科室页码
@property (nonatomic, assign) NSInteger departProjectPage;  //科室的特色项目页码
@property (nonatomic, assign) BOOL departIsEnd;         //科室是不是最后一页
@property (nonatomic, assign) BOOL projectIsEnd;  //特色项目是不是最后一页

- (void)requestMedicalProjectWithDepartId:(NSString *)departId targetTitle:(NSString *)targetTitle page:(NSInteger)page block:(void(^)(BOOL, NSArray *))block;
- (IBAction)allDepartBtnClick:(UIButton *)sender;
- (IBAction)btnAction:(UIButton*)sender;
@end

@implementation FamousDoctorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavItem];
    
    _projectPage = 1;
    _departPage = 1;
    _departProjectPage = 1;
    [tbView registerNib:[UINib nibWithNibName:@"FamousDoctor_Cell" bundle:nil] forCellReuseIdentifier:@"FamousDoctor_Cell"];
    
    self.allDepartList = [NSMutableArray array];
    self.allMedicalProjectList = [NSMutableArray array];
    self.departPathView.hidden = YES;
    [self showNoData:YES];
    [self btnAction:(UIButton *)[self.view viewWithTag:100]];
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
    FamousDoctorSearch_VC *vc = [[FamousDoctorSearch_VC alloc] init];
    vc.searchStr = self.searchTextField.text;
    [self.navigationController pushViewController:vc animated:NO];
    self.searchTextField.text = @"";
}

#pragma mark - Private
- (void)showNoData:(bool)showOn {
    self.noDataLabel.hidden = !showOn;
    tbView.hidden = showOn;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.searchTextField resignFirstResponder];
}

#pragma mark - Button Action
- (IBAction)btnAction:(UIButton*)sender {
    [self.searchTextField resignFirstResponder];
    __weakSelf_(weakSelf);
    [self.dataSource removeAllObjects];
    [self showNoData:NO];
    if (sender.tag == 100) {
        _tag = 0;
        _btn1Text.selected = YES;
        _btn1Icon.selected = YES;
        _btn2Text.selected = NO;
        _btn2Icon.selected = NO;
        
        self.isLastPage = weakSelf.projectIsEnd;
        if (self.allMedicalProjectList.count == 0) {
            [self requestMedicalProjectWithDepartId:nil targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
                [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
            }];
        }else {
            [self.dataSource addObjectsFromArray:self.allMedicalProjectList];
        }
    }
    else if (sender.tag == 101) {
        _tag = 1;
        _btn1Text.selected = NO;
        _btn1Icon.selected = NO;
        _btn2Text.selected = YES;
        _btn2Icon.selected = YES;
        
        self.isLastPage = weakSelf.departIsEnd;
        if (self.allDepartList.count == 0) {
            [self requestAllDepartWithPage:1 Block:^(BOOL index, NSArray *arr) {
                [weakSelf.allDepartList addObjectsFromArray:arr];
            }];
        }else {
            [self.dataSource addObjectsFromArray:self.allDepartList];
        }
    }
    [tbView reloadData];
}

- (IBAction)allDepartBtnClick:(UIButton *)sender {
    self.departPathView.hidden = YES;
    self.isLastPage = self.departIsEnd;
    [self btnAction:(UIButton *)[self.view viewWithTag:101]];
}

#pragma mark 上下拉刷新
//need to over write
- (void)refreshData {
    NSLog(@"下拉");
    __weakSelf_(weakSelf);
    if (_tag == 0) {
        _projectPage = 1;
        [self requestMedicalProjectWithDepartId:nil targetTitle:nil page:self.projectPage block:^(BOOL index, NSArray *arr) {
            [weakSelf.allMedicalProjectList removeAllObjects];
            [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
            weakSelf.projectIsEnd = index;
        }];
    }else if (_tag == 1)
    {
        _departPage = 1;
        [self requestAllDepartWithPage:self.departPage Block:^(BOOL index, NSArray *arr) {
            [weakSelf.allDepartList removeAllObjects];
            [weakSelf.allDepartList addObjectsFromArray:arr];
            weakSelf.departIsEnd = index;
        }];
    }else if (_tag == 2)
    {
        _departProjectPage = 1;
        [self requestMedicalProjectWithDepartId:self.allDepartList[_selectDepartRow][@"hospital_depart_id"] targetTitle:nil page:_departProjectPage  block:^(BOOL index, NSArray *arr) {
        }];
    }
}

//need to over write
- (void)loadMoreData  {
    NSLog(@"上拉");
    __weakSelf_(weakSelf);
    if (_tag == 0) {
        [self requestMedicalProjectWithDepartId:nil targetTitle:nil page:self.projectPage+1 block:^(BOOL index, NSArray *arr) {
            weakSelf.projectPage++;
            [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
            weakSelf.projectIsEnd = index;
        }];
    }else if (_tag == 1)
    {
        [self requestAllDepartWithPage:self.departPage+1 Block:^(BOOL index, NSArray *arr) {
            weakSelf.departPage++;
            [weakSelf.allDepartList addObjectsFromArray:arr];
             weakSelf.departIsEnd = index;
        }];
    }else if (_tag == 2)
    {
        [self requestMedicalProjectWithDepartId:self.allDepartList[_selectDepartRow][@"hospital_depart_id"] targetTitle:nil page:_departProjectPage+1  block:^(BOOL index, NSArray *arr) {
            weakSelf.departProjectPage++;
        }];
    }
}


#pragma mark - RequestData
- (void)requestAllDepartWithPage:(NSInteger)page Block:(void(^)(BOOL, NSArray *))block {
    __weakSelf_(weakSelf);
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getHospitalDepartList.action" param:params onCompletion:^(id jsonResponse) {
        
       
        
        
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (jsonResponse[@"remain_page"] && [[NSString stringWithFormat:@"%@", jsonResponse[@"remain_page"]] integerValue] == 0) {
                weakSelf.isLastPage = YES;
            }else {
                weakSelf.isLastPage = NO;
            }
            if (isValidArray(arr)) {
                block(weakSelf.isLastPage, arr);
                if (page == 1) {
                    [weakSelf.dataSource removeAllObjects];
                }
                
                [weakSelf.dataSource addObjectsFromArray:arr];
                [tbView reloadData];
                [weakSelf showNoData:NO];
            }else {
                [weakSelf showNoData:YES];
            }
        }
    } onError:^(NSError *error) {
        [weakSelf showNoData:YES];
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
    
    
}

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
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getMedicalProjectListByAPP.action" param:params onCompletion:^(id jsonResponse) {
        
        NSLog(@"_______________%@+++++++++++++++",jsonResponse);
        
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (jsonResponse[@"remain_page"] && [[NSString stringWithFormat:@"%@", jsonResponse[@"remain_page"]] integerValue] == 0) {
                weakSelf.isLastPage = YES;
            }else {
                weakSelf.isLastPage = NO;
            }
            if (isValidArray(arr)) {
                block(weakSelf.isLastPage, arr);
                if (page == 1) {
                    [weakSelf.dataSource removeAllObjects];
                }
                [weakSelf.dataSource addObjectsFromArray:arr];
                [tbView reloadData];
                [weakSelf showNoData:NO];
            }else {
                [weakSelf showNoData:YES];
            }
        }
    } onError:^(NSError *error) {
        [weakSelf showNoData:YES];
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FamousDoctor_Cell *cell = [tableView dequeueReusableCellWithIdentifier:@"FamousDoctor_Cell" forIndexPath:indexPath];
  
    NSDictionary *dic = self.dataSource[indexPath.row];
    if (self.tag == 0) {
        cell.nameLabel.text = dic[@"project_title"];
        NSLog(@"%@*************",dic[@"project_title"]);
    }else if(self.tag == 1) {
        cell.nameLabel.text = dic[@"depart_name"];
    }else if(self.tag == 2) {
        cell.nameLabel.text = dic[@"project_title"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchTextField resignFirstResponder];
    NSDictionary *dic = self.dataSource[indexPath.row];
    
    if(self.tag == 1) {
        self.tag = 2;
        self.departPathView.hidden = NO;
        self.departNameLabel.text = dic[@"depart_name"];
        _selectDepartRow = indexPath.row;
        [self requestMedicalProjectWithDepartId:dic[@"hospital_depart_id"] targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
            
        }];
    }else if(self.tag == 2 || self.tag == 0) {
        MedicalProjectDetail_VC *vc = [[MedicalProjectDetail_VC alloc] init];
        vc.project_id = dic[@"project_id"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end

