//
//  RelationShipCell.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "RelationShipCell.h"

@implementation RelationShipCell

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    imgvAvatar.layer.cornerRadius = imgvAvatar.frame.size.width / 2.f;
    [imgvAvatar setImageURLStr:[dataInfo objectForKey:@"photo"] placeholder:Defualt_Avatar_Image];
    labelName.text = [dataInfo objectForKey:@"user_nick"];
}

- (IBAction)btnAction:(UIButton*)sender  {
    NSLog(@"button action");
    if ([self.delegate respondsToSelector:@selector(relationShipCell:buttonDidClickAtIndexPath:)]) {
        [self.delegate relationShipCell:self buttonDidClickAtIndexPath:self.indexPath];
    }
}

@end
