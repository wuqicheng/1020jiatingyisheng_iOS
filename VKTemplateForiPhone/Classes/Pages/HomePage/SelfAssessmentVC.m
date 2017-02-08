//
//  SelfAssessmentVC.m
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/8/30.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import "SelfAssessmentVC.h"
#import "ValueVC.h"
#import "SegmentVC.h"
#import "MyAlertView.h"
#import "UserSessionCenter.h"

static CGFloat const ButtonHeight = 50;

@interface SelfAssessmentVC (){
    NSMutableArray *dataSource;
     NSInteger pageNoForView,pageNoForServer;
}


@end

@implementation SelfAssessmentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"健康计划";
    [self getDataFromServerShowIndicator:YES];
    // Do any additional setup after loading the view from its nib.
    SegmentVC *vc = [[SegmentVC alloc]init];
    NSArray *titleArray = @[@"营养计划", @"康复计划", @"医疗计划", @"运动计划"];
    vc.titleArray = titleArray;
    NSMutableArray *controlArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < vc.titleArray.count; i ++) {
        ValueVC *vc = [[ValueVC alloc]initWithIndex:i title:titleArray[i]];
        vc.view.tag = i;
        vc.pageNoForView = pageNoForView;
        [controlArray addObject:vc];
    }
    vc.titleSelectedColor = [UIColor colorWithRed:50.0/255.0 green:209.0/255.0 blue:104.0/255.0 alpha:1.0];
    vc.subViewControllers = controlArray;
    vc.buttonWidth = 80;
    vc.buttonHeight = ButtonHeight;
    [vc initSegment];
    [vc addParentController:self];
    [self.view addSubview:btn];
//     [self getDataFromServerShowIndicator:YES];
}

//-(void)initItems{
//    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
//    whiteView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:whiteView];
//    
//    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 99, [UIScreen mainScreen].bounds.size.width, 1)];
//    line.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0f];
//    [self.view addSubview:line];
//    
//    UILabel *startData = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 100, 30)];
//    startData.font = [UIFont systemFontOfSize:14];
//    startData.text = @"计划开始时间：";
//    startData.textColor  = [UIColor blackColor];
//    [whiteView addSubview:startData];
//    UILabel *finishData = [[UILabel alloc]initWithFrame:CGRectMake(20, 55, 100, 30)];
//    finishData.font = [UIFont systemFontOfSize:14];
//    finishData.text = @"计划完成时间：";
//    finishData.textColor  = [UIColor blackColor];
//    [whiteView addSubview:finishData];
//    
//    UILabel *startTime = [[UILabel alloc]initWithFrame:CGRectMake(110, 20, [UIScreen mainScreen].bounds.size.width-110-40, 20)];
//    startTime.font = [UIFont systemFontOfSize:12];
//    startTime.layer.cornerRadius = 5;
//    
//     NSLog(@"%@&^^&&^^&&*",[dataSource valueForKey:@"start_time"]);
//    startTime.text = [NSString stringWithFormat:@"  %@",[[dataSource valueForKey:@"start_time"] firstObject]];
//    
//    
//    
//    startTime.textColor  = [UIColor grayColor];
//    [whiteView addSubview:startTime];
//    UILabel *finishTime = [[UILabel alloc]initWithFrame:CGRectMake(110, 60, [UIScreen mainScreen].bounds.size.width-110-40, 20)];
//    finishTime.font = [UIFont systemFontOfSize:12];
//    finishTime.layer.cornerRadius = 5;
//    finishTime.text = [NSString stringWithFormat:@"  %@",[[dataSource valueForKey:@"end_time"] firstObject]];
//    finishTime.textColor  = [UIColor grayColor];
//    [whiteView addSubview:finishTime];
//}
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
    [self showNoData:NO];
    //    }
    
    pageNoForView = 1;
    pageNoForServer = 1;
    dataSource = [[NSMutableArray alloc] init];
    [self getDataFromServerShowIndicator:YES];
}

#pragma mark - Button Action
- (IBAction)btnAction1:(UIButton*)sender {
    if (sender.tag == 100) {
        pageNoForView++;
        [self updateForm];
    }
    else if (sender.tag == 101) {
        pageNoForView--;
        [self updateForm];
    }
//    else if (sender.tag == 200) {
//        HeathyProjectChartViewController *hVc = [[HeathyProjectChartViewController alloc] init];
//        [self.navigationController pushViewController:hVc animated:YES];
//    }
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
//更新视图数据
- (void)updateForm {
    [self.view addSubview:self.topView];
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
    NSLog(@"%@qqqqqqqqqqq",[pInfo objectForKey:@"week_index"]);
    
   [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_GetUserProfileSuccess" object:[pInfo objectForKey:@"week_index"] userInfo:nil];
}

- (void)updateForm:(NSInteger)index{
    [self updateForm];
}

- (IBAction)btnAction:(UIButton*)sender {
     MyAlertView *myAlert = [[MyAlertView alloc] initWithTitle:@"健康计划" alertContent:@"健康计划是1020家庭医生为购买相应服务会员改善健康善制订的提升计划，由后台医生负责维护和更新。会员需认真阅读并配合执行才能取得好的改善效果。" style:MyAlertViewStyleI_Know];
    [myAlert show];
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
        NSLog(@"----++++++++++++++&&&&&&+++++++++++++++++%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            dataSource = [[NSMutableArray alloc] init];
            [dataSource removeAllObjects];
            [dataSource addObjectsFromArray:[jsonResponse objectForKey:@"rows"]];
            
            NSLog(@"----++++++++++++222222+++++++++++++++++++%@",self->dataSource);
             [self updateForm];
        }
        else {
            if (on) {
                //                [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
            }
        }
        
        if (!isValidArray(dataSource)) {
            //            [self showNoDataWithTips:@"1、健康计划是1020家庭医生为VIP会员制订的执行计划，各个计划内容由1020家庭医生负责维护和更新。\n2、VIP会员点击其中的任一计划，可以查看计划的详细内容。\n 3、VIP会员需要每周日给自己打分（从左向右拖动彩色圆点即可），没有打分，系统即默认为没有执行。您的健康顾问、监护人会根据您的打分判断您的配合与执行情况。"];
            
        }
        else {
            
        }
    } onError:^(NSError *error) {
        if (on) {
            [SVProgressHUD dismiss];
        }
    } defaultErrorAlert:on isCacheNeeded:NO method:nil];
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
