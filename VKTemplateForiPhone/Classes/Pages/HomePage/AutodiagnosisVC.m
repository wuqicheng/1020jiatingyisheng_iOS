//
//  AutodiagnosisVC.m
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/8/24.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import "AutodiagnosisVC.h"
#import "AutodiagnosisCell.h"
#import "UserSessionCenter.h"
#import "FreeSearchResultQACell.h"
#import "FreeSearchDetailAnswerViewController.h"
#import "PopoverView.h"
#import "ZZCustomAlertView.h"
#import "AppDelegate.h"
#import "Masonry.h"


//屏幕宽和高
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)


@interface AutodiagnosisVC ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>
{
    NSInteger pageLevel;
    FreeSearchResultQACell *sampleCell2;
    ZZCustomAlertView *alert;
    UILabel *rightNoData;
}

@property (nonatomic, strong) NSMutableArray *hotSearchKey;  //热搜词

@property (nonatomic, strong) UICollectionView *rightCollectionView;
@property (nonatomic ,strong) NSMutableArray *dataArr;
@property (nonatomic ,strong) NSMutableArray *sourceArr;
@property (nonatomic ,strong) NSArray *Arr;
//@property (nonatomic ,strong) NSMutableArray *imgArr;
@property (nonatomic ,strong) NSArray *myData;
@property (nonatomic ,assign) NSInteger selectedIndex;
@property (nonatomic, strong) UITableView *lefttableView;
@property (nonatomic, assign) BOOL isRelate;
@property (nonatomic, strong) NSString *searchString;       //搜索的关键词
@property (nonatomic, strong) NSMutableArray *allMedicalProjectList;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic ,strong) NSArray *rightArr;
@property (nonatomic, strong) NSMutableArray *rightArrList;
@property (nonatomic, strong) NSMutableArray *parentQuestIdArr;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic ,strong) NSArray *Arr1;
@end

@implementation AutodiagnosisVC

//#pragma mark - 懒加载创建数据
//- (NSMutableArray *)rightArrList {
//    if (!_rightArrList) {
//        self.rightArrList = [NSMutableArray arrayWithCapacity:1];
//    }
//    return _rightArrList;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _page = 1;
    
    _rightArrList = [[NSMutableArray alloc] init];
    
    //    _dataArr = [[NSArray alloc]initWithObjects:@"全身症状",@"头部", @"颈部",@"胸部",@"腹部",@"腰背部",@"四肢",@"皮肤",@"生殖器",@"排泄部",nil];
    //    _imgArr = [[NSArray alloc]initWithObjects:@"qs",@"tb1", @"jb",@"xb",@"fb",@"ybb",@"sz",@"pf",@"szq",@"pxb",nil];
    _myData = [[NSArray alloc]initWithObjects:@"喉咙肿痛",@"牙龈肿痛",@"中耳炎",@"眼睛异常",@"黄褐斑",@"脑积水",@"口臭", nil];
    
    [self customBackButton];
    
    UIBarButtonItem *bItem = self.navigationItem.leftBarButtonItem;
    UIBarButtonItem *sItem= [[UIBarButtonItem alloc] initWithCustomView:sView];
    sView.layer.cornerRadius = 5;
    self.navigationItem.leftBarButtonItems = @[bItem,sItem];
    
    [self customNavigationBarItemWithTitleName:@"搜索" isLeft:NO];
    
    dataSource = [[NSMutableArray alloc] init];
    pageLevel = 0;
    
    sampleCell2 = [[[NSBundle mainBundle] loadNibNamed:@"FreeSearchResultQACell" owner:self options:nil] objectAtIndex:0];
    //    __weakSelf_(weakSelf);
    [self requestHotSearchData];
    [self requestLeftData];
    //    [self requestMedicalProjectWithDepartId:nil targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
    //        [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
    //    }];
    
    tfSearch.delegate = self;
    tfSearch.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    
    return YES;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    tfSearch.delegate = self;
    [[ZZCustomAlertView alertViewOnPresent] dismiss];
    alert = [ZZCustomAlertView alertViewWithParentView:self.view andContentView:nil];
    
    //头部热搜提示
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,40)];
    //    topView.backgroundColor = _Color_(240, 240, 240, 1.0f);
    
    
    
    //***************添加热搜按钮********
    self.hotSearchKey = [self cutString:_Arr1[0][@"hot_target_title"]];
    
    NSLog(@"%@===***+++++=123451234323578====",self.hotSearchKey);
    
    NSInteger index = 0;
    CGFloat orginX = 10, currentX = orginX;
    CGFloat orginY =  10, currentY = orginY;
    CGFloat height = 32;
    UIButton *btn;
    UIScrollView *bgsccroll = [UIScrollView new];
    bgsccroll.frame = CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, 140);
    bgsccroll.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    
    while (index < self.hotSearchKey.count) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:self.hotSearchKey[index] forState:UIControlStateNormal];
        [btn setTitleColor:_Color_(50, 50, 50, 1) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn addTarget:self action:@selector(hotSearchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 100+index;
        [bgsccroll addSubview:btn];
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
            [bgsccroll setContentSize: CGSizeMake([UIScreen mainScreen].bounds.size.width,currentY+height+8)];
        }
        
        //        [btn setBackgroundColor:_Color_(241, 241, 241, 1)];
        btn.layer.borderColor = _Color_(195, 221, 227, 1).CGColor;
        btn.clipsToBounds  = YES;
        btn.layer.cornerRadius = 8.0f;
        btn.layer.borderWidth = 0.8f;
        index++;
        
        
        [alert addSubview:topView];
        [alert addSubview:bgsccroll];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, topView.width, topView.height)];
        label.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0f];
        label.text = @"热门搜索";
        label.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        [topView addSubview:label];
        
        
        
        [alert show];
    }
    
    
    //    [alert show];
    
    
    NSLog(@"输入框");
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [tfSearch resignFirstResponder];
    
    
}



