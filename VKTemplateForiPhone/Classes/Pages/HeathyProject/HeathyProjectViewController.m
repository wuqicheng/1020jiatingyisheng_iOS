//
//  HeathyProjectViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/20.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "HeathyProjectViewController.h"
#import "FollowUpListViewController.h"
#import "MySliderView.h"
#import "HeathyProjectChartViewController.h"
#import "UserSessionCenter.h"
#import "HeathyProjectDetailViewController.h"
#import "MyAlertView.h"
#import "THud.h"

#define AmountPerPage 10

@interface HeathyProjectViewController ()<MySliderViewDelegate> {
    MySliderView *slider1,*slider2,*slider3,*slider4;
    NSInteger pageNoForView,pageNoForServer;
    NSMutableArray *dataSource;
    NSMutableDictionary *dic;
}

@end

@implementation HeathyProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dic = [[NSMutableDictionary alloc] init];
    [self customBackButton];
    // Do any additional setup after loading the view from its nib.
    self.title = @"每周自评";
    //    [self customNavigationBarItemWithTitleName:@"随访记录" isLeft:NO];
    [self initSliders];
   }

- (IBAction)btn:(UIButton*)sender {
     MyAlertView *myAlert = [[MyAlertView alloc] initWithTitle:@"每周自评" alertContent:@"每周评分是客户或监护人对健康计划执行情况的自我评价，每周仅自评1次即可，不要随便拉动。请客观打分，以便后台家庭医生根据执行情况及时调整方案。没有打分，即默认您没有配合执行计划。\n打分方法：先在心里为自己各个计划本周的执行情况打分（100分制），再按住对应的彩条从左向右分别拉动至相应分数，点击提交按钮。" style:MyAlertViewStyleI_Know];
    [myAlert show];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![app_delegate() checkIfLogin]) {
        [app_delegate() presentLoginViewIn:self];
        return;
    }
    
//    if (![app_delegate() checkIfVIP]) {
//        [self showAlertWithTitle:nil message:@"注册成为VIP会员，享受更多服务哦！" cancelButton:String_Sure sureButton:nil];
//        [self showNoData:YES];
//        tbView.hidden = YES;
//        return;
//    }
//    else {
        tbView.hidden = NO;
        [self showNoData:NO];
