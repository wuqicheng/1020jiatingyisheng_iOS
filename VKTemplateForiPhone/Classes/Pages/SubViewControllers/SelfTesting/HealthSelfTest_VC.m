//
//  HealthSelfTest_VC.m
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/11/30.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import "HealthSelfTest_VC.h"
#import "UserSessionCenter.h"
#import "HealthTestSession.h"
#import "HealthSelfTest_Cell.h"
#import "HealthSelfTestResult_VC.h"
@interface HealthSelfTest_VC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL isFinishLoad;
@property (nonatomic, strong) NSMutableDictionary *questDic;
@property (nonatomic, strong) NSMutableArray *questOptionArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HealthSelfTest_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [HealthTestSession shareInstance].project_title;
    [self customBackButton];
    [self initRightItem];
    if (![HealthTestSession shareInstance].isReady) {
        NSLog(@"111qqqwww");
        [self requestQuestData];
    }else {NSLog(@"3qqqqq");
        if (self.types == 1) {
            [self requestQuestData];
        }else{
        [self refreshData];
        }
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HealthSelfTest_Cell" bundle:nil] forCellReuseIdentifier:@"HealthSelfTest_Cell"];
}

- (void)viewWillAppear:(BOOL)animated {NSLog(@"4qqqqq");
    [self.tableView reloadData];
    if (self.isAutoSkipToNext) {NSLog(@"5qqqqq");
        [self refreshData];
    }
}

