//
//  AppsBaseTableViewCell.m
//  aixiche
//
//  Created by vescky.luo on 14-10-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "AppsBaseTableViewCell.h"

@implementation AppsBaseTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self showHighlishted:selected];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self showHighlishted:highlighted];
}

- (void)showHighlishted:(bool)highlighted {
    if (highlighted) {
        bgImage = imgvBg.image;
        [imgvBg setImage:nil];
        imgvBg.backgroundColor = GetColorWithRGB(180, 180, 180);
    }
    else {
        [imgvBg setImage:bgImage];
        imgvBg.backgroundColor = [UIColor clearColor];
    }
}

- (void)setCellDataInfo:(NSDictionary*)dataInfo {
    //overwrite this methor
    cellDataInfo = dataInfo;
}

+ (CGFloat)getCellHeightWithDataInfo:(NSDictionary*)dataInfo {
    //overwrite this methor
    return 44.f;
}

@end
