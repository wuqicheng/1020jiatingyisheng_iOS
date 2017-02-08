//
//  FreeSearchViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "FreeSearchViewController.h"
#import "FreeSearchDetailAnswerViewController.h"
#import "UserSessionCenter.h"
#import "FreeSearchResultQACell.h"
#import "ZZCustomAlertView.h"

@interface FreeSearchViewController ()<UITextFieldDelegate> {
    NSInteger pageLevel;
    NSDictionary *currentCategory;
    ZZCustomAlertView *alert;
    
    FreeSearchResultQACell *sampleCell2;
}
@property (nonatomic, strong) NSMutableArray *hotSearchKey;  //热搜词
@property (nonatomic, strong) UIView *hotSearchView;        //热搜
@property (nonatomic, strong) NSString *searchString;       //搜索的关键词
@property (nonatomic ,strong) NSArray *Arr1;
@end

@implementation FreeSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self customBackButton];
    
    UIBarButtonItem *bItem = self.navigationItem.leftBarButtonItem;
    UIBarButtonItem *sItem= [[UIBarButtonItem alloc] initWithCustomView:sView];
    self.navigationItem.leftBarButtonItems = @[bItem,sItem];
    
    [self customNavigationBarItemWithTitleName:@"搜索" isLeft:NO];

    dataSource = [[NSMutableArray alloc] init];
    pageLevel = 0;
    
    sampleCell2 = [[[NSBundle mainBundle] loadNibNamed:@"FreeSearchResultQACell" owner:self options:nil] objectAtIndex:0];
    
//    //热搜
//    self.hotSearchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64)];
//    self.hotSearchView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:self.hotSearchView];
    
    [self requestHotSearchData];
    tfSearch.delegate = self;
    tfSearch.clearButtonMode = UITextFieldViewModeWhileEditing;

    
    //搜索框监听
//    [tfSearch  addTarget:self  action:@selector(searchValueChanged:)  forControlEvents:UIControlEventAllEditingEvents];
}

#pragma mark - init
#pragma mark 加载热搜
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    
    return YES;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    tfSearch.delegate = self;
    
    alert = [ZZCustomAlertView alertViewWithParentView:self.view andContentView:nil];
    
    UIScrollView *bgsccroll = [UIScrollView new];
    bgsccroll.frame = CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, 160);
    [alert addSubview:bgsccroll];
    
    
    //头部热搜提示
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,40)];
    //    topView.backgroundColor = _Color_(240, 240, 240, 1.0f);
    topView.backgroundColor = [UIColor blackColor];
    
    
    //***************添加热搜按钮********
    self.hotSearchKey = [self cutString:_Arr1[0][@"hot_target_title"]];
    
    NSLog(@"%@===***+++++=123451234323578====",self.hotSearchKey);
    
    NSInteger index = 0;
    CGFloat orginX = 10, currentX = orginX;
    CGFloat orginY = CGRectGetMaxY(topView.frame)+ 15, currentY = orginY;
    CGFloat height = 32;
    UIButton *btn;
    while (index < self.hotSearchKey.count) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:self.hotSearchKey[index] forState:UIControlStateNormal];
        [btn setTitleColor:_Color_(50, 50, 50, 1) forState:UIControlStateNormal];
        
        [btn setBackgroundColor:[UIColor redColor]];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn addTarget:self action:@selector(hotSearchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 100+index;
        [alert addSubview:btn];
        NSLog(@"%@===***+++++=1====",self.hotSearchKey);
        CGFloat width = getTextWidth(btn.titleLabel.text, btn.titleLabel.font)+6;
        
        if (currentX + width < Screen_Width) {
            btn.frame = CGRectMake(currentX,  currentY, width, height);
            currentX += width + 12;
        }else {
            currentX = orginX;
            currentY += height + 10;
            btn.frame = CGRectMake(currentX,  currentY, width, height);
            currentX += width + 12;
        }
        
        //        [btn setBackgroundColor:_Color_(241, 241, 241, 1)];
        btn.layer.borderColor = _Color_(195, 221, 227, 1).CGColor;
        btn.clipsToBounds  = YES;
        btn.layer.cornerRadius = 8.0f;
        btn.layer.borderWidth = 0.8f;
        index++;
        
        
        [alert addSubview:topView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, topView.width-10, topView.height)];
        label.text = @"热门搜索";
        label.backgroundColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:14];
        [topView addSubview:label];
        
        
        [alert show];
    }
    
    
    //    [alert show];
    
    
    NSLog(@"输入框");
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [tfSearch endEditing:YES];
}



