//
//  DropdownMenuCell.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/4.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewCell.h"
#import "DropdownMenuListItem.h"

@interface DropdownMenuCell : AppsBaseTableViewCell {
    IBOutlet UIImageView *imgvIcon;
    IBOutlet UILabel *labelTitle;
}

- (void)setCellDataInfo:(DropdownMenuListItem *)cellItem;

@end