- (void)initHotSearchViewSubview:(NSDictionary *)dic{
    
    [self lefttableView];
    
    
}

- (void)initItems{
    [self CollectionView];
    rightNoData = [UILabel new];
    rightNoData.text = @"暂无数据，请查看其他项";
    rightNoData.frame = CGRectMake(kScreenWidth*0.36, 100, kScreenWidth-kScreenWidth*0.36, 40);
    rightNoData.font = [UIFont systemFontOfSize:12];
    rightNoData.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:rightNoData];
    rightNoData.hidden = YES;
    
    
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
    //    [SVProgressHUD showWithStatus:String_Loading];
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
                [weakSelf initHotSearchViewSubview:_Arr1[0]];
            }
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

//左边列表
//- (void)requestMedicalProjectWithDepartId:(NSString *)departId targetTitle:(NSString *)targetTitle page:(NSInteger)page block:(void(^)(BOOL, NSArray *))block {
//    __weakSelf_(weakSelf);
//    [SVProgressHUD showWithStatus:String_Loading];
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:@[departId?departId:@"", targetTitle?[targetTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@""] forKeys:@[@"hospital_depart_id", @"target_title"]];
//    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
//        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
//    }
//    if (isValidString(ApplicationDelegate.sessionId)) {
//        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
//    }
//    [params setObject:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
//    [[AppsNetWorkEngine shareEngine] submitRequest:@"getParentQuestList.action" param:params onCompletion:^(id jsonResponse) {
//
//        NSLog(@"_______________%@+++++++++++++++",jsonResponse);
//
//        [SVProgressHUD dismiss];
//        [weakSelf stopRefreshing];
//        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
//            _Arr = [jsonResponse objectForKey:@"rows"];
//            if (jsonResponse[@"remain_page"] && [[NSString stringWithFormat:@"%@", jsonResponse[@"remain_page"]] integerValue] == 0) {
//                weakSelf.isLastPage = YES;
//            }else {
//                weakSelf.isLastPage = NO;
//            }
//            if (isValidArray(_Arr)) {
//                block(weakSelf.isLastPage, _Arr);
////                if (page == 1) {
////                    [_sourceArr removeAllObjects];
////                }
////                [_sourceArr addObjectsFromArray:_Arr];
//                _dataArr = [_Arr valueForKey:@"quest_title"];
//                 NSLog(@"%@===***+++++=====",_sourceArr);
//
////                [tbView reloadData];
//                [weakSelf showNoData:NO];
//            }else {
//                [weakSelf showNoData:YES];
//            }
//            [weakSelf initHotSearchViewSubview:_Arr[0]];
//
//        }
//    } onError:^(NSError *error) {
//        [weakSelf showNoData:YES];
//        [SVProgressHUD dismiss];
//        [weakSelf stopRefreshing];
//    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
//}



