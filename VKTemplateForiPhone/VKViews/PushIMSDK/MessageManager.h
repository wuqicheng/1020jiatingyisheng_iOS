//
//  MessageManager.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/29.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageModel.h"

//typedef void (^MessageManagerBlock)(id jsonRespond);
@protocol MessageManagerDelegate <NSObject>

- (void)messageMenagerDidRecieveNewMessages:(NSArray*)messages;

@end

@interface MessageManager : NSObject {
    //暂未启用验证机制
    NSString *userName,*userPassword;
    NSString *ticket;
}

@property (nonatomic,strong) NSString *userId;
@property (nonatomic,assign) id <MessageManagerDelegate> delegate;

///聊天SDK单例
+ (id)defaultManager;

- (void)startUpByUserId:(NSString*)userId;

- (void)haveA_Break;

///检查是否有新消息--轮询用
- (void)checkNewMessage;

///暂存聊天消息
- (void)saveNewChatMessage:(NSDictionary*)chatMessage;
- (NSDictionary*)getNewChatMessage;
- (void)removeNewChatMessage;


@end
