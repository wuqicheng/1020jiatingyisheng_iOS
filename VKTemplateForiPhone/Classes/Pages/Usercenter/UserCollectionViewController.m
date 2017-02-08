//
//  UserCollectionViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/23.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "UserCollectionViewController.h"
#import "UserSessionCenter.h"
#import "DoctorDetailViewController.h"
#import "FreeSearchDetailAnswerViewController.h"
#import "UserProjectCollect_Cell.h"
#import "MedicalProjectDetail_VC.h"
@interface UserCollectionViewController () {
    NSInteger expPage, doctorPage, projectPage;
}
@property (nonatomic, assign) NSInteger selectBtnTag;
@end

@implementation UserCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的收藏";
    [self customBackButton];
    
    expPage = 1;
    doctorPage = 1;
    projectPage = 1;
    dataSource = [[NSMutableArray alloc] init];
    
    [tbView registerNib:[UINib nibWithNibName:@"UserProjectCollect_Cell" bundle:nil] forCellReuseIdentifier:@"UserProjectCollect_Cell"];
    self.selectBtnTag = 100;
    [self refreshData];
}


#pragma mark - Button Action
- (IBAction)btnAction:(UIButton*)sender {
    if (sender.selected) {
        return;
    }
    
    ((UIButton *)[self.topView viewWithTag:self.selectBtnTag]).selected = NO;
    ((UIView *)[self.topView viewWithTag:self.selectBtnTag+100]).hidden = YES;
    ((UIButton *)[self.topView viewWithTag:sender.tag]).selected = YES;
    ((UIView *)[self.topView viewWithTag:sender.tag+100]).hidden = NO;
    _selectBtnTag = sender.tag;
    [self refreshData];
}

#pragma mark - Data
//need to over write
- (void)refreshData {
    if (_selectBtnTag == 100) {
        expPage = 1;
    }
    else if (_selectBtnTag == 101) {
        doctorPage = 1;
    }else if (_selectBtnTag == 102) {
        projectPage = 1;
    }
    [self getCollectionListWithPage:1];
}

//need to over write
- (void)loadMoreData  {
    NSInteger page;
    if (_selectBtnTag == 100) {
        page = expPage+1;
    }
    else if (_selectBtnTag == 101) {
        page = doctorPage+1;
    }else if (_selectBtnTag == 102) {
        page = projectPage+1;
    }
    [self getCollectionListWithPage:page];
}

- (void)getCollectionListWithPage:(NSInteger)page {
    NSString *url;
    if (_selectBtnTag == 100) {
        url = @"getCollectQuestByUser.action";
    }
    else if (_selectBtnTag == 101) {
        url = @"getCollectDoctorByUser.action";
    }else if (_selectBtnTag == 102) {
        url = @"getCollectProjectByUser.action";
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@(page) forKey:@"page"];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setValue:[[UserSessionCenter shareSession] getUserId] forKey:@"user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setValue:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    
    __weakSelf_(weakSelf);
    [SVProgressHUD showWithStatus:String_Loading];
    [[AppsNetWorkEngine shareEngine] submitRequest:url param:params onCompletion:^(id jsonResponse) {
        [self stopRefreshing];
        [SVProgressHUD dismiss];
        
        if ([[jsonResponse objectForKey:@"remain_page"] integerValue] <= 0) {
            weakSelf.isLastPage = YES;
        }
        else {
            weakSelf.isLastPage = NO;
        }
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (page == 1) {
                [dataSource removeAllObjects];
            }
            if (isValidArray(arr)) {
                if (weakSelf.selectBtnTag == 100) {
                     expPage++;
                }
                else if (_selectBtnTag == 101) {
                    doctorPage++;
                }else if (_selectBtnTag == 102) {
                    projectPage++;
                }
                
                [weakSelf showNoData:NO];
                [dataSource addObjectsFromArray:arr];
                [tbView reloadData];
            }
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
        
        if (!isValidArray(dataSource)) {
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

- (void)showNoData:(bool)showOn {
    labelNoData.hidden = !showOn;
    tbView.hidden = showOn;
}


#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_selectBtnTag == 100) {
        //经验列表
        NSString *reusedIdentify = @"FreeSearchResultQACell";
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
    else  if (_selectBtnTag == 101){
        //医生列表
        NSString *reusedIdentify = @"UserCollectionCell1";
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
    }else if (_selectBtnTag == 102){
        UserProjectCollect_Cell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserProjectCollect_Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *dic = dataSource[indexPath.row];
        cell.departNameLabel.text = dic[@"depart_name"];
        cell.projectNameLabel.text = dic[@"project_title"];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectBtnTag == 102){
        return 60.0f;
    }
    return 79.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select at row:%d",indexPath.row);
    NSDictionary *dic = dataSource[indexPath.row];
    if (_selectBtnTag == 100) {
        //经验
        FreeSearchDetailAnswerViewController *fVc = [[FreeSearchDetailAnswerViewController alloc] init];
        fVc.detailInfo = dic;
        [self.navigationController pushViewController:fVc animated:YES];
    }
    else if  (_selectBtnTag == 101) {
        //医生
        DoctorDetailViewController *dVc = [[DoctorDetailViewController alloc] init];
        dVc.detailInfo = dic;
        [self.navigationController pushViewController:dVc animated:YES];
    }else if (_selectBtnTag == 102) {
        MedicalProjectDetail_VC *vc = [[MedicalProjectDetail_VC alloc] init];
        vc.project_id = dic[@"project_id"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
