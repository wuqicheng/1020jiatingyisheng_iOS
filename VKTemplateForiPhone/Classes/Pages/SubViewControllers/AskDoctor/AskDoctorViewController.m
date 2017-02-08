//
//  AskDoctorViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AskDoctorViewController.h"
#import "DoctorDetailViewController.h"
#import "DropdownMenuCell.h"
#import "UserSessionCenter.h"
#import "SearchDoctorViewController.h"

@interface AskDoctorViewController () {
    NSMutableArray *menus,*departmentList,*statusList;
    NSInteger onlineStatus,phoneStatus,currentPage;
    NSDictionary *selectedDepartment;
    NSArray *phineArry;
}
@property (nonatomic,strong) NSString *phone;
@end

@implementation AskDoctorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"医生咨询";
    [self customBackButton];
    [self customNavigationBarItemWithImageName:@"icon_search_white.png" isLeft:NO];
    
    menus = [[NSMutableArray alloc] init];
    onlineStatus = -1;
    phoneStatus = -1;
    
    DropdownMenuListItem *item1 = [[DropdownMenuListItem alloc] init];
    item1.title = @"全部";
    item1.iconImage = [UIImage imageNamed:@"ad_icon_all.png"];
    
    DropdownMenuListItem *item2 = [[DropdownMenuListItem alloc] init];
    item2.title = @"图文咨询";
    item2.iconImage = [UIImage imageNamed:@"ad_icon_check.png"];
    
    DropdownMenuListItem *item3 = [[DropdownMenuListItem alloc] init];
    item3.title = @"下线";
    item3.iconImage = [UIImage imageNamed:@"ad_icon_unchecked.png"];
    
    
    DropdownMenuListItem *item4 = [[DropdownMenuListItem alloc] init];
    item4.title = @"电话咨询";
    item4.iconImage = [UIImage imageNamed:@"ad_icon_phoneCall.png"];
    
    statusList = [[NSMutableArray alloc] initWithObjects:item1,item2,item4,item3, nil];
    
    departmentList = [[NSMutableArray alloc] init];
    DropdownMenuListItem *itemD = [[DropdownMenuListItem alloc] init];
    itemD.title = @"全部科室";
    itemD.iconImage = [UIImage imageNamed:@"ad_icon_all1.png"];
    itemD.ext = nil;
    [departmentList addObject:itemD];
    
    [self getDepartmentList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
- (void)showDropdownList {
    tbMenu.hidden = NO;
    maskView.hidden = NO;
    
    CGFloat h = menus.count * 44.f;
    if (tbMenu.frame.origin.y+h > self.view.frame.size.height) {
        h = self.view.frame.size.height - tbMenu.frame.origin.y;
    }
    setViewFrameSizeHeight(tbMenu, h);
    
    [tbMenu reloadData];
    
    if ((btn1Icon.selected && !isValidDictionary(selectedDepartment)) || (btn2Icon.selected && onlineStatus == -1)) {
        [tbMenu selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)dismissDropdownList {
    tbMenu.hidden = YES;
    maskView.hidden = YES;
    
    btn1Text.selected = NO;
    btn1Icon.selected = NO;
    btn2Text.selected = NO;
    btn2Icon.selected = NO;
}

-(void)reSetStatus
{
    phoneStatus = -1;
    onlineStatus = -1;
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    SearchDoctorViewController *sdVc = [[SearchDoctorViewController alloc] init];
    [self.navigationController pushViewController:sdVc animated:YES];
}

#pragma mark - Button Action
- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == 100) {
        btn1Text.selected = !btn1Text.selected;
        btn1Icon.selected = !btn1Icon.selected;
        btn2Text.selected = NO;
        btn2Icon.selected = NO;
        menus = departmentList;
    }
    else if (sender.tag == 101) {
        btn1Text.selected = NO;
        btn1Icon.selected = NO;
        btn2Text.selected = !btn2Text.selected;
        btn2Icon.selected = !btn2Icon.selected;
        menus = statusList;
    }
    
    
    if (sender.selected) {
        [self showDropdownList];
    }
    else {
        [self dismissDropdownList];
    }
}

#pragma mark - Data
- (void)getDepartmentList {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@1,@"status", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getHospitalDepartList.action" param:params onCompletion:^(id jsonResponse) {
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            NSLog(@"qqqaaa%@",arr);
            if (isValidArray(arr)) {
                for (int i = 0; i < arr.count; i++) {
                    NSDictionary *dic = [arr objectAtIndex:i];
                    if (isValidDictionary(dic)) {
                        DropdownMenuListItem *item = [[DropdownMenuListItem alloc] init];
                        item.title = [dic objectForKey:@"depart_name"];
                        item.iconLink = [dic objectForKey:@"depart_icon"];
                        item.ext = dic;
                        [departmentList addObject:item];
                    }
                }
            }
        }
    } onError:^(NSError *error) {
        
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

//need to over write
- (void)refreshData {
    currentPage = 1;
    dataSource = [[NSMutableArray alloc] init];
    [self getDoctorList];
}

//need to over write
- (void)loadMoreData  {
    currentPage++;
    [self getDoctorList];
}

- (void)getDoctorList {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(currentPage),@"page",[[UserSessionCenter shareSession] getUserId],@"cur_user_id", nil];
    if (onlineStatus >= 0) {
        [params setObject:@(onlineStatus) forKey:@"work_status"];
    }
    
    if (phoneStatus>=0) {
         [params setObject:@(phoneStatus) forKey:@"phone_line"];
    }
    if (isValidDictionary(selectedDepartment)) {
        NSLog(@"111111111");
        [params setObject:[selectedDepartment objectForKey:@"hospital_depart_id"] forKey:@"hospital_depart_id"];
    }
    
    NSLog(@"qqqq1111%@",params);
    [SVProgressHUD showWithStatus:String_Loading];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getDUserListByApp.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        if (!isValidArray(dataSource)) {
            [self showNoData:YES];
        }
        
        if ([[jsonResponse objectForKey:@"remain_page"] integerValue] <= 0) {
            self.isLastPage = YES;
        }
        else {
            self.isLastPage = NO;
        }
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (isValidArray(arr)) {
                phineArry = [[NSArray alloc]init];
                phineArry = [arr valueForKey:@"user_phone"];
                NSLog(@"%@qqqqq",phineArry);
                
                
                [self showNoData:NO];
                [dataSource addObjectsFromArray:arr];
                [tbView reloadData];
                [self reSetStatus];
            }
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        if (!isValidArray(dataSource)) {
            [self showNoData:YES];
        }
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (void)showNoData:(bool)showOn {
    labelNoData.hidden = !showOn;
    tbView.hidden = showOn;
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 100) {
        //下拉选择
        return menus.count;
    }
    else {
        //医生列表
        return dataSource.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 100) {
        //下拉选择
        NSString *reusedIdentify = @"DropdownMenuCell";
        DropdownMenuCell *cell = (DropdownMenuCell*)[tableView dequeueReusableCellWithIdentifier:reusedIdentify];
        if (!cell) {
            cell = (DropdownMenuCell*)[[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //init cell
        if (indexPath.row < menus.count) {
            DropdownMenuListItem *dItem = [menus objectAtIndex:indexPath.row];
            [cell setCellDataInfo:dItem];
            if (dItem.isSelected) {
                [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
        
        return cell;
    }
    else {
        //医生列表
        NSString *reusedIdentify = @"DoctorCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //init cell
        if (indexPath.row < dataSource.count) {
            if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
                [cell performSelector:@selector(setCellDataInfo:) withObject:[dataSource objectAtIndex:indexPath.row]];
            }
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 100) {
        //下拉
        return 44.0f;
    }
    else {
        return 79.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 100) {
        //下拉菜单
        for (int i = 0; i < menus.count; i++) {
            DropdownMenuListItem *dItem = [menus objectAtIndex:i];
            if (indexPath.row == i) {
                dItem.isSelected = YES;
            }
            else {
                dItem.isSelected = NO;
            }
        }
        
        if (btn1Icon.selected) {
            DropdownMenuListItem *dItem = [menus objectAtIndex:indexPath.row];
            selectedDepartment = dItem.ext;
            label1.text = dItem.title;
        }
        else {
            NSString *statStr = @"全部";
            switch (indexPath.row) {
                case 0:
                    onlineStatus = -1;
                    break;
                case 1:
                    onlineStatus = 1;
                    statStr = @"图文咨询";
                    break;
                case 2:
                    phoneStatus = 1;
                    statStr = @"电话咨询";
                    break;
                case 3:
                    onlineStatus = 0;
                    phoneStatus = 0;
                    statStr = @"下线";
                    break;

                default:
                    break;
            }
            label2.text = statStr;
        }
        [self dismissDropdownList];
        [self refreshData];
    }
    else {
        [UIView animateWithDuration:0.5 animations:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        
        //医生列表
        DoctorDetailViewController *doctorDetailVc = [[DoctorDetailViewController alloc] init];
        doctorDetailVc.detailInfo = [dataSource objectAtIndex:indexPath.row];
        doctorDetailVc.phone = phineArry[indexPath.row];
        [self.navigationController pushViewController:doctorDetailVc animated:YES];
    }
}

@end
