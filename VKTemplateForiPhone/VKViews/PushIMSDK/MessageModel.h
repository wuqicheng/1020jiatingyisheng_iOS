//
//  MessageModel.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/29.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject {
    
}

/*!
 @enum
 @brief 聊天类型
 @constant messageBodyType_Text 文本类型
 @constant messageBodyType_Image 图片类型
 @constant messageBodyType_Location 位置类型
 @constant messageBodyType_Voice 语音类型
 @constant messageBodyType_Video 视频类型
 @constant messageBodyType_File 文件类型
 @constant messageBodyType_Command 命令类型
 */
typedef NS_ENUM(NSInteger, MessageBodyType) {
    messageBodyType_Text = 1,
    messageBodyType_Image,
    messageBodyType_Location,
    messageBodyType_Voice,
    messageBodyType_Video,
    messageBodyType_File,
    messageBodyType_Command
};

/*!
 @enum
 @brief 聊天消息发送状态
 @constant messageDeliveryState_Pending 待发送
 @constant messageDeliveryState_Delivering 正在发送
 @constant messageDeliveryState_Delivered 已发送, 成功
 @constant messageDeliveryState_Failure 已发送, 失败
 */
typedef NS_ENUM(NSInteger, MessageDeliveryState) {
    messageDeliveryState_Pending = 0,
    messageDeliveryState_Delivering,
    messageDeliveryState_Delivered,
    messageDeliveryState_Failure
};

///对话id
@property (nonatomic,strong) NSString *conversationId;
///消息id
@property (nonatomic,strong) NSString *messageId;
///发送者
@property (nonatomic,strong) NSString *senderId;
///接受者
@property (nonatomic,strong) NSString *recieverId;
///对方的昵称
@property (nonatomic,strong) NSString *senderNickName;
///对方的头像
@property (nonatomic,strong) NSString *senderAvatar;
///发送时间
@property (nonatomic,strong) NSString *time;
///内容
@property (nonatomic,strong) NSString *messageContent;
///消息类型
@property MessageBodyType messageType;
///消息发送状态
@property MessageDeliveryState deliveryState;
///是否已读
@property bool isRead;
///是不是自己发出的
@property bool isSelfSender;
///是否显示时间
@property bool showsTime;
///附件，图像、音频、视频等
@property (nonatomic,strong) id attach;

- (MessageModel*)initWithJsonValue:(NSDictionary*)json;
- (NSDictionary*)toJsonValue;

@end
