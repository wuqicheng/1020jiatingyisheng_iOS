//
//  CollectionListVC.m
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/9/1.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import "CollectionListVC.h"
#import "UserSessionCenter.h"
#import "Masonry.h"
#import "ProductDetailTVC.h"
#import "UILabel+ContentSize.h"
#import "MJRefresh.h"

@interface CollectionListVC (){
    NSInteger currentPage;
}

@property (nonatomic, strong) NSMutableArray *allMedicalProjectList;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation CollectionListVC
@synthesize disableLoadMore,disableRefresh,isLastPage = _isLastPage;
@synthesize _header,_footer;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.dic[@"name"];
}

- (void)initItems {
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) collectionViewLayout:flowLayout];
    [self initRefreshView];
    self.collectionView.alwaysBounceVertical = YES;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0f]];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    [self.view addSubview:self.collectionView];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
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
        _footer.scrollView = _collectionView;
        _footer.delegate = self;
        
    }
    if (!disableRefresh) {
        _header = [MJRefreshHeaderView header];
        _header.scrollView = _collectionView;
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
    currentPage = 1;
   [self getMedicalReports];
}

//need to over write
- (void)loadMoreData  {
    
    currentPage++;
   [self getMedicalReports];
}

- (void)getMedicalReports {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(currentPage),@"page",
                                   [[UserSessionCenter shareSession] getUserId],@"user_id",nil];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    [params setObject:[NSString stringWithFormat:@"%@",[_dic valueForKey:@"id"]] forKey:@"t_id"];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)currentPage] forKey:@"page"];
    [params setObject:@(6) forKey:@"rows"];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getMallProductList.action" param:params onCompletion:^(id jsonResponse) {
           NSLog(@"＃＃＃%@$$$$11##qqq##&&&&",jsonResponse);
        NSLog(@"223344%@881188118811***",[_dic valueForKey:@"id"]);
        
        [SVProgressHUD dismiss];
        [self stopRefreshing];
//        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
//            NSMutableArray *Array = [jsonResponse objectForKey:@"rows"];
        
//           //过滤
//            NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"t_id = %@",[_dic valueForKey:@"id"]]; // merge the
//            NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[datePredicate]];
//            NSArray *filterDataArr = [Array filteredArrayUsingPredicate: predicate];
            if ([[jsonResponse objectForKey:@"remain_page"] integerValue] <= 0) {
                self.isLastPage = YES;
            }else {
                self.isLastPage = NO;
            }
            
            if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
                NSArray *Array = [jsonResponse objectForKey:@"rows"];
            if (isValidArray(Array)) {
                 [self showNoData:NO];
                _dataArray = [[NSMutableArray alloc]init];
                [_dataArray addObjectsFromArray:Array];
                NSLog(@"%@$$$$####&&&&",_dataArray);
               [self initItems];
                [self.collectionView reloadData];
            }
            }else {
                [self showNoData:YES];
            }
    } onError:^(NSError *error) {
        [self showNoData:YES];
        [SVProgressHUD dismiss];
        [self stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

#pragma mark -- UICollectionViewDataSource

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    //防止cell复用带来的控件重叠
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    UIImageView *picView = [UIImageView new];
    picView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.width);
    
    NSMutableArray *_picArray = [[NSMutableArray alloc]init];
    NSMutableArray *_nameArray = [[NSMutableArray alloc]init];
    NSMutableArray *_subheadArray = [[NSMutableArray alloc]init];
    [_picArray removeAllObjects];
    [_nameArray removeAllObjects];
    [_subheadArray removeAllObjects];
    _picArray = [_dataArray valueForKey:@"pic"];
    _nameArray = [_dataArray valueForKey:@"name"];
    _subheadArray = [_dataArray valueForKey:@"product_describe"];
    NSLog(@"%@*****11111*****2222***",_picArray);
   
    picView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_picArray[indexPath.item]]]];
    [cell.contentView addSubview:picView];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = _nameArray[indexPath.item];
    nameLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(4);
        make.top.mas_equalTo(picView.mas_bottom).offset(4);
    }];
    
    UILabel *subheadLabel = [UILabel new];
