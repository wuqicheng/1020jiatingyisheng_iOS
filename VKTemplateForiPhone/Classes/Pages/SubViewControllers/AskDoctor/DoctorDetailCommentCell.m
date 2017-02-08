//
//  DoctorDetailCommentCell.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/19.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DoctorDetailCommentCell.h"

@implementation DoctorDetailCommentCell

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    labelContent.text = [NSString stringWithFormat:@"%@：%@",[self encodeUserNick:[dataInfo objectForKey:@"user_nick"]],[dataInfo objectForKey:@"comment_msg"]];
    labelTime.text = getShortDateTimeForShow([dataInfo objectForKey:@"comment_date"]);
}

- (NSString*)encodeUserNick:(NSString*)uNick {
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    [resultStr appendString:[uNick substringToIndex:1]];
    for (int i = 1; i < uNick.length; i++) {
        [resultStr appendString:@"*"];
    }
    
    return resultStr;
}


@end
