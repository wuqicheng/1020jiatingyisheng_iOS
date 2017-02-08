//
//  MessageModel.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/29.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel
@synthesize conversationId,messageId,messageContent,messageType,deliveryState,isRead,showsTime;
@synthesize senderId,recieverId,time,isSelfSender;
@synthesize senderAvatar,senderNickName;

- (id)copyWithZone:(NSZone *)zone {
    MessageModel *copy = [[MessageModel alloc] init];
    if (copy) {
        copy.conversationId = self.conversationId;
        copy.messageId = self.messageId;
        copy.messageContent = self.messageContent;
        copy.messageType = self.messageType;
        copy.deliveryState = self.deliveryState;
        copy.isRead = self.isRead;
        copy.senderId = self.senderId;
        copy.recieverId = self.recieverId;
        copy.time = self.time;
        copy.isSelfSender = self.isSelfSender;
        copy.senderAvatar = self.senderAvatar;
        copy.senderNickName = self.senderNickName;
        copy.showsTime = self.showsTime;
    }
    
    return copy;
}

- (MessageModel*)initWithJsonValue:(NSDictionary*)json {
    if (isValidDictionary(json)) {
        self.conversationId = [json objectForKey:@"conversation_id"];
        self.messageId = [json objectForKey:@"id"];
        self.messageContent = [json objectForKey:@"content"];
        self.messageType = [[json objectForKey:@"type"] integerValue];
        self.senderId = [json objectForKey:@"from_user_id"];
        self.recieverId = [json objectForKey:@"to_user_id"];
        self.time = [json objectForKey:@"time"];
        return self;
    }
    
    return nil;
}

- (NSDictionary*)toJsonValue {
    NSMutableDictionary *msgInfo = [[NSMutableDictionary alloc] init];
    if (self.conversationId) {
        [msgInfo setObject:self.conversationId forKey:@"conversation_id"];
    }
    if (self.messageId) {
        [msgInfo setObject:self.messageId forKey:@"message_id"];
    }
    if (self.messageType) {
        [msgInfo setObject:@(self.messageType) forKey:@"content_type"];
    }
    if (self.senderId) {
        [msgInfo setObject:self.senderId forKey:@"from_user_id"];
    }
    if (self.recieverId) {
        [msgInfo setObject:self.recieverId forKey:@"to_user_id"];
    }
    if (self.time) {
        [msgInfo setObject:self.time forKey:@"send_time"];
    }
    
    return msgInfo;
}

@end
