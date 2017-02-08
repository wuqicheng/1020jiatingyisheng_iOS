//
//  FreeSearchResultCategoryCell.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/23.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "FreeSearchResultCategoryCell.h"

@implementation FreeSearchResultCategoryCell

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    _labelTitle.text = [dataInfo objectForKey:@"target_title"];
}


@end
