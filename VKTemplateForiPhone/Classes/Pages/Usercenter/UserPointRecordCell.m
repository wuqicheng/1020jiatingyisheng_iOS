//
//  UserPointRecordCell.m
//  VKTemplateForiPhone
//
//  Created by Vescky on 15/3/2.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "UserPointRecordCell.h"

@implementation UserPointRecordCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    [super setCellDataInfo:dataInfo];
    
    labelDesc.text = getString([dataInfo objectForKey:@"consume_title"]);
    labelScore.text = [NSString stringWithFormat:@"-￥%@",[dataInfo objectForKey:@"fee"]];
    labelDate.text = getShortDateTimeForShow([dataInfo objectForKey:@"create_date"]);
    
}

@end
