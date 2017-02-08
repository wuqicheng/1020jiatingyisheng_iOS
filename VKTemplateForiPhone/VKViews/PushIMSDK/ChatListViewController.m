//
//  ChatListViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "ChatListViewController.h"
#import "MessageManager.h"
#import "UserSessionCenter.h"
#import "SingleChatViewController.h"

@interface ChatListViewController () {
    NSInteger currentPage;
}

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    self.disableLoadMore = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"咨询记录";
    [self customBackButton];
    currentPage = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NotificationDidRecieveNewChatMessage object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationDidRecieveNewChatMessage object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationDidRecieveNewChatMessage object:nil];
}


#pragma mark - Data
#pragma mark - Data
- (void)refreshData {
    currentPage = 1;
    dataSource = [[NSMutableArray alloc] init];
    [self getData];
}

////need to over write
//- (void)loadMoreData  {
//    currentPage++;
//    [self getData];
//}

- (void)getData {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];//,@(currentPage),@"page"
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getCommentSessionListByAppUser.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
//        if ([[jsonResponse objectForKey:@"remain_page"] integerValue] <= 0) {
//            self.isLastPage = YES;
//        }
//        else {
//            self.isLastPage = NO;
//        }
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [dataSource addObjectsFromArray:[jsonResponse objectForKey:@"rows"]];
            [tbView reloadData];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
        
        if (!isValidArray(dataSource)) {
            //无数据？
            tbView.hidden = YES;
            labelNoData.hidden = NO;
        }
        else {//有数据
            tbView.hidden = NO;
            labelNoData.hidden = YES;
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}


#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reusedIdentify = @"ChatListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    //init cell
    if (indexPath.row < dataSource.count) {
        if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
            [cell performSelector:@selector(setCellDataInfo:) withObject:[dataSource objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select at row:%d",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = [dataSource objectAtIndex:indexPath.row];
    SingleChatViewController *sVc = [[SingleChatViewController alloc] init];
//    sVc.conversationInfo = [dataSource objectAtIndex:indexPath.row];
    sVc.conversationId = [dic objectForKey:@"conversation_id"];
    [self.navigationController pushViewController:sVc animated:YES];
}


@end
