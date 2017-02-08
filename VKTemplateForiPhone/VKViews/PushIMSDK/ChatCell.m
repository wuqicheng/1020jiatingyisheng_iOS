//
//  ChatCell.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "ChatCell.h"

#define TimestampMargin 20.f

@implementation ChatCell
@synthesize delegate;

+ (CGFloat)getCellHeightWithDataInfo:(MessageModel *)msg {
    CGFloat margin = 0.f,cellHeight;
    if (msg.showsTime) {
        margin = TimestampMargin;
    }
    
    if (msg.messageType == messageBodyType_Text && isValidString(msg.messageContent)) {
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        label1.font = [UIFont systemFontOfSize:14.f];
        
        CGSize textSize = getTextSizeForLabel(msg.messageContent, label1, 200.f, MAXFLOAT);
        cellHeight = textSize.height + 10.f + 18.f * 2 + margin;
    }
    else if (msg.messageType == messageBodyType_Image) {
        cellHeight = 200.f + 18.f * 2 + margin;
    }
    
    if (cellHeight < 66.f+margin) {
        cellHeight = 66.f+margin;
    }
    
    return cellHeight;
}

- (void)setCellDataInfo:(MessageModel *)msg{
    if (!msg) {
        return;
    }
    
    //头像
    imgvAvatar.layer.cornerRadius = imgvAvatar.frame.size.width / 2.f;
    if (msg.senderAvatar) {
        [imgvAvatar setImageURLStr:msg.senderAvatar placeholder:Defualt_Avatar_Image];
    }
    
    //消息类型
    if (msg.messageType == messageBodyType_Text) {
        imgvContent.hidden = YES;
        labelContent.hidden = NO;
        //set text
        labelContent.text = msg.messageContent;
        labelContent.lineBreakMode = NSLineBreakByCharWrapping;
        CGSize textSize = getTextSizeForLabel(msg.messageContent, labelContent, 200.f, MAXFLOAT);
        setViewFrameSizeHeight(bubbleView, textSize.height+10.f);
        setViewFrameSizeWidth(bubbleView, textSize.width+26.f);
    }
    else if (msg.messageType == messageBodyType_Image){
        imgvContent.hidden = NO;
        labelContent.hidden = YES;
        if (msg.attach) {
            [imgvContent setImage:(UIImage*)msg.attach];
        }
        else {
            [imgvContent setImageURLStr:getTransformImageLink(msg.messageContent, 50) placeholder:Defualt_Loading_Image];
        }
        
        setViewFrameSizeHeight(bubbleView, 200.f);
        setViewFrameSizeWidth(bubbleView, 200.f);
        
        //添加点击事件，放大图片
        imgvContent.userInteractionEnabled = YES;
        [imgvContent addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentImageViewDidClick:)]];
    }
    
    //是否显示时间
    if (msg.showsTime) {
        labelTimestamp.hidden = NO;
        labelTimestamp.text = getShortDateTimeForShow(msg.time);
        setViewFrameSizeHeight(self,bubbleView.frame.size.height + bubbleView.frame.origin.y*2 + TimestampMargin);
        setViewFrameOriginY(imgvAvatar, imgvAvatar.frame.origin.y + TimestampMargin);
        setViewFrameOriginY(bubbleView, bubbleView.frame.origin.y + TimestampMargin);
    }
    else {
        setViewFrameSizeHeight(self,bubbleView.frame.size.height + bubbleView.frame.origin.y*2);
    }
    
    //自己发的,改变layout
    if (msg.isSelfSender) {
        //头像靠右边
        float margin = 12.f;
        setViewFrameOriginX(imgvAvatar,self.frame.size.width - imgvAvatar.frame.size.width - margin);
        setViewFrameOriginX(bubbleView, imgvAvatar.frame.origin.x - bubbleView.frame.size.width - margin);
        [imgvBubble setImage:[[UIImage imageNamed:@"chat_dialogue_blue.png"] stretchableImageWithLeftCapWidth:10.f topCapHeight:30.f]];
        setViewFrameOriginX(labelContent, labelContent.frame.origin.x-3.f);
        
        setViewFrameOriginX(imgvContent, imgvContent.frame.origin.x-5.f);
    }
    else {
        [imgvBubble setImage:[[UIImage imageNamed:@"chat_dialogue_white.png"] stretchableImageWithLeftCapWidth:30.f topCapHeight:30.f]];
        setViewFrameOriginX(labelContent, labelContent.frame.origin.x+3.f);
    }
    
    
}

- (void)contentImageViewDidClick:(UITapGestureRecognizer *)tap {
    if ([delegate respondsToSelector:@selector(chatCell:contentImageDidClick:)]) {
        [delegate chatCell:self contentImageDidClick:imgvContent];
    }
}

@end
