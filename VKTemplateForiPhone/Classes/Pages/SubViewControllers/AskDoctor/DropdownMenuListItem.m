//
//  DropdownMenuListItem.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/4.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DropdownMenuListItem.h"

@implementation DropdownMenuListItem
@synthesize title,iconImage,iconLink,ext,isSelected;

- (id)copyWithZone:(NSZone *)zone {
    DropdownMenuListItem *copy = [[DropdownMenuListItem alloc] init];
    if (copy) {
        copy.title = self.title;
        copy.iconLink = self.iconLink;
        copy.iconImage = self.iconImage;
        copy.ext = self.ext;
    }
    
    return copy;
}

@end
