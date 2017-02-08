//
//  ChatListCell.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewCell.h"

@interface ChatListCell : AppsBaseTableViewCell {
    IBOutlet UILabel *labelName,*labelTime;
    IBOutlet UIImageView *imgvAvatar;
    IBOutlet UIButton *btnState;
}

@end
