//
//  UserSessionCenter.h
//  BanJi
//
//  Created by Vescky on 14-8-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSessionCenter : NSObject {
    
}

+ (id)shareSession;

//用户详细信息
- (bool)saveAccountDetailInfo:(NSDictionary*)dict;
- (NSDictionary*)getAccountDetailInfo;
- (bool)destroyAccountDetailInfo;

///临时登陆
- (bool)saveTmpAccountDetailInfo:(NSDictionary*)dict;
- (NSDictionary*)getTmpAccountDetailInfo;
- (bool)destroyTmpAccountDetailInfo;

- (void)setIfIsTmpLogin:(bool)isTmp;
- (bool)isTmpLogin;

- (void)saveAccountName:(NSString*)aName;
- (NSString*)getAccountName;
- (bool)savePassword:(NSString*)pwd;
- (NSString*)getUserPassword;

- (void)setAutoFillAccountInfo:(bool)isAuto;
- (bool)isAutoFillAccountInfo;

- (bool)saveUserPushConfig:(bool)isOn;
- (bool)isPushConfigOn;

- (bool)setAutoLoginDisable:(bool)isOn;
- (bool)isAutoLoginDisable;

- (bool)saveUserCityInfo:(NSDictionary*)cityInfo;
- (NSDictionary*)getUserCityInfo;
- (NSString*)getUserCityId;

//定义一些便捷的getter
- (NSString*)getUserAccountName;
- (NSString*)getUserPhoneNumber;
- (NSString*)getUserNickName;
- (NSString*)getUserAvatar;
- (NSString*)getUserCode;//用户编码
- (NSString*)getUserId;
- (NSString*)getUserCost;//账户余额
- (NSString*)getUserScore;//积分
- (NSString*)getUserInviteCode;//获取邀请码

- (bool)isVip;
- (NSString*)getVipLevelId;
- (NSString*)getVipLevelName;
- (NSString*)getVipDays;

- (NSArray*)getUserCarList;//获取车辆列表--洗车
- (NSArray*)getUserInvoiceList;//获取发票抬头列表--洗车
- (NSArray*)getUserAddressList;//获取用户地址列表

//定义一些便捷的setter
- (bool)saveUserNickName:(NSString*)userName;
- (bool)saveUserAvatar:(NSString*)userAvatar;
- (bool)saveUserPhoneNumber:(NSString*)phoneNum;
- (bool)saveUserVipLevelId:(NSString*)vipId;
- (bool)saveUserVipLevelName:(NSString*)vipName;
- (bool)saveUserVipLevelDays:(NSString*)vipDays;

- (bool)saveUserCarList:(NSArray*)carList;
- (bool)saveUserInvoiceList:(NSArray*)invoiceList;
- (bool)saveUserAddressList:(NSArray*)addressList;


- (void)removeUserId;//做自动登录的时候用

@end
