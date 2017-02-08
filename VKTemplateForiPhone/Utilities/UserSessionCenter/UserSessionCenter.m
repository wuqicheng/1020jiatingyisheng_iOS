//
//  UserSessionCenter.m
//  BanJi
//
//  Created by Vescky on 14-8-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "UserSessionCenter.h"

@implementation UserSessionCenter

static UserSessionCenter *defaultUserSession;

+ (id)shareSession {
    if (!defaultUserSession) {
        defaultUserSession = [[UserSessionCenter alloc] init];
    }
    return defaultUserSession;
}

#pragma mark - Private -- 定义储存的基本方法
- (bool)saveObject:(id)obj forKey:(NSString*)key {
    if (!obj || !key) {
        return NO;
    }
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [usd setObject:data forKey:key];
    [usd synchronize];
    return YES;
}

- (id)getObjectForKey:(NSString*)key {
    if (!key) {
        return nil;
    }
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[NSKeyedUnarchiver unarchiveObjectWithData:[usd objectForKey:key]]);
    return [NSKeyedUnarchiver unarchiveObjectWithData:[usd objectForKey:key]];
}

- (bool)removeObjectForKey:(NSString*)key {
    if (!key) {
        return NO;
    }
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    [usd removeObjectForKey:key];
    [usd synchronize];
    return YES;
}

#pragma mark - Public -- 定义储存的拓展方法
- (bool)saveAccountDetailInfo:(NSDictionary*)dict {
    if ([self isTmpLogin]) {
        return [self saveTmpAccountDetailInfo:dict];
    }
    else {
        return [self saveObject:dict forKey:@"account_detail_info"];
    }
    
}

- (NSDictionary*)getAccountDetailInfo {
    if ([self isTmpLogin]) {
        return [self getTmpAccountDetailInfo];
    }
    else {
        return [self getObjectForKey:@"account_detail_info"];
    }
}

- (bool)destroyAccountDetailInfo {
    ///摧毁临时登陆信息
    [self destroyTmpAccountDetailInfo];
    return [self removeObjectForKey:@"account_detail_info"];
}

///临时登陆
- (bool)saveTmpAccountDetailInfo:(NSDictionary*)dict {
    return [self saveObject:dict forKey:@"tmp_account_detail_info"];
}
- (NSDictionary*)getTmpAccountDetailInfo {
    return [self getObjectForKey:@"tmp_account_detail_info"];
}
- (bool)destroyTmpAccountDetailInfo {
    return [self removeObjectForKey:@"tmp_account_detail_info"];
}

- (void)setIfIsTmpLogin:(bool)isTmp {
    [self saveObject:@(isTmp) forKey:@"is_tmp_login"];
}
- (bool)isTmpLogin {
    return [[self getObjectForKey:@"is_tmp_login"] boolValue];
}

///更改单个字段的值
- (bool)setObjectForAccountDetailInfo:(id)obj withKey:(NSString*)key {
    if (!obj) {
        return NO;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[self getAccountDetailInfo]];
    [dic setObject:obj forKey:key];
    [self saveAccountDetailInfo:dic];
    return YES;
}

#pragma mark - 账号和密码的存储
- (void)saveAccountName:(NSString*)aName {
    [self saveObject:aName forKey:@"user_drow_account"];
}
- (NSString*)getAccountName {
    return [self getObjectForKey:@"user_drow_account"];
}
- (bool)savePassword:(NSString*)pwd {
    return [self saveObject:pwd forKey:@"user_drow_ssap"];
}
- (NSString*)getUserPassword {
    return [self getObjectForKey:@"user_drow_ssap"];
}

#pragma mark - AutoFill
- (void)setAutoFillAccountInfo:(bool)isAuto {
    [self saveObject:@(isAuto) forKey:@"auto_fill_account_info"];
}
- (bool)isAutoFillAccountInfo {
    return [[self getObjectForKey:@"auto_fill_account_info"] boolValue];
}

#pragma mark - Push Config
- (bool)saveUserPushConfig:(bool)isOn {
    return [self saveObject:[NSNumber numberWithInt:isOn] forKey:@"user_push_config_is_on"];
}
- (bool)isPushConfigOn {
    return [[self getObjectForKey:@"user_push_config_is_on"] boolValue];
}

