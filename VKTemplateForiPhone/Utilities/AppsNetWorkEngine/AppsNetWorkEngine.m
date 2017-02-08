//
//  AppsEngine.m
//  HaoJieGPS
//
//  Created by Vescky on 13-6-18.
//  Copyright (c) 2013年 GDPU_DEV. All rights reserved.
//

#import "AppsNetWorkEngine.h"
#import "Cache.h"
#import "AppDelegate.h"
#import "UserSessionCenter.h"

#define Default_Request_Methor @"POST"

@implementation AppsNetWorkEngine

AppsNetWorkEngine *appEngine;

//把字符串转换成json-object
- (NSDictionary *)toValue:(NSData *)json {
    NSString *str = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    str = [self stringByRemovingControlCharacters:str];
    
//    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    str = [str stringByReplacingOccurrencesOfString:@"\v" withString:@""];
//    str = [str stringByReplacingOccurrencesOfString:@"\f" withString:@""];
//    str = [str stringByReplacingOccurrencesOfString:@"\b" withString:@""];
//    str = [str stringByReplacingOccurrencesOfString:@"\a" withString:@""];
//    str = [str stringByReplacingOccurrencesOfString:@"\e" withString:@""];
    
    NSDictionary *resultDict;
    
    NSError *error;
    resultDict = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"#### Error--AppsEngine->toValue:%@",error);
    }
    if (!resultDict) {
        resultDict = [[NSDictionary alloc] init];
    }
    
    return resultDict;
}

///避免转义字符出问题
- (NSString *)stringByRemovingControlCharacters: (NSString *)inputString
{
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    NSRange range = [inputString rangeOfCharacterFromSet:controlChars];
    if (range.location != NSNotFound) {
        NSMutableString *mutable = [NSMutableString stringWithString:inputString];
        while (range.location != NSNotFound) {
            [mutable deleteCharactersInRange:range];
            range = [mutable rangeOfCharacterFromSet:controlChars];
        }
        return mutable;
    }
    return inputString;
}


+ (id)shareEngine {
    if (!appEngine) {
        appEngine = [[self alloc] initWithHostName:SERVER_DATA customHeaderFields:nil];
        [appEngine useCache];
    }
    return appEngine;
}

#pragma mark - 请求的方法
- (void)submitFullLinkRequest:(NSString*)url onCompletion:(JsonEngineBlock)completionBlock onError:(MKNKErrorBlock)errorBlock method:(NSString *)method {
    
    MKNetworkOperation *op = [self operationWithURLString:url params:nil httpMethod:method];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        NSData *responseData = [completedOperation responseData];
        completionBlock([self toValue:responseData]);
        
    } onError:^(NSError *error) {
        
        errorBlock(error);
    }];
    
    [self emptyCache];
    [self enqueueOperation:op];
}

//发送请求到设定的服务器 
- (id)submitRequest:(NSString*)action param:(NSMutableDictionary*)paramsDic onCompletion:(JsonEngineBlock)completionBlock onError:(MKNKErrorBlock)errorBlock defaultErrorAlert:(bool)isDefaultErrorAlert isCacheNeeded:(bool)isCacheNeeded method:(NSString *)method { NSLog(@"nihaoaaaa");
    
    NSString *storeKey = nil;
    if (isCacheNeeded) {
        storeKey = [NSString stringWithFormat:@"SimpleCacheForRequest-%@",action];
    }
    
    if (!method) {
        method = Default_Request_Methor;
    }
    
    //此部分是按需加上
    if (isValidString(ApplicationDelegate.sessionId)) {
        [paramsDic setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    
    MKNetworkOperation *op = [self operationWithPath:action params:paramsDic httpMethod:method];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        NSData *responseData = [completedOperation responseData];
        NSLog(@"%@",[completedOperation responseString]);
        if (isCacheNeeded) {
            //缓存
            NSDictionary *responseDic = [self toValue:responseData];
            [Cache save:responseDic key:storeKey];
        }
        completionBlock([self toValue:responseData]);
    } onError:^(NSError *error) {
        errorBlock(error);
        if (isDefaultErrorAlert) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"暂时无法连接到网络!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }];
    
    [self emptyCache];
    [self enqueueOperation:op];
    
    if (isCacheNeeded) {
        //读取缓存并返回
        return [Cache readByKey:storeKey];
    }
    
    return nil;
}

#pragma mark - 图片上传接口
- (void)uploadImagePath:(NSString*)imgPath onCompletion:(JsonEngineBlock)completionBlock onError:(MKNKErrorBlock)errorBlock {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    MKNetworkOperation *op = [self operationWithPath:@"fileuplaod.up" params:params httpMethod:@"POST"];
    [op addFile:imgPath forKey:@"file1" mimeType:@"multipart/form-data"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSData *responseData = [completedOperation responseData];
        completionBlock([self toValue:responseData]);
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
    
    [self enqueueOperation:op];
}

#pragma mark - Test
- (void)testUploadImage:(NSString*)imgName onCompletion:(JsonEngineBlock)completionBlock onError:(MKNKErrorBlock)errorBlock {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    MKNetworkOperation *op = [self operationWithPath:@"savePhotoCommit.pic" params:params httpMethod:@"POST"];
    [op addFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"testimg0.jpg"] forKey:@"photostream" mimeType:@"multipart/form-data"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSData *responseData = [completedOperation responseData];
        completionBlock([self toValue:responseData]);
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
    
    [self enqueueOperation:op];
}

@end
