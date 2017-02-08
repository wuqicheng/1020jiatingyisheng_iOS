//
//  ChatCell.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewCell.h"
#import "MessageModel.h"

@protocol ChatCellDelegate;

@interface ChatCell : AppsBaseTableViewCell {
    IBOutlet UILabel *labelContent,*labelTimestamp;
    IBOutlet UIImageView *imgvContent,*imgvAvatar,*imgvBubble;
    IBOutlet UIView *bubbleView;
    
}

@property (nonatomic,assign) id <ChatCellDelegate> delegate;

+ (CGFloat)getCellHeightWithDataInfo:(MessageModel *)msg;

- (void)setCellDataInfo:(MessageModel *)msg;

@end


@protocol ChatCellDelegate <NSObject>

- (void)chatCell:(ChatCell*)chatCell contentImageDidClick:(UIImageView*)imgv;

@end