- (void)requestLeftData {
    __weakSelf_(weakSelf);
    //    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    [params setObject:@(1) forKey:@"page"];
    [params setObject:@(10) forKey:@"rows"];
    
    
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getParentQuestList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
        
        NSLog(@"%@===***+++++=====",jsonResponse);
        
        
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (isValidArray(arr) && isValidDictionary(arr[0])) {
                _dataArr = [arr valueForKey:@"quest_title"];
//                _imgArr = [arr valueForKey:@"quest_pic"];
                _parentQuestIdArr = [arr valueForKey:@"quest_id"];
                
                [weakSelf initHotSearchViewSubview:arr[0]];
                [_lefttableView reloadData];
                
                NSIndexPath *ip=[NSIndexPath indexPathForRow:0 inSection:0];
                [_lefttableView selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionBottom];
                NSIndexPath *path=[NSIndexPath indexPathForItem:0 inSection:0];
                [self tableView:_lefttableView didSelectRowAtIndexPath:path];//默认选中第几行；
                
                
                
                
            }
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

//加载右边数据
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
    [params setObject:_parentQuestIdArr[_selectedIndex] forKey:@"parent_quest_id"];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getParentQuestList.action" param:params onCompletion:^(id jsonResponse) {
        
        
        
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"]; NSLog(@"_______________%@++++1234443233+++++++++++",arr);
            [weakSelf initItems];
            if (jsonResponse[@"remain_page"] && [[NSString stringWithFormat:@"%@", jsonResponse[@"remain_page"]] integerValue] == 0) {
                weakSelf.isLastPage = YES;
            }else {
                weakSelf.isLastPage = NO;
            }
            if (isValidArray(arr)) {
                block(weakSelf.isLastPage, arr);
                if (page == 1) {
                    [_rightArrList removeAllObjects];
                }
                weakSelf.page++;
                
                [_rightArrList addObjectsFromArray:arr];
                
                NSLog(@"_______________%@++++122334411223344+++++++++++",_rightArrList);
                [_rightCollectionView reloadData];
                
                
                
                [weakSelf showNoDataleft:YES];
            }
            else {
                
                
                [_rightArrList removeAllObjects];
                [_rightArrList addObjectsFromArray:arr];
                rightNoData.hidden = NO;
                [_rightCollectionView reloadData];
                //                [weakSelf showNoDataright:YES];
            }
            
            //            NSLog(@"_______________%@++++999999999+++++++++++",_myDataArr);
        }
    } onError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
        [weakSelf showNoDataright:YES];
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
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
                rightNoData.hidden = YES;
                [tbView reloadData];
                pageLevel++;
            }else {
                [self showNoData:YES];
                rightNoData.hidden = YES;
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
    self.lefttableView.hidden = YES;
    self.rightCollectionView.hidden = YES;
    noRecordView.hidden = !showOn;
    tbView.hidden = showOn;
}
- (void)showNoDataleft:(bool)showOn {
    self.lefttableView.hidden = NO;
    self.rightCollectionView.hidden = NO;
    noRecordView.hidden = showOn;
    tbView.hidden = showOn;
}

- (void)showNoDataright:(bool)showOn {
    self.lefttableView.hidden = NO;
    self.rightCollectionView.hidden = YES;
    noRecordView.hidden = !showOn;
    tbView.hidden = showOn;
}