//    subheadLabel.text = @"我们你好在哪里喜欢是否能够放暑假发放个人感觉对方的负担发的返回的国家工商局风蛋糕蛋糕加拿大队均反对给你发发奶粉罐奶粉奶粉把奶粉吧你把烦恼不见变得方便。";
    subheadLabel.text = _subheadArray[indexPath.item];
    subheadLabel.font = [UIFont systemFontOfSize:12];
    subheadLabel.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0f];
    [cell.contentView addSubview:subheadLabel];
    [subheadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameLabel);
        make.right.mas_equalTo(-4);
        make.top.mas_equalTo(nameLabel.mas_bottom).offset(3);
    }];
    
    UILabel *priceMark = [UILabel new];
    priceMark.font = [UIFont systemFontOfSize:18];
    priceMark.textColor = [UIColor colorWithRed:255.0/255.0 green:100.0/255.0 blue:75.0/255.0 alpha:1.0f];
    priceMark.text = @"￥";
    [cell.contentView addSubview:priceMark];
    [priceMark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(3);
        make.bottom.mas_equalTo(cell.mas_bottom).offset(-8);;
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(13);
    }];
    
    UILabel *priceNum = [UILabel new];
    priceNum.frame = CGRectMake(22, 190, 20, 15);
    priceNum.font = [UIFont systemFontOfSize:18];
    priceNum.textColor = [UIColor colorWithRed:255.0/255.0 green:100.0/255.0 blue:75.0/255.0 alpha:1.0f];
    NSMutableArray *_priceArray = [[NSMutableArray alloc]init];
    [_priceArray removeAllObjects];
    _priceArray = [_dataArray valueForKey:@"price"];
    priceNum.text = _priceArray[indexPath.item];
    [priceNum setFrame: CGRectMake(22, 194, [priceNum contentSizeWidth].width, 15)];
    NSLog(@"%f------23456123",[priceNum contentSizeWidth].width);
    [cell.contentView addSubview:priceNum];
//    [priceNum mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(19);
//        make.top.mas_equalTo(priceMark);
//    }];
    
    UILabel *priceUnit1 = [UILabel new];
    priceUnit1.frame = CGRectMake(CGRectGetMaxX(priceNum.frame)+5, 194, 25, 16);
    priceUnit1.font = [UIFont systemFontOfSize:12];
    priceUnit1.text = @"元／";
    [cell.contentView addSubview:priceUnit1];
//    [priceUnit1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(CGRectGetMaxX(priceNum.frame)).offset(10);
//        make.bottom.mas_equalTo(priceNum);
//    }];
    
    UILabel *priceUnit2 = [UILabel new];
    priceUnit2.frame = CGRectMake(CGRectGetMaxX(priceUnit1.frame), 194, 145-CGRectGetMaxX(priceUnit1.frame), 16);
    priceUnit2.font = [UIFont systemFontOfSize:12];
    NSMutableArray *_priceUnitArray = [[NSMutableArray alloc]init];
    [_priceUnitArray removeAllObjects];
    _priceUnitArray = [_dataArray valueForKey:@"df"];
    priceUnit2.text = _priceUnitArray[indexPath.item];
    if (priceUnit2.text.length==0) {
        priceUnit1.text = @"元";
    }

    [cell.contentView addSubview:priceUnit2];
    //    [priceUnit2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(90);
//        make.bottom.mas_equalTo(priceNum);
//    }];
    
//    cell.backgroundColor = [UIColor colorWithRed:((10 * indexPath.row) / 255.0) green:((20 * indexPath.row)/255.0) blue:((30 * indexPath.row)/255.0) alpha:1.0f];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    label.textColor = [UIColor redColor];
//    label.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
//    for (id subView in cell.contentView.subviews) {
//        [subView removeFromSuperview];
//    }
//    [cell.contentView addSubview:label];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(145, 216);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);//顶、左、底、右
}

//设置行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //临时改变个颜色，看好，只是临时改变的。如果要永久改变，可以先改数据源，然后在cellForItemAtIndexPath中控制。（和UITableView差不多吧！O(∩_∩)O~）
//    cell.backgroundColor = [UIColor greenColor];
//    NSLog(@"item======%ld",(long)indexPath.item);
//    NSLog(@"row=======%ld",(long)indexPath.row);
//    NSLog(@"section===%ld",(long)indexPath.section);
    [UIView animateWithDuration:0.5 animations:^{
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }];
    ProductDetailTVC *fDetailVc = [[ProductDetailTVC alloc] init];
    fDetailVc.detailInfo = [_dataArray objectAtIndex:indexPath.item];
    [self.navigationController pushViewController:fDetailVc animated:YES];
    
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
