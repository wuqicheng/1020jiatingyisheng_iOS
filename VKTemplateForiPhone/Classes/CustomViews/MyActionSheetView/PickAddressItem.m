//
//  PickAddressItem.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/3.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "PickAddressItem.h"

@implementation PickAddressItem
@synthesize provinceName,provinceId,cityName,cityId,districtName,districtId;

- (id)copyWithZone:(NSZone *)zone {
    PickAddressItem *copy = [[PickAddressItem alloc] init];
    if (copy) {
        copy.provinceId = self.provinceId;
        copy.provinceName = self.provinceName;
        copy.cityId = self.cityId;
        copy.cityName = self.cityName;
        copy.districtId = self.districtId;
        copy.districtName = self.districtName;
    }
    
    return copy;
}

@end
