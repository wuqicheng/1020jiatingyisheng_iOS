//
//  AppsEngine.h
//  HaoJieGPS
//
//  Created by Vescky on 13-6-18.
//  Copyright (c) 2013年 GDPU_DEV. All rights reserved.
//  服务器地址定义，在static.h

#import <Foundation/Foundation.h>
#import "MKNetworkKit.h"

typedef void (^JsonEngineBlock)(id jsonResponse);

@interface AppsNetWorkEngine : MKNetworkEngine

+ (id)shareEngine;


//发送自定义链接的请求，完整链接包括http开头
- (void)submitFullLinkRequest:(NSString*)url onCompletion:(JsonEngineBlock)completionBlock onError:(MKNKErrorBlock)errorBlock method:(NSString *)method ;

/* 发送请求到设定的服务器
 * action:请求的方法
 * param:请求的参数
 * completionBlock:请求完成的回调
 * errorBlock:请求失败的回调，服务器返回失败的状态码或者网络无链接
 * isDefaultErrorAlert: 是否自动显示默认的请求失败提示
 * isCacheNeeded: 设置是否需要缓存，此处提供一页的简易数据缓存，若有缓存，会马上返回缓存有的数据
 * method: http请求的方法，一般为 Get/POST
 */
- (id)submitRequest:(NSString*)action param:(NSMutableDictionary*)paramsDic onCompletion:(JsonEngineBlock)completionBlock onError:(MKNKErrorBlock)errorBlock defaultErrorAlert:(bool)isDefaultErrorAlert isCacheNeeded:(bool)isCacheNeeded method:(NSString *)method;

//上传图片 -- 自定义服务器
- (void)uploadImagePath:(NSString*)imgPath onCompletion:(JsonEngineBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;


//For Test
- (void)testUploadImage:(NSString*)imgName onCompletion:(JsonEngineBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;



@end