//    }
    
    pageNoForView = 1;
    pageNoForServer = 1;
    dataSource = [[NSMutableArray alloc] init];
    [self getDataFromServerShowIndicator:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

- (void)initSliders {
    CGRect sliderRect = CGRectMake(25, 42, 286, 20);
    slider1 = [[MySliderView alloc] initWithFrame:sliderRect
                                      cursorImage:[UIImage imageNamed:@"project_cursor1.png"]
                                  foregroundImage:[[UIImage imageNamed:@"project_progress1.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5]
                                  backgroundImage:[[UIImage imageNamed:@"project_progress_bg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:4]];
    
    slider2 = [[MySliderView alloc] initWithFrame:sliderRect
                                      cursorImage:[UIImage imageNamed:@"project_cursor2.png"]
                                  foregroundImage:[[UIImage imageNamed:@"project_progress2.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5]
                                  backgroundImage:[[UIImage imageNamed:@"project_progress_bg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:4]];
    
    slider3 = [[MySliderView alloc] initWithFrame:sliderRect
                                      cursorImage:[UIImage imageNamed:@"project_cursor3.png"]
                                  foregroundImage:[[UIImage imageNamed:@"project_progress3.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5]
                                  backgroundImage:[[UIImage imageNamed:@"project_progress_bg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:4]];
    
    slider4 = [[MySliderView alloc] initWithFrame:sliderRect
                                      cursorImage:[UIImage imageNamed:@"project_cursor4.png"]
                                  foregroundImage:[[UIImage imageNamed:@"project_progress4.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5]
                                  backgroundImage:[[UIImage imageNamed:@"project_progress_bg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:4]];
    
    slider1.delegate = self;
    slider2.delegate = self;
    slider3.delegate = self;
    slider4.delegate = self;
    
    slider1.tag = 1;
    slider2.tag = 2;
    slider3.tag = 3;
    slider4.tag = 4;
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    FollowUpListViewController *fListVc = [[FollowUpListViewController alloc] init];
    [self.navigationController pushViewController:fListVc animated:YES];
}

#pragma mark - Data
- (void)getDataFromServerShowIndicator:(bool)on {
    if (on) {
        [SVProgressHUD showWithStatus:String_Loading];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];//,@(pageNoForServer),@"page"
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getHealthPlanListByUser.action" param:params onCompletion:^(id jsonResponse) {
        if (on) {
            [SVProgressHUD dismiss];
        }
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [dataSource addObjectsFromArray:[jsonResponse objectForKey:@"rows"]];
            
             NSLog(@"----+++++++++++++++++++++++++++++++%@",self->dataSource);
            
            [self updateForm];
        }
        else {
            if (on) {
                [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
            }
        }
        
        if (!isValidArray(dataSource)) {
//            [self showNoDataWithTips:@"1、健康计划是1020家庭医生为VIP会员制订的执行计划，各个计划内容由1020家庭医生家负责维护和更新。\n2、VIP会员点击其中的任一计划，可以查看计划的详细内容。\n 3、VIP会员需要每周日给自己打分（从左向右拖动彩色圆点即可），没有打分，系统即默认为没有执行。您的健康顾问、监护人会根据您的打分判断您的配合与执行情况。"];
            tbView.hidden = YES;
        }
        else {
            tbView.hidden = NO;
            [self showNoData:NO];
        }
    } onError:^(NSError *error) {
        if (on) {
            [SVProgressHUD dismiss];
        }
    } defaultErrorAlert:on isCacheNeeded:NO method:nil];
}

///提交进度
- (void)submitProgressWithContent:(NSDictionary*)content {
    if (pageNoForView-1 >= 0 && pageNoForView-1 < dataSource.count) {
        NSMutableDictionary *pInfo = [NSMutableDictionary dictionaryWithDictionary:[dataSource objectAtIndex:pageNoForView-1]];
        for (NSString *key in content.allKeys) {
            [pInfo setObject:[content objectForKey:key] forKeyedSubscript:key];
        }
        [dataSource replaceObjectAtIndex:pageNoForView-1 withObject:pInfo];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:content];
        [params setObject:[pInfo objectForKey:@"plan_id"] forKey:@"plan_id"];
//        [params setObject:[pInfo objectForKey:@"week_index"] forKey:@"week_index"];
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"user_id"];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"saveOrUpdateHealthPlanInfos.action" param:params onCompletion:^(id jsonResponse) {
            NSLog(@"%@",jsonResponse);
            if ([[jsonResponse valueForKey:@"status"] intValue] == 1) {
                [[THud sharedInstance] showtips:@"提交成功"];
            }else{
                [[THud sharedInstance] showtips:@"提交失败，请重试"];
            }
        } onError:^(NSError *error) {
//            [[THud sharedInstance] showtips:@"暂时无法连接到服务器"];
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"暂时无法连接到网络!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}
//更新视图数据
- (void)updateForm {
    if (pageNoForView < 1) {
        pageNoForView = 1;
        return;
    }
    if (pageNoForView > dataSource.count) {
        pageNoForView = dataSource.count > 1 ? dataSource.count : 1;
        return;
    }
    //设置翻页按钮
    btnNext.enabled = (pageNoForView > 1);
    btnPrevious.enabled = (pageNoForView < dataSource.count);
    //设置标题
    NSDictionary *pInfo = [dataSource objectAtIndex:pageNoForView-1];
    labelDate.text = [NSString stringWithFormat:@"%@/%@",getDateStringByCuttingTime([pInfo objectForKey:@"start_time"]),getDateStringByCuttingTime([pInfo objectForKey:@"end_time"])];
    labelWeek.text = [NSString stringWithFormat:@"第%@周",[pInfo objectForKey:@"week_index"]];
    //设置进度
    [self setProgress:[[pInfo objectForKey:@"medical_plan_ratio"] floatValue]/100.f ForSlider:slider1];
    [self setProgress:[[pInfo objectForKey:@"nutri_plan_ratio"] floatValue]/100.f ForSlider:slider2];
    [self setProgress:[[pInfo objectForKey:@"body_health_plan_ratio"] floatValue]/100.f ForSlider:slider3];
    [self setProgress:[[pInfo objectForKey:@"sport_plan_ratio"] floatValue]/100.f ForSlider:slider4];
}

- (NSString*)getDateStringCutTime:(NSString*)dString {
    if (!isValidString(dString)) {
        return nil;
    }
    NSArray *arr = [dString componentsSeparatedByString:@" "];
    return [arr firstObject];
}

- (void)setProgress:(float)percentage ForSlider:(MySliderView*)sliderTmp {
    sliderTmp.currentPercentage = percentage;
    NSArray *arr = @[labelPercentage1,labelPercentage2,labelPercentage3,labelPercentage4];
    NSString *strPercentage = [NSString stringWithFormat:@"%d%%",(int)(percentage*100)];
    UILabel *labelTmp = [arr objectAtIndex:sliderTmp.tag-1];
    labelTmp.text = strPercentage;
}

#pragma mark - Button Action
- (IBAction)commit:(UIButton *)sender {
    NSLog(@"nihao");
    [self submitProgressWithContent:dic];
}

- (IBAction)btnAction:(UIButton*)sender {
     NSLog(@"qqqqqqddddeeeeqqqqq");
    if (sender.tag == 100) {
        pageNoForView++;
        [self updateForm];
    }
    else if (sender.tag == 101) {
        pageNoForView--;
        [self updateForm];
    }
    else if (sender.tag == 200) {
        HeathyProjectChartViewController *hVc = [[HeathyProjectChartViewController alloc] init];
        [self.navigationController pushViewController:hVc animated:YES];
    }
}

- (IBAction)alertButton:(UIButton*)sender {
    if (sender.tag == 100) {
        //前一个
        [SVProgressHUD showErrorWithStatus:@"已是最早的记录！"];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"已是最近的记录！"];
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cArr = @[cell1,cell2,cell3,cell4,cell5,cell7,cell6];
    UITableViewCell *cell = [cArr objectAtIndex:indexPath.row];
    if (indexPath.row > 0) {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row > 0 && indexPath.row < 5) {
        NSArray *sArr = @[slider1,slider2,slider3,slider4];
        MySliderView *sv = [sArr objectAtIndex:indexPath.row-1];
        [cell.contentView addSubview:sv];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 44.f;
    }
    else if (indexPath.row == 5) {
        return 46.f;
    }else if (indexPath.row == 6 ){
         return 40.f;
    }
    else {
        return 89.f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    if (pageNoForView > dataSource.count) {
        return;
    }
//    NSDictionary *planInfo = [dataSource objectAtIndex:pageNoForView-1];
//    HeathyProjectDetailViewController *hVc = [[HeathyProjectDetailViewController alloc] init];
//    switch (indexPath.row) {
//        case 1://医疗
//            hVc.planContent = [planInfo objectForKey:@"medical_plan"];
//            break;
//        case 2://营养
//            hVc.planContent = [planInfo objectForKey:@"nutri_plan"];
//            break;
//        case 3://康复
//            hVc.planContent = [planInfo objectForKey:@"body_health_plan"];
//            break;
//        case 4://运动
//            hVc.planContent = [planInfo objectForKey:@"sport_plan"];
//            break;
//        default:
//            return;
//            break;
//    }
//    
//    [self.navigationController pushViewController:hVc animated:YES];
}

#pragma mark - MySliderView
- (void)mySliderView:(MySliderView*)mySliderView valueDidChange:(CGFloat)percentage {
    NSString *strPercentage = [NSString stringWithFormat:@"%d%%",(int)(mySliderView.currentPercentage*100)];
//    NSLog(@"%@-%f",strPercentage,mySliderView.currentPercentage);
    switch (mySliderView.tag) {
        case 1:
            //医疗
            labelPercentage1.text = strPercentage;
            break;
        case 2:
            //营养
            labelPercentage2.text = strPercentage;
            break;
        case 3:
            //康复
            labelPercentage3.text = strPercentage;
            break;
        case 4:
            //运动
            labelPercentage4.text = strPercentage;
            break;
        default:
            break;
    }
}

- (void)mySliderViewDidFinishDragging:(MySliderView*)mySliderView {
   
    NSInteger percentage = (int)(mySliderView.currentPercentage*100);
    
    switch (mySliderView.tag) {
        case 1:
            //医疗
            [dic setObject:@(percentage) forKey:@"medical_plan_ratio"];
            break;
        case 2:
            //营养
            [dic setObject:@(percentage) forKey:@"nutri_plan_ratio"];
            break;
        case 3:
            //康复
            [dic setObject:@(percentage) forKey:@"body_health_plan_ratio"];
            break;
        case 4:
            //运动
            [dic setObject:@(percentage) forKey:@"sport_plan_ratio"];
            break;
        default:
            break;
    }
}

@end
