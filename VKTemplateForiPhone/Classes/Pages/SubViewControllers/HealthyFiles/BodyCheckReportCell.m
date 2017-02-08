//
//  BodyCheckReportCell.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "BodyCheckReportCell.h"

@implementation BodyCheckReportCell

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    labelTitle.text = [dataInfo objectForKey:@"report_name"];
    labelDate.text = getDateStringByCuttingTime([dataInfo objectForKey:@"last_update_date"]);
}

@end
