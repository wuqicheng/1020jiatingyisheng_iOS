//
//  CacheManager.h
//  aixiche
//
//  Created by Vescky on 14-11-6.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//  存放app一般信息的缓存

#import <Foundation/Foundation.h>

@interface CacheManager : NSObject

+ (id)defaultManager;

//缓存公司信息
- (void)saveCompanyInfo:(NSDictionary*)cInfo;
- (NSDictionary*)getCompanyInfo;

//所在城市
- (void)saveCurrentCityInfo:(NSDictionary*)cInfo;
- (NSDictionary*)getCurrentCityInfo;

//缓存新版本信息
- (void)saveNewVersionInfo:(NSDictionary*)newVersionInfo;
- (NSDictionary*)getNewVersionInfo;

//暂存推送通知
- (void)savePushMessageInfo:(NSDictionary*)mInfo;
- (NSDictionary*)getPushMessageInfo;
- (void)removePushMessageInfo;

- (void)setNeedToJumpToNotificationList:(NSDictionary*)info;
- (NSDictionary*)ifNeedToJumpToNotificationList;

@end
