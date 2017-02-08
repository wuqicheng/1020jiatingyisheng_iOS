//
//  DropdownMenuCell.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/4.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DropdownMenuCell.h"
#import "UIImageView+MJWebCache.h"

@implementation DropdownMenuCell

- (void)setCellDataInfo:(DropdownMenuListItem *)cellItem {
    labelTitle.text = cellItem.title;
    if (isValidString(cellItem.iconLink)) {
        [imgvIcon setImageURLStr:cellItem.iconLink placeholder:nil];
    }
    else if (cellItem.iconImage) {
        [imgvIcon setImage:cellItem.iconImage];
    }
}

@end
