//
//  MedicalReportCell.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "MedicalReportCell.h"

@implementation MedicalReportCell

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    labelTitle.text = [dataInfo objectForKey:@"record_title"] ? [dataInfo objectForKey:@"record_title"] : [dataInfo objectForKey:@"active_theme"];
    labelTime.text = getShortDateTimeForShow([dataInfo objectForKey:@"create_date"]);
}


@end
