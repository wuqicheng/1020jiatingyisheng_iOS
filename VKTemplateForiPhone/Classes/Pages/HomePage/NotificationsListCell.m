//
//  NotificationsListCell.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "NotificationsListCell.h"

@implementation NotificationsListCell

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    labelTitle.text = [dataInfo objectForKey:@"push_title"];
    labelTime.text = getShortDateTimeForShow([dataInfo objectForKey:@"create_date"]);
}

@end