#pragma mark 加载返回按钮
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

#pragma mark - Load Data
//need to over write
- (void)refreshData {
        pageLevel = 1;
        dataSource = [[NSMutableArray alloc] init];
        [self loadRecords:(_searchString)];
}

//need to over write
- (void)loadMoreData  {
        [self loadRecords:(_searchString)];
}

- (void)requestHotSearchData {
    __weakSelf_(weakSelf);
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getMedicalQuestIntroduceList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            _Arr1 = [jsonResponse objectForKey:@"rows"];
            if (isValidArray(_Arr1) && isValidDictionary(_Arr1[0])) {
//                [weakSelf initHotSearchViewSubview:_Arr1[0]];
            }
        }

//            NSArray *arr = [jsonResponse objectForKey:@"rows"];
//            if (isValidArray(arr) && isValidDictionary(arr[0])) {
//                [weakSelf initHotSearchViewSubview:arr[0]];
//            }
//        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

- (void)loadRecords:(NSString *)key {
    __weakSelf_(weakSelf);
    [SVProgressHUD showWithStatus:String_Searching];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(pageLevel),@"page",nil];
    //NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[currentCategory objectForKey:@"target_id"],@"target_id",@1,@"status",@(pageLevel),@"page",nil];
    if ([[UserSessionCenter shareSession] getUserId]) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"user_id"];
    }
    [params setObject:key forKey:@"target_title"];
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getMedicalQuestList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        
        if (pageLevel == 1) {
            [dataSource removeAllObjects];
        }
        
        if (jsonResponse[@"remain_page"] && [[NSString stringWithFormat:@"%@", jsonResponse[@"remain_page"]] integerValue] == 0) {
            weakSelf.isLastPage = YES;
        }else {
            weakSelf.isLastPage = NO;
        }
       
        NSArray *arr = [jsonResponse objectForKey:@"rows"];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            if (isValidArray(arr)) {
                [dataSource addObjectsFromArray:arr];
                [self showNoData:NO];
                [tbView reloadData];
                pageLevel++;
            }else {
                 [self showNoData:YES];
            }
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@""] cancelButton:String_Sure sureButton:nil];
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
    self.hotSearchView.hidden = YES;
    noRecordView.hidden = !showOn;
    tbView.hidden = showOn;
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 10;//dataSource.count;
    return dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reusedIdentify =  @"FreeSearchResultQACell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }

    //init cell
    NSMutableArray *data = dataSource ;
    if (indexPath.row < data.count) {
        if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
            [cell performSelector:@selector(setCellDataInfo:) withObject:[data objectAtIndex:indexPath.row]];
        }
    }
    //cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < dataSource.count) {
         return [sampleCell2 getCellHeight:[dataSource objectAtIndex:indexPath.row]];//79.f
    }else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    FreeSearchDetailAnswerViewController *aVc = [[FreeSearchDetailAnswerViewController alloc] init];
    aVc.detailInfo = [dataSource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:aVc animated:YES];
}

#pragma mark － Action
- (void)goBack {
    if (self.hotSearchView.hidden == YES) {
        self.hotSearchView.hidden = NO;
    }else {
         [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)searchTagAction {
    if (tfSearch.text.length > 0) {
        [tfSearch resignFirstResponder];
        pageLevel = 1;
        _searchString = tfSearch.text;
        [self loadRecords:(_searchString)];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"请输入关键字"];
    }
}

- (void)hotSearchBtnClick:(UIButton *)sender {
    [tfSearch resignFirstResponder];
    if (self.hotSearchKey) {
        self.searchString = self.hotSearchKey[sender.tag - 100];
        pageLevel = 1;
        [self loadRecords:self.searchString];
    }
}

- (void)searchValueChanged:(UITextField *)textField {
    if([textField.text isEqualToString:@""]) {
        self.hotSearchView.hidden = NO;
    }
}
#pragma mark - Other
//@"咳、感冒、鼻炎"  去除“、”号
- (NSMutableArray *)cutString:(NSString *)str {
    NSMutableArray *arr = [NSMutableArray array];
    while ([str rangeOfString:@"、"].location != NSNotFound && str.length > 0) {
        [arr addObject:[str substringToIndex:[str rangeOfString:@"、"].location]];
        str = [str substringFromIndex:[str rangeOfString:@"、"].location+1];
    }
    if (![str isEqualToString:@""] && str.length > 0) {
        [arr addObject:str];
    }
    return arr;
}
@end
