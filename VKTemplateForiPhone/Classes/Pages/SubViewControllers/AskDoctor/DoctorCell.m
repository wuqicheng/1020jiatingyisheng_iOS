//
//  DoctorCell.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/5.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DoctorCell.h"

@implementation DoctorCell

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    NSLog(@"%@",dataInfo);
    [self setOnlineStatus:[[dataInfo objectForKey:@"work_status"] boolValue]];
    [self setPhoneChatStatus:[[dataInfo objectForKey:@"phone_line"] boolValue]];
    labelName.text = [dataInfo objectForKey:@"user_name"];
    labelContent.text = [dataInfo objectForKey:@"doctor_subject"];
//    labelContent.text = @"医生专长";
    [imgvAvatar setImageURLStr:[dataInfo objectForKey:@"photo"] placeholder:Defualt_Avatar_Image];
    imgvAvatar.layer.cornerRadius = imgvAvatar.frame.size.width / 2.f;
}

- (void)setOnlineStatus:(bool)isOnline {
    if (!isOnline) {
        labelName.textColor = GetColorWithRGB(204, 204, 204);
        labelContent.textColor = GetColorWithRGB(204, 204, 204);
        imgvStatus.hidden = YES;
        yuyue.hidden = YES;
    }
    
}

-(void)setPhoneChatStatus:(bool)isOnline
{
    if (!isOnline) {
        phoneStatus.hidden = YES;
        
    }
}
@end
