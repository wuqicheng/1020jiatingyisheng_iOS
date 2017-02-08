//
//  CacheManager.m
//  aixiche
//
//  Created by Vescky on 14-11-6.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "CacheManager.h"
#import "Cache.h"

#define CacheManagerPath @"TTXICHECACHEMANAGER"

@implementation CacheManager
static CacheManager *ttxicheDefaultManager;

+ (id)defaultManager {
    if (!ttxicheDefaultManager) {
        ttxicheDefaultManager = [[CacheManager alloc] init];
    }
    return ttxicheDefaultManager;
}

//缓存公司信息
- (void)saveCompanyInfo:(NSDictionary*)cInfo {
    [Cache save:cInfo key:@"TTXICHE_COMPANY_INFO"];
}

- (NSDictionary*)getCompanyInfo {
    return [Cache readByKey:@"TTXICHE_COMPANY_INFO"];
}

//所在城市
- (void)saveCurrentCityInfo:(NSDictionary*)cInfo {
    [Cache save:cInfo key:@"CurrentCityInfo"];
}

- (NSDictionary*)getCurrentCityInfo {
    return [Cache readByKey:@"CurrentCityInfo"];
}

//缓存新版本信息
- (void)saveNewVersionInfo:(NSDictionary*)newVersionInfo {
    [Cache save:newVersionInfo key:@"newVersionInfo"];
}
- (NSDictionary*)getNewVersionInfo {
    return [Cache readByKey:@"newVersionInfo"];
}

//暂存推送通知
- (void)savePushMessageInfo:(NSDictionary*)mInfo {
    [Cache save:mInfo key:@"PushMessageInfo"];
}
- (NSDictionary*)getPushMessageInfo {
    return [Cache readByKey:@"PushMessageInfo"];
}

- (void)removePushMessageInfo {
    [Cache save:nil key:@"PushMessageInfo"];
}

- (void)setNeedToJumpToNotificationList:(NSDictionary*)info {
    [Cache save:info key:@"NeedToJumpToNotificationList"];
}

- (NSDictionary*)ifNeedToJumpToNotificationList {
    NSDictionary *info = [Cache readByKey:@"NeedToJumpToNotificationList"];
    [Cache save:nil key:@"NeedToJumpToNotificationList"];
    return info;
}

@end
