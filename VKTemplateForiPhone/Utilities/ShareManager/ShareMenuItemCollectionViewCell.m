//
//  ShareMenuItemCollectionViewCell.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/26.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "ShareMenuItemCollectionViewCell.h"

@implementation ShareMenuItemCollectionViewCell
@synthesize img = _img,title = _title;

//- (void)awakeFromNib {
//    // Initialization code
//}

- (void)setImg:(UIImage *)img {
    _img = img;
    [imgv setImage:img];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    labelTitle.text = title;
}

@end