#pragma mark - AutoLogin
- (bool)setAutoLoginDisable:(bool)isOn {
    return [self saveObject:[NSNumber numberWithBool:isOn] forKey:@"user_auto_login_status"];
}
- (bool)isAutoLoginDisable {
    return [[self getObjectForKey:@"user_auto_login_status"] boolValue];
}

#pragma mark - City
- (bool)saveUserCityInfo:(NSDictionary*)cityInfo {
    return [self saveObject:cityInfo forKey:@"user_city_info"];
}

- (NSDictionary*)getUserCityInfo {
    return [self getObjectForKey:@"user_city_info"];
}

- (NSString*)getUserCityId {
    return [[self getUserCityInfo] objectForKey:@"city_id"];
}

#pragma mark - 定义一些便捷的getter
- (NSString*)getUserAccountName {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"user_login_name"];
}

- (NSString*)getUserPhoneNumber {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"user_phone"];
}

- (NSString*)getUserNickName {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"user_nick"];
}
- (NSString*)getUserAvatar {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"photo"];
}
- (NSString*)getUserCode {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"user_code"];
}
- (NSString*)getUserId {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"user_id"];
}

- (NSString*)getUserCost {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"cost"];
}

- (NSString*)getUserScore {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"score"];
}

- (NSString*)getUserInviteCode {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"invite_code"];
}

- (bool)isVip {
    return [[self getVipLevelId] integerValue] > 0;
}

- (NSString*)getVipLevelId {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"user_level"];
}

- (NSString*)getVipLevelName {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"user_level_name"];
}

- (NSString*)getVipDays {
    NSDictionary *uInfo = [self getAccountDetailInfo];
    if (!uInfo) {
        return nil;
    }
    return [uInfo objectForKey:@"level_day"];
}

- (NSArray*)getUserCarList {
    return [self getObjectForKey:@"user_car_list"];
}
- (NSArray*)getUserInvoiceList {
    return [self getObjectForKey:@"user_invocice_list"];
}
- (NSArray*)getUserAddressList {
    return [self getObjectForKey:@"user_address_list"];
}

#pragma mark - 定义一下便捷的setter
- (bool)saveUserNickName:(NSString*)userName {
    return [self setObjectForAccountDetailInfo:userName withKey:@"user_nick"];
}

- (bool)saveUserPhoneNumber:(NSString*)phoneNum {
    return [self setObjectForAccountDetailInfo:phoneNum withKey:@"user_phone"];
}

- (bool)saveUserAvatar:(NSString*)userAvatar {
    return [self setObjectForAccountDetailInfo:userAvatar withKey:@"photo"];
}

- (bool)saveUserVipLevelId:(NSString*)vipId {
    return [self setObjectForAccountDetailInfo:vipId withKey:@"user_level"];
}
- (bool)saveUserVipLevelName:(NSString*)vipName {
    return [self setObjectForAccountDetailInfo:vipName withKey:@"user_level_name"];
}
- (bool)saveUserVipLevelDays:(NSString*)vipDays {
    return [self setObjectForAccountDetailInfo:vipDays withKey:@"level_day"];
}

- (bool)saveUserCarList:(NSArray*)carList {
    if (!isValidArray(carList)) {
        return NO;
    }
    return [self saveObject:carList forKey:@"user_car_list"];
}
- (bool)saveUserInvoiceList:(NSArray*)invoiceList {
    if (!isValidArray(invoiceList)) {
        return NO;
    }
    return [self saveObject:invoiceList forKey:@"user_invocice_list"];
}
- (bool)saveUserAddressList:(NSArray*)addressList {
    if (!isValidArray(addressList)) {
        return NO;
    }
    return [self saveObject:addressList forKey:@"user_address_list"];
}

#pragma mark - 特殊方法
- (void)removeUserId {
    NSMutableDictionary *uInfo = [NSMutableDictionary dictionaryWithDictionary:[self getAccountDetailInfo]];
    if (!isValidDictionary(uInfo)) {
        return;
    }
    [uInfo removeObjectForKey:@"user_id"];
    [self saveAccountDetailInfo:uInfo];
}

@end
