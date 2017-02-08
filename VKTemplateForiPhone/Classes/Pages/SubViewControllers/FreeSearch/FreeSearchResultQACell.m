//
//  FreeSearchResultQACell.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/23.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "FreeSearchResultQACell.h"

@implementation FreeSearchResultQACell

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    NSString *titleStr = [NSString stringWithFormat:@"%@",[dataInfo objectForKey:@"quest_title"]];
    labelQuestion.text = titleStr;
    CGRect rect = labelQuestion.frame;
    rect.size.height =  getTextHeight(labelQuestion.text, labelQuestion.font, labelQuestion.width);
    labelQuestion.frame = rect;
    labelQuestion.numberOfLines = 0;
   
    imgvTitle.center = CGPointMake(imgvTitle.center.x, labelQuestion.center.y);
    
    setViewFrameOriginY(labelAnswer, CGRectGetMaxY(labelQuestion.frame));
    labelAnswer.text = removeHtmlTags([dataInfo objectForKey:@"quest_desc"]);
    labelAnswer.numberOfLines = 2;
    CGFloat OneRowHeight = getTextHeight(labelAnswer.text, labelAnswer.font, 99999.0f);
    NSInteger rowNum = ceilf(getTextHeight(labelAnswer.text, labelAnswer.font, labelAnswer.width) / OneRowHeight);
    rect = labelAnswer.frame;
    rect.size.height = rowNum > 2 ? OneRowHeight*2 : OneRowHeight*rowNum;
    labelAnswer.frame = rect;
    setViewFrameSizeHeight(self, CGRectGetMaxY(labelAnswer.frame)+ 10);
}

- (float)getCellHeight:(NSDictionary*)data {
    [self setCellDataInfo:data];
    return self.frame.size.height;
}

@end
