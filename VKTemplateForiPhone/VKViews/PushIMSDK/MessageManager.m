//
//  MessageManager.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/29.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "MessageManager.h"
#import "AppsNetWorkEngine.h"
#import "Cache.h"

@implementation MessageManager

+ (id)defaultManager {
    static MessageManager *messageManagerInstance;
    static dispatch_once_t onceMessageManager;
    dispatch_once(&onceMessageManager, ^{
        messageManagerInstance = [[self alloc] init];
    });
    
    return messageManagerInstance;
}

- (void)startUpByUserId:(NSString*)userId {
    self.userId = userId;
    [self checkRemoteNotificationIsOn];
}

- (void)haveA_Break {
    //暂停轮询
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkRemoteNotificationIsOn) object:nil];
}

- (void)checkRemoteNotificationIsOn {
    if (ios8OrLater()) {
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
            //推送关闭，采用轮询获取新消息
            [self checkNewMessage];
        }
    }
    else {
        if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
            //推送关闭，采用轮询获取新消息
            [self checkNewMessage];
        }
    }
    
    
    [self performSelector:@selector(checkRemoteNotificationIsOn) withObject:nil afterDelay:3*10];//30秒检查一次
}

///检查是否有新消息
- (void)checkNewMessage {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.userId,@"user_id", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getHasUserAllNotReadChartMsg.action" param:params onCompletion:^(id jsonResponse) {
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            if ([self.delegate respondsToSelector:@selector(messageMenagerDidRecieveNewMessages:)]) {
                [self.delegate messageMenagerDidRecieveNewMessages:[jsonResponse objectForKey:@"rows"]];
            }
        }
    } onError:^(NSError *error) {
        
    } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
}

///暂存聊天消息
- (void)saveNewChatMessage:(NSDictionary*)chatMessage {
    [Cache save:chatMessage key:@"MessageManagerNewChatMessage"];
}

- (NSDictionary*)getNewChatMessage {
    return [Cache readByKey:@"MessageManagerNewChatMessage"];
}

- (void)removeNewChatMessage {
    [Cache save:nil key:@"MessageManagerNewChatMessage"];
}

@end




