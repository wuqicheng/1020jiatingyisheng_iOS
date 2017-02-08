//
//  DropdownMenuListItem.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/4.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DropdownMenuListItem : NSObject

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *iconLink;
@property (nonatomic,strong) UIImage *iconImage;
@property (nonatomic,strong) NSDictionary *ext;
@property bool isSelected;

@end
