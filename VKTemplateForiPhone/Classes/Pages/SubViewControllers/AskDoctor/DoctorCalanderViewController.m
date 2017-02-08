//
//  DoctorCalanderViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DoctorCalanderViewController.h"

#import "WQCalendarLogic.h"
#import "WQDraggableCalendarView.h"
#import "WQScrollCalendarWrapperView.h"

@interface DoctorCalanderViewController () {
    //日历所需
    WQDraggableCalendarView *calendarView;
    WQCalendarLogic *calendarLogic;
    NSMutableArray *monthData;
}

@end

@implementation DoctorCalanderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"出诊时间";
    [self customBackButton];
    monthData = [[NSMutableArray alloc] init];
    labelMonth.text = getStringFromDate(@"yyyy-MM", [NSDate date]);
    [self initCalanderView];
    
//    [self getValidTimeString:@[@1,@2,@4,@6,@8,@9,@10,@18,@19,@20]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshCalendarData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarDidSelectDay) name:@"WQCalendarTileViewRefreshDate" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data
- (void)refreshCalendarData {
    NSString* selectedDate = getStringFromDate(@"yyyy-MM-dd", [calendarLogic.selectedCalendarDay date]);
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[self.doctorInfo objectForKey:@"user_id"],@"user_id",selectedDate,@"day", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getCurDayVisitTimeByUser.action" param:params onCompletion:^(id jsonResponse) {
//        if (isValidArray([jsonResponse objectForKey:@"rows"])) {
//            monthData = [[NSMutableArray alloc] initWithArray:[jsonResponse objectForKey:@"rows"]];
//        }
        if (isValidString([jsonResponse objectForKey:@"day_time"])) {
            NSArray *times = [[jsonResponse objectForKey:@"day_time"] componentsSeparatedByString:@","];
            labelTime.text = [self getValidTimeString:times];
            NSLog(@"%@",times);
        }
        else {
            labelTime.text = @"暂无";
        }
    } onError:^(NSError *error) {
        
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

//- (void)fillSelectedDay {
//    if (!isValidArray(monthData)) {
//        return;
//    }
//    NSString* selectedDate = getStringFromDate(@"yyyy-MM-dd", [calendarLogic.selectedCalendarDay date]);
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"day CONTAINS %@", selectedDate];
//    NSArray *result = [monthData filteredArrayUsingPredicate:predicate];
//    
//}


///传入纯数字的数组，自动计算好：几点至几点
- (NSString*)getValidTimeString:(NSArray*)arr {
    NSMutableArray *segmentArr = [[NSMutableArray alloc] init];
    if (arr.count > 1) {
        for (int i = 0; i < arr.count; i++) {
            NSMutableArray *segTmp = [[NSMutableArray alloc] initWithObjects:[arr objectAtIndex:i], nil];
            //遍历是否有连续的时间
            for (int j = i+1; j < arr.count; j++) {
                NSInteger num1 = [[arr objectAtIndex:j-1] integerValue];
                NSInteger num2 = [[arr objectAtIndex:j] integerValue];
                if (num2 - num1 == 1) {
                    [segTmp addObject:@(num2)];
                }
                else {
                    [segmentArr addObject:segTmp];
                    i = j-1;
                    break;
                }
                
                if (j >= arr.count-1) {
                    [segmentArr addObject:segTmp];
                    i = j;
                    break;
                }
            }
        }
    }
    else {
        [segmentArr addObject:arr];
    }
    
    NSString *resultStr = @"";
    for (int i = 0; i < segmentArr.count; i++) {
        NSArray *segTmp = [segmentArr objectAtIndex:i];
        NSInteger startIndex = [[segTmp firstObject] integerValue];
        NSInteger endIndex = [[segTmp lastObject] integerValue] + 1;
        NSString *segStr = [NSString stringWithFormat:@"%2d:00至%2d:00",startIndex,endIndex];
        if (i == 0) {
            //第一个
            resultStr = [resultStr stringByAppendingFormat:@"%@",segStr];
        }
        else {
            resultStr = [resultStr stringByAppendingFormat:@"、%@",segStr];
        }
    }
    
    NSLog(@"%@",resultStr);
    return resultStr;
}

- (void)calendarDidSelectDay {
    NSString* selectedDate = getStringFromDate(@"yyyy-MM-dd", [calendarLogic.selectedCalendarDay date]);
    NSLog(@"%@",selectedDate);
    [self refreshCalendarData];
}

#pragma mark - Button Action
- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == 100) {
        //previous
        [calendarLogic goToPreviousMonthInCalendarView:calendarView];
    }
    else {
        //next
        [calendarLogic goToNextMonthInCalendarView:calendarView];
    }
    
    labelMonth.text = getStringFromDate(@"yyyy-MM", [calendarLogic.selectedCalendarDay date]);
}

#pragma mark -
- (void)initCalanderView {
    calendarLogic = [[WQCalendarLogic alloc] init];
    
    CGRect calendarRect = cellCalendar.bounds;
    calendarRect.origin.y += 50, calendarRect.size.height -= 50;
    calendarView = [[WQDraggableCalendarView alloc] initWithFrame:calendarRect];
    calendarView.draggble = YES;
    [cellCalendar addSubview:calendarView];
    calendarView.backgroundColor = [UIColor colorWithRed:237/255.0f green:236/255.0f blue:234/255.0f alpha:1.0f];
    [calendarLogic reloadCalendarView:calendarView];
}

#pragma mark - UItableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *cells = @[cellCalendar,cell1,cell2];
    UITableViewCell *cell = [cells objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cells = @[cellCalendar,cell1,cell2];
    UITableViewCell *cell = [cells objectAtIndex:indexPath.row];
    return cell.frame.size.height;
}


@end
