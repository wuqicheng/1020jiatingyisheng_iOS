//
//  TimeTableActionSheet.m
//  VKTemplateForiPhone
//
//  Created by Vescky on 15/2/13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "TimeTableActionSheet.h"

#define TimeTableActionSheet_Background  999
#define TimeTableActionSheet_Button_Yes  998
#define TimeTableActionSheet_Button_No   997
#define TimeTableActionSheet_Button_Prev 996
#define TimeTableActionSheet_Button_Next 995
#define TimeTableActionSheet_Cell        800
#define TimeTableActionSheet_Cell_Invalid 799
#define ENABLE_BACKGROUND_ACTION NO

@implementation TimeTableActionSheet
@synthesize delegate;

- (instancetype)initWithDataSource:(NSArray*)dataSource {
    self = [self initWithFrame:CGRectMake(0, 0, [AppKeyWindow bounds].size.width, [AppKeyWindow bounds].size.height)];
    if (self) {
        [self setupPicker:dataSource];
    }
    return self;
}

- (instancetype)initWithDataSource:(NSArray*)dataSource duration:(NSInteger)d {
    self = [self initWithDataSource:dataSource];
    timeDuration = d;
    return self;
}

- (void)show {
    setViewFrameOriginY(mainContainer, self.frame.size.height);
    [self refreshGridViewStatus];
    [AppKeyWindow addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        setViewFrameOriginY(mainContainer, self.frame.size.height - mainContainer.frame.size.height);
    }];
    
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        setViewFrameOriginY(mainContainer, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)setupPicker:(NSArray*)dataSource {
    selectedDayIndex = 0;
    selectedTimeIndex = -1;
    if (!timeDuration) {
        timeDuration = 1;
    }
    dayArray = PRESET_DAY_ARRAY;
    dataSourceForTimeTable = dataSource;
    
    self.backgroundColor = [UIColor clearColor];
    
    //make a mask-view
    UIView *viewMask = [[UIView alloc] initWithFrame:[AppKeyWindow bounds]];
    viewMask.backgroundColor = [UIColor blackColor];
    viewMask.alpha = 0.6;
    [self addSubview:viewMask];
    
    if (ENABLE_BACKGROUND_ACTION) {
        //make up background responder
        UIButton *btnBackground = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBackground.backgroundColor = [UIColor clearColor];
        btnBackground.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        btnBackground.tag = TimeTableActionSheet_Background;
        [btnBackground addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnBackground];
    }
    
    CGFloat margin = 10.f;
    CGFloat contentWidth = self.frame.size.width-2*margin;
    UIColor *bgColor = GetColorWithRGB(245, 245, 245);
    
    //make up top-bar，放进grid-view里面
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, contentWidth, 44.f)];
    topBar.backgroundColor = bgColor;
    
    btnPre = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPre.frame = CGRectMake(2*margin, 0.f, 120.f, topBar.frame.size.height);
    btnPre.tag = TimeTableActionSheet_Button_Prev;
    [btnPre setImage:[UIImage imageNamed:@"time_table_btn_pre.png"] forState:UIControlStateNormal];
    [btnPre addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btnPre.enabled = NO;
    [topBar addSubview:btnPre];
    
    labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(topBar.frame.size.width / 2.f - 30.f, 0, 60.f, topBar.frame.size.height)];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.textColor = [UIColor blackColor];
    labelTitle.font = [UIFont systemFontOfSize:17.0];
    labelTitle.text = [dayArray objectAtIndex:selectedDayIndex];
    [topBar addSubview:labelTitle];
    
    btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNext.frame = CGRectMake(topBar.frame.size.width - 2*margin - 120.f, 0.f, 120.f, topBar.frame.size.height);
    btnNext.tag = TimeTableActionSheet_Button_Next;
    [btnNext setImage:[UIImage imageNamed:@"time_table_btn_next.png"] forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btnNext];
    
    //makeup grid-view
    float gridCellHeight = 44.0f,gridCellWidth = contentWidth/4.0;
    gridView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, contentWidth, 6*gridCellHeight+topBar.frame.size.height)];
    [gridView addSubview:topBar];
    
    gridView.backgroundColor = bgColor;
    gridView.layer.cornerRadius = 5.0;
    gridView.clipsToBounds = YES;
    for (NSInteger i = 0; i <= 23; i++) {
        NSInteger row = i/4;
        NSInteger col = i%4;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(gridCellWidth*col, gridCellHeight*row+topBar.frame.size.height, gridCellWidth, gridCellHeight);
        [gridView addSubview:btn];
        
        btn.tag = TimeTableActionSheet_Cell + i;
        btn.layer.borderWidth = 0.5f;
        btn.layer.borderColor = GetColorWithRGB(223, 223, 223).CGColor;
        [btn setTitle:[NSString stringWithFormat:@"%@:00",@(i)] forState:UIControlStateNormal];
        
        //text color
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn setTitleColor:GetColorWithRGB(167, 167, 167) forState:UIControlStateDisabled];
        [btn setBackgroundImage:[UIImage imageNamed:@"time_table_bg_selected.png"] forState:UIControlStateSelected];
        
        //action
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //make up bottom bar
    CGFloat bottomBarHeight = 2 * 45.0f;
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(margin, gridView.frame.origin.y + gridView.frame.size.height + margin, contentWidth, bottomBarHeight)];
    bottomBar.backgroundColor = bgColor;
    bottomBar.layer.cornerRadius = 5.0;
    
    UIButton *btnSure,*btnCancel;
    btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:GetColorWithRGB(125, 125, 125) forState:UIControlStateNormal];
    btnCancel.frame = CGRectMake(0.0f, 45.0f+5.0f, bottomBar.frame.size.width, 45.0f);
    [btnCancel addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btnCancel.tag = TimeTableActionSheet_Button_No;
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [bottomBar addSubview:btnCancel];
    
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0.f, btnCancel.frame.size.height, bottomBar.frame.size.width, 1.f)];
    viewLine.backgroundColor = GetColorWithRGB(180, 180, 180);
    [bottomBar addSubview:viewLine];
    
    btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSure setTitle:@"确定" forState:UIControlStateNormal];
    [btnSure setTitleColor:GetColorWithRGB(48, 151, 226) forState:UIControlStateNormal];
    btnSure.frame = CGRectMake(0.0f, 5.0f, bottomBar.frame.size.width, 45.0f);
    [btnSure addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btnSure.tag = TimeTableActionSheet_Button_Yes;
    btnSure.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [bottomBar addSubview:btnSure];
    
    //main-container
    CGFloat mainContainerH = bottomBar.frame.origin.y + bottomBar.frame.size.height + margin;
    CGFloat mainContainerY = self.frame.size.height - mainContainerH;
    mainContainer = [[UIView alloc] initWithFrame:CGRectMake(0, mainContainerY, self.frame.size.width, mainContainerH)];
    mainContainer.backgroundColor = [UIColor clearColor];
    
    [mainContainer addSubview:gridView];
    [mainContainer addSubview:bottomBar];
    
    [self addSubview:mainContainer];
}

