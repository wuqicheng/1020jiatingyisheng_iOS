//
//  PickAddressActionSheetView.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/3.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseView.h"
#import "PickAddressItem.h"

////定义一个地址数据类
//@interface AddressItem : NSObject
//
//@property (nonatomic,strong) NSString *provinceName;
//@property (nonatomic,strong) NSString *provinceId;
//@property (nonatomic,strong) NSString *cityName;
//@property (nonatomic,strong) NSString *cityId;
//@property (nonatomic,strong) NSString *districtName;
//@property (nonatomic,strong) NSString *districtId;
//
//@end
//
//@implementation AddressItem
//@synthesize provinceName,provinceId,cityName,cityId,districtName,districtId;
//
//- (id)copyWithZone:(NSZone *)zone {
//    AddressItem *copy = [[AddressItem alloc] init];
//    if (copy) {
//        copy.provinceId = self.provinceId;
//        copy.provinceName = self.provinceName;
//        copy.cityId = self.cityId;
//        copy.cityName = self.cityName;
//        copy.districtId = self.districtId;
//        copy.districtName = self.districtName;
//    }
//    
//    return copy;
//}
//
//@end

@protocol PickAddressActionSheetViewDelegate;
@interface PickAddressActionSheetView : AppsBaseView<UIPickerViewDataSource,UIPickerViewDelegate> {
    UIPickerView *aPickerView;
    UIView *pickerContainer;
}

typedef NS_ENUM(NSInteger, PickAddressActionSheetViewType) {
    PickAddressActionSheetViewTypeDefault = 0,//省-市-区
    PickAddressActionSheetViewTypeProvinceAndCity,//省-市
    PickAddressActionSheetViewTypeCityAndDistrict,//市-区
};

@property (nonatomic,assign) id <PickAddressActionSheetViewDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *provinces,*cities,*districts;
@property (nonatomic,strong) PickAddressItem *selectedAddress;

- (instancetype)initWithTitle:(NSString*)pTitle pickerType:(PickAddressActionSheetViewType)type;
- (void)show;
- (void)dismiss;

@end


@protocol PickAddressActionSheetViewDelegate <NSObject>

- (void)pickAddressActionSheetView:(PickAddressActionSheetView*)pv didSelectAddress:(PickAddressItem*)address;

@end