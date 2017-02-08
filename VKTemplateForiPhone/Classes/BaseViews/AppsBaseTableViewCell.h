//
//  AppsBaseTableViewCell.h
//  aixiche
//
//  Created by vescky.luo on 14-10-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+MJWebCache.h"

@interface AppsBaseTableViewCell : UITableViewCell {
    IBOutlet UIImageView *imgvBg;
    UIImage *bgImage;
    NSDictionary *cellDataInfo;
}

///Should over-write this methor
+ (CGFloat)getCellHeightWithDataInfo:(NSDictionary*)dataInfo;

///Should over-write this methor
- (void)setCellDataInfo:(NSDictionary*)dataInfo;


@end
