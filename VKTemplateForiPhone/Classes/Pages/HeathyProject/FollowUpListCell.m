//
//  FollowUpListCell.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "FollowUpListCell.h"

@implementation FollowUpListCell

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    labelName.text = [dataInfo objectForKey:@"visit_theme"];
    labelTime.text = getShortDateTimeForShow([dataInfo objectForKey:@"last_update_date"]);
}


@end
