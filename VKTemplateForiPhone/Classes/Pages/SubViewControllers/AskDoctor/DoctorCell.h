//
//  DoctorCell.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/5.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewCell.h"

@interface DoctorCell : AppsBaseTableViewCell {
    IBOutlet UIImageView *imgvAvatar,*imgvStatus;
    IBOutlet UILabel *labelName,*labelContent;
    IBOutlet UIButton *phoneStatus;
    IBOutlet UIButton *yuyue;
}

@end
