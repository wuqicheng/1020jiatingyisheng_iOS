//
//  UserCollectionCell1.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/23.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewCell.h"

@interface UserCollectionCell1 : AppsBaseTableViewCell {
    IBOutlet UIImageView *imgvAvatar,*imgvStatus;
    IBOutlet UILabel *labelName,*labelContent,*labelTime;
    IBOutlet UIButton *phoneStatus;
}

@end
