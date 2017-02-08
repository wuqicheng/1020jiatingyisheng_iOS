//
//  UserCollectionCell1.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/23.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "UserCollectionCell1.h"

@implementation UserCollectionCell1

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    [self setOnlineStatus:[[dataInfo objectForKey:@"work_status"] boolValue]];
    [self setPhoneChatStatus:[[dataInfo objectForKey:@"phone_line"] boolValue]];
    labelName.text = [dataInfo objectForKey:@"user_name"];
    labelTime.text = getShortDateTimeForShow([dataInfo objectForKey:@"create_date"]);
    labelContent.text = [dataInfo objectForKey:@"doctor_subject"];
    [imgvAvatar setImageURLStr:[dataInfo objectForKey:@"photo"] placeholder:Defualt_Avatar_Image];
    imgvAvatar.layer.cornerRadius = imgvAvatar.frame.size.width/2.f;
    imgvAvatar.clipsToBounds = YES;
}

- (void)setOnlineStatus:(bool)isOnline {
    if (!isOnline) {
        labelName.textColor = GetColorWithRGB(204, 204, 204);
        labelContent.textColor = GetColorWithRGB(204, 204, 204);
        imgvStatus.hidden = YES;
    }
}

-(void)setPhoneChatStatus:(bool)isOnline
{
    if (!isOnline) {
        phoneStatus.hidden = YES;
    }
}


@end
