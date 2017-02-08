//
//  TimeTableActionSheet.h
//  VKTemplateForiPhone
//
//  Created by Vescky on 15/2/13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseView.h"

@protocol TimeTableActionSheetDelegate;

@interface TimeTableActionSheet : AppsBaseView {
    UIView *mainContainer,*gridView;;
    UILabel *labelTitle;
    NSArray *dayArray,*dataSourceForTimeTable;
    NSInteger selectedDayIndex,selectedTimeIndex,timeDuration;
    UIButton *btnPre,*btnNext;
}

@property (nonatomic,assign) id <TimeTableActionSheetDelegate> delegate;

- (instancetype)initWithDataSource:(NSArray*)dataSource;
- (instancetype)initWithDataSource:(NSArray*)dataSource duration:(NSInteger)d;
- (void)show;
- (void)dismiss;

@end

@protocol TimeTableActionSheetDelegate <NSObject>

- (void)btnDidClick:(TimeTableActionSheet*)ttas atIndex:(int)buttonIndex;
- (void)btnDidFinishSelect:(TimeTableActionSheet*)ttas dayIndex:(NSInteger)di timeIndex:(NSInteger)ti;

@end