- (void)refreshTopbarStatus {
    if (selectedDayIndex < 0 || selectedDayIndex >= dayArray.count) {
        selectedDayIndex = 0;
    }
    if (selectedDayIndex == 0) {
        [btnPre setEnabled:NO];
    }
    else if (selectedDayIndex == dayArray.count-1) {
        [btnNext setEnabled:NO];
    }
    else {
        [btnPre setEnabled:YES];
        [btnNext setEnabled:YES];
    }
    labelTitle.text = [dayArray objectAtIndex:selectedDayIndex];
    [self refreshGridViewStatus];
}

- (void)refreshGridViewStatus {
    NSArray *timeArr = [dataSourceForTimeTable objectAtIndex:selectedDayIndex];
    if (!timeArr) {
        return;
    }
    NSInteger ct = [getStringFromDate(@"HH", [NSDate date]) integerValue];//获取当前几点
    for (NSInteger i = 0; i < 24; i++) {
        UIButton *btnTmp = (UIButton*)[gridView viewWithTag:TimeTableActionSheet_Cell+i];
        if (selectedDayIndex == 0 && i <= ct) {
//            btnTmp.enabled = NO;
            //早于当前时间
            [btnTmp setTitleColor:GetColorWithRGB(167, 167, 167) forState:UIControlStateNormal];
            btnTmp.tag = TimeTableActionSheet_Cell_Invalid;
            continue;
        }
//        if (i < timeArr.count && [btnTmp respondsToSelector:@selector(setEnabled:)]) {
//            btnTmp.enabled = ![[timeArr objectAtIndex:i] boolValue];
//        }
        if (i < timeArr.count) {
            if ([[timeArr objectAtIndex:i] boolValue]) {
                //已选就不能再选了
                [btnTmp setTitleColor:GetColorWithRGB(167, 167, 167) forState:UIControlStateNormal];
                btnTmp.tag = TimeTableActionSheet_Cell_Invalid;
            }
        }
    }
}

- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == TimeTableActionSheet_Background) {
        
    }
    else if (sender.tag == TimeTableActionSheet_Button_Yes) {
        if (selectedTimeIndex > 1) {
            if ([delegate respondsToSelector:@selector(btnDidFinishSelect:dayIndex:timeIndex:)]) {
                [delegate btnDidFinishSelect:self dayIndex:selectedDayIndex timeIndex:selectedTimeIndex];
            }
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"请选择时间"];
            return;
        }
    }
    else if (sender.tag == TimeTableActionSheet_Button_No) {
        NSLog(@"no..");
    }
    else if (sender.tag == TimeTableActionSheet_Button_Prev) {
        selectedDayIndex--;
        [self refreshTopbarStatus];
    }
    else if (sender.tag == TimeTableActionSheet_Button_Next) {
        selectedDayIndex++;
        [self refreshTopbarStatus];
    }
    else {
        //选了时间点
        if (sender.tag == TimeTableActionSheet_Cell_Invalid) {
            //无效时间
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"当前时间已有预约，请选择黑色的时间点" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        selectedTimeIndex = sender.tag - TimeTableActionSheet_Cell;
        sender.selected = !sender.selected;
        if (!sender.selected) {
            selectedTimeIndex = -1;
        }
        else {
            for (NSInteger i = 0; i < 24; i++) {
                UIButton *btnTmp = (UIButton*)[gridView viewWithTag:TimeTableActionSheet_Cell+i];
                if (btnTmp.selected && btnTmp.tag != TimeTableActionSheet_Cell+selectedTimeIndex) {
                    btnTmp.selected = NO;
                }
            }
        }
    }
    
    if (sender.tag == TimeTableActionSheet_Background || sender.tag == TimeTableActionSheet_Button_No || sender.tag == TimeTableActionSheet_Button_Yes) {
        [self dismiss];
    }
}

@end