#pragma mark － Action
- (void)goBack {
    [[ZZCustomAlertView alertViewOnPresent] dismiss];
    if (self.lefttableView.hidden == YES) {
        self.lefttableView.hidden = NO;
        self.rightCollectionView.hidden = NO; [tfSearch resignFirstResponder];
        //        tbView.hidden = YES;
        if (_rightArrList.count == 0) {
            rightNoData.hidden = NO;
        }else{
        rightNoData.hidden = YES;
        }
        
    }else {
        [tfSearch resignFirstResponder];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)searchTagAction {
    
    if (tfSearch.text.length > 0) {
        [[ZZCustomAlertView alertViewOnPresent] dismiss];
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
    if (self.hotSearchKey) {
        [[ZZCustomAlertView alertViewOnPresent] dismiss];
        self.searchString = self.hotSearchKey[sender.tag - 100];
        pageLevel = 1;
        [self loadRecords:self.searchString];
        tfSearch.text = self.searchString;
        [tfSearch resignFirstResponder];
        alert.hidden = YES;
        
    }
}

- (void)searchValueChanged:(UITextField *)textField {
    if([textField.text isEqualToString:@""]) {
        //        self.hotSearchView.hidden = NO;
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




//创建lefttableView左边栏
-(UITableView *)lefttableView{
    if (_lefttableView == nil) {
        
        
        _lefttableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth*0.26,kScreenHeight-64) style:UITableViewStylePlain];
        //        _lefttableView.backgroundColor = [UIColor redColor];
        _lefttableView.tag = 5;
        _lefttableView.delegate = self;
        _lefttableView.dataSource = self;
        _lefttableView.rowHeight = 60;
        
        self.lefttableView.showsVerticalScrollIndicator = NO;//隐藏lefttableView滚动条
        
        //设置cell分割线的颜色
        if([_lefttableView respondsToSelector:@selector(setSeparatorInset:)]){
            
            [_lefttableView setSeparatorInset:UIEdgeInsetsZero ];
            
            [_lefttableView setSeparatorColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
            
        }
        
        
        //        _lefttableView.scrollEnabled = NO;//不能滑动
        [self.view addSubview:_lefttableView];
        
        
        
        
    }
    return _lefttableView;
    
}


//设置_lefttableView的cell分割线居左顶格
-(void)viewDidLayoutSubviews {
    
    if ([_lefttableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_lefttableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([_lefttableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [_lefttableView setLayoutMargins:UIEdgeInsetsZero];
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

//创建右边视图
-(UICollectionView *)CollectionView
{
    //创建tableview的列表
    UICollectionViewFlowLayout *flowayout = [[UICollectionViewFlowLayout alloc]init];
    
    //横向最小间距
    flowayout.minimumInteritemSpacing = 0.f;
    flowayout.minimumLineSpacing = 0.5f;
    _rightCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(kScreenWidth*0.26, 0, kScreenWidth-kScreenWidth*0.26, self.view.frame.size.height) collectionViewLayout:flowayout];
    
    [_rightCollectionView registerClass:[AutodiagnosisCell class] forCellWithReuseIdentifier:@"AutodiagnosisCell"];
    
    [_rightCollectionView setBackgroundColor:GetColorWithRGB(240, 240, 240)];
    
    
    _rightCollectionView.delegate = self;
    _rightCollectionView.dataSource = self;
    
    [self.view addSubview:_rightCollectionView];
    
    return _rightCollectionView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 5) {
        
        return 60;
        
    }
    else{
        if (indexPath.row < dataSource.count) {
            return [sampleCell2 getCellHeight:[dataSource objectAtIndex:indexPath.row]];//79.f
        }else {
            return 44;
        }
    }
}


// 行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 5) {
        return _dataArr.count;}
    else{
        
        return dataSource.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 5) {
        
        NSString *identifier = [NSString stringWithFormat:@"cell%ld",(long)indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        } else//当页面拉动的时候 当cell存在并且最后一个存在 把它进行删除就出来一个独特的cell我们在进行数据配置即可避免
        {
            while ([cell.contentView.subviews lastObject] != nil) {
                [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
            }
        }
        cell.backgroundColor = [UIColor clearColor];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.text = _dataArr[indexPath.row];
        [cell.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(cell);
//            make.left.mas_equalTo(48);
             make.centerX.mas_equalTo(cell);
        }];
        
//        UIImageView *img = [UIImageView new];
//        img.frame = CGRectMake(10, 14, 32, 32);
//        img.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_imgArr[indexPath.row]]]];
//        [cell.contentView addSubview:img];
//        
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.0/250.0 green:230.0/250.0 blue:22.0/250.0 alpha:1.0];
        selectedBackgroundView.alpha = 0.1;
        cell.selectedBackgroundView = selectedBackgroundView;//自定义cell选中时的背景
        _titleLabel.highlightedTextColor = [UIColor whiteColor];//cell选中时字体显示为白色
        
        return cell;
    }
    
    else  {
        NSString *reusedIdentify =  @"FreeSearchResultQACell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
        }else//当页面拉动的时候 当cell存在并且最后一个存在 把它进行删除就出来一个独特的cell我们在进行数据配置即可避免
        {
            while ([cell.contentView.subviews lastObject] != nil) {
                [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
            }
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
    
}

// tableview cell 选中
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 5) {
        
        tbView.hidden = YES;
//        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        [_rightCollectionView scrollRectToVisible:CGRectMake(0, 0, self.rightCollectionView.frame.size.width, self.rightCollectionView.frame.size.height) animated:YES];
        
        _selectedIndex = indexPath.row;
        
        __weakSelf_(weakSelf);
        [self requestMedicalProjectWithDepartId:nil targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
            [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
        }];
        [_rightCollectionView reloadData];
        _rightCollectionView.hidden = YES;
        rightNoData.hidden = YES;
        
        
    }
    else{
        [UIView animateWithDuration:0.5 animations:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        
        FreeSearchDetailAnswerViewController *aVc = [[FreeSearchDetailAnswerViewController alloc] init];
        aVc.detailInfo = [dataSource objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:aVc animated:YES];
    }
    
}

#pragma mark------CollectionView的代理方法
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return _rightArrList.count;
    
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    AutodiagnosisCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AutodiagnosisCell" forIndexPath:indexPath];
    cell.collectionView_imageview.frame = CGRectMake(5, 0, 50, 50);
   
    cell.collectionView_Label.frame = CGRectMake(0, 50, 60, 50);
    //根据左边点击的indepath更新右边内容;
    //    switch (_selectedIndex)
    //    {
    //        case 0:
    //            cell.collectionView_imageview.image = [UIImage imageNamed:@"hlzt"];
    //            break;
    //        case 1:
    //            cell.collectionView_imageview.image = [UIImage imageNamed:@"yyzt"];
    //            break;
    //        case 2:
    //            cell.collectionView_imageview.image = [UIImage imageNamed:@"zey"];
    //            break;
    //        case 3:
    //            cell.collectionView_imageview.image = [UIImage imageNamed:@"yjyc"];
    //            break;
    //        case 4:
    //            cell.collectionView_imageview.image = [UIImage imageNamed:@"hhb"];
    //            break;
    //        case 5:
    //            cell.collectionView_imageview.image = [UIImage imageNamed:@"njs"];
    //            break;
    //        case 6:
    //            cell.collectionView_imageview.image = [UIImage imageNamed:@"kc"];
    //            break;
    //        default:
    //            break;
    //    }
    
    NSLog(@"%@____+++++1!!!!",_rightArrList);
    
    if ((isValidArray(_rightArrList))) {
        NSMutableArray *_myDataArr = [[NSMutableArray alloc]init];
        NSMutableArray *_picArray = [[NSMutableArray alloc]init];
        [_myDataArr removeAllObjects];
         [_picArray removeAllObjects];
        [_myDataArr addObjectsFromArray:[_rightArrList valueForKey:@"quest_title"]];
        [_picArray addObjectsFromArray:[_rightArrList valueForKey:@"quest_pic"]];
       
        
        [cell.collectionView_imageview setImageWithURL:[NSURL URLWithString:_picArray[indexPath.item]] placeholderImage:[UIImage imageNamed:@"加载失败.png"]];
//        cell.collectionView_imageview.layer.masksToBounds=YES;
//        cell.collectionView_imageview.layer.cornerRadius=5; //设置为图片宽度的一半出来为圆形
//        cell.collectionView_imageview.layer.borderWidth=1.0f; //边框宽度
//        cell.collectionView_imageview.layer.borderColor=[[UIColor whiteColor] CGColor];//边框颜色
        cell.collectionView_imageview.contentMode = UIViewContentModeScaleToFill;
        cell.collectionView_Label.text = _myDataArr[indexPath.item];
    }else{
        UILabel *noData = [UILabel new];
        noData.text = @"暂无数据，请查看其它项";
        noData.frame = CGRectMake(20, 100, 80, 60);
        [cell.contentView addSubview:noData];
        NSLog(@"%@____+++++12!!!!",_rightArrList);
    }
    return cell;
}

//设置上下左右空间
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(20, 20, 0, 10);
    
}

//调用代理设置itme大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(60,100);
    
}

//collertionview点击事件处理
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    FreeSearchDetailAnswerViewController *aVc = [[FreeSearchDetailAnswerViewController alloc] init];
    aVc.detailInfo = [_rightArrList objectAtIndex:indexPath.item];
    [self.navigationController pushViewController:aVc animated:YES];
    
    NSLog(@"%ld行--%ld组-%ld行",(long)indexPath.item,(long)indexPath.section,(long)indexPath.row);
    
    //    MYShopViewController *shopview = [[MYShopViewController alloc]init];
    //    [self.navigationController pushViewController:shopview animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

 In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     Get the new view controller using [segue destinationViewController].
     Pass the selected object to the new view controller.
}
*/


@end
