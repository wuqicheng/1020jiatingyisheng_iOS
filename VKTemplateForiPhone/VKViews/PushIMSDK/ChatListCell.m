//
//  ChatListCell.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "ChatListCell.h"

@implementation ChatListCell


- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    imgvAvatar.layer.cornerRadius = imgvAvatar.frame.size.width / 2.f;
    [imgvAvatar setImageURLStr:[dataInfo objectForKey:@"photo"] placeholder:Defualt_Avatar_Image];
    btnState.enabled = ![[dataInfo objectForKey:@"chart_status"] boolValue];//会话状态  0 进行中  1结束
    labelName.text = [dataInfo objectForKey:@"user_name"];
    labelTime.text = getShortDateTimeForShow([dataInfo objectForKey:@"last_chart_date"]);
}

@end