- (void)initRightItem {
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, 0, 26, 26);
    closeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [closeBtn setImage:[UIImage imageNamed:@"title_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeItem= [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.rightBarButtonItem = closeItem;
}

- (void)refreshData{
    if (![HealthTestSession shareInstance].isReady) {
        NSLog(@"6qqqq");
        return;
    }
    NSLog(@"7qqqqq");
   
    NSDictionary *dic = [[HealthTestSession shareInstance] next];
    NSLog(@"%@qqqqqqqqqw",dic);
    
    
    self.questDic = dic[@"quest"][0];
    self.questOptionArr = dic[@"option"];
    [self.tableView reloadData];
    
    if (self.isAutoSkipToNext) {
        [self toNext];
    }
}

#pragma mark - Action
- (void)toNext {
    self.isAutoSkipToNext = NO;
    [[HealthTestSession shareInstance] selectQuestOptionWithId:self.optionId];
    HealthSelfTest_VC *vc = [[HealthSelfTest_VC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//导航栏左键响应函数
- (void)goBack {
    [[HealthTestSession shareInstance] rollBack];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonAction {
     [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
}

#pragma mark - RequestData
- (void)requestQuestData {
    __weakSelf_(weakSelf);
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(1) forKey:@"page"];
    [params setObject:@(100) forKey:@"rows"];
    [params setObject:[HealthTestSession shareInstance].project_id forKey:@"project_id"];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getExamQuestionListByAPP.action" param:params onCompletion:^(id jsonResponse) {
 
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (isValidArray(arr)) {
                [[HealthTestSession shareInstance].quest removeAllObjects];
                [[HealthTestSession shareInstance].quest addObjectsFromArray:arr];
                [weakSelf requestQuestOptionListData];
            }else {
                [SVProgressHUD dismiss];
            }
        }
    } onError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

- (void)requestQuestOptionListData {
    __weakSelf_(weakSelf);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(1) forKey:@"page"];
    [params setObject:@(100) forKey:@"rows"];
    [params setObject:[HealthTestSession shareInstance].project_id forKey:@"project_id"];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getExamQuestionOptionListByAPP.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            [[HealthTestSession shareInstance].questOption removeAllObjects];
            [[HealthTestSession shareInstance].questOption addObjectsFromArray:arr];
            NSLog(@"%@11225553344&^&^&^11",arr);//
            
            NSMutableArray *arrrr = [[NSMutableArray alloc] init];
            for (NSObject *aa in [[HealthTestSession shareInstance].questOption valueForKey:@"next_question_id"]) {  NSLog(@"11225666553344&^&^&^11");//
                if(aa == [NSNull null]){ NSLog(@"11225667776553344&^&^&^11");
                   
                }else{ NSLog(@"11225666999553344&^&^&^11");//
                    [arrrr  addObject:aa];
                   
                }
            }

             NSLog(@"%@11223344&^&^&^11",arrrr);//
             [[HealthTestSession shareInstance].nextQuestionIdArry addObjectsFromArray:arrrr];
            
            NSLog(@"%@^^###2211###222",[HealthTestSession shareInstance].nextQuestionIdArry);//
            [weakSelf refreshData];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!self.questDic[@"question_title"]) {
        return 0;
    }
    UIFont *font = [UIFont systemFontOfSize:19];
    NSString *title = [NSString stringWithFormat:@"  %ld、%@",([HealthTestSession shareInstance].selected.count+ 1) , self.questDic[@"question_title"]];;
    CGFloat x = 15+7, y = 15+7;
    CGFloat width = Screen_Width - x*2;
    CGFloat height = getTextHeight(title, font, width);
    return y*2+height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!self.questDic[@"question_title"]) {
        return nil;
    }
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UIFont *font = [UIFont systemFontOfSize:19];
    NSString *title = [NSString stringWithFormat:@"  %ld、%@",([HealthTestSession shareInstance].selected.count + 1) , self.questDic[@"question_title"]];
    CGFloat x = 15+7, y = 15+7;
    CGFloat width = Screen_Width - x*2;
    CGFloat height = getTextHeight(title, font, width);
    UILabel *questLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    questLabel.font = font;
    questLabel.text = title;
    questLabel.numberOfLines = 0;
    [view addSubview:questLabel];
    
    view.frame = CGRectMake(0, 0, Screen_Width, CGRectGetMaxY(questLabel.frame) + questLabel.top);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIFont *labelFont = [UIFont systemFontOfSize:17];
    NSString *labelDetail = self.questOptionArr[indexPath.row][@"option_title"];
    CGFloat labelWidth = Screen_Width - 52 - 15;
    CGFloat labelHeight = getTextHeight(labelDetail, labelFont, labelWidth);
    return labelHeight + 15*2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.questOptionArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HealthSelfTest_Cell *cell = [tableView dequeueReusableCellWithIdentifier:@"HealthSelfTest_Cell"];
    cell.optionLabel.text = self.questOptionArr[indexPath.row][@"option_title"];
    [cell.optionBtn setTitle:self.questOptionArr[indexPath.row][@"sort"] forState:UIControlStateNormal];

    if (_optionId && [self.questOptionArr[indexPath.row][@"option_id"] isEqualToString:_optionId]) {
        cell.optionBtn.selected  = YES;
    }else {
        cell.optionBtn.selected  = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath  {
    HealthSelfTest_Cell *cell = (HealthSelfTest_Cell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.optionBtn.highlighted = YES;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath  {
    HealthSelfTest_Cell *cell = (HealthSelfTest_Cell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.optionBtn.highlighted = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[HealthTestSession shareInstance].nextQuestionIdArry removeObjectAtIndex:indexPath.row];
    _optionId = self.questOptionArr[indexPath.row][@"option_id"];
    [[HealthTestSession shareInstance] selectQuestOptionWithId:self.questOptionArr[indexPath.row][@"option_id"]];
    if ([HealthTestSession shareInstance].next_quest_id && ![[HealthTestSession shareInstance].next_quest_id isEqualToString:@"0"]) {
        HealthSelfTest_VC *vc = [[HealthSelfTest_VC alloc] init];
        vc.dicdic = self.dicdic;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        HealthSelfTestResult_VC *vc = [[HealthSelfTestResult_VC alloc] init];
        vc.dicdicdic = self.dicdic;
        vc.index = indexPath.row;
        vc.project_id = [HealthTestSession shareInstance].project_id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
