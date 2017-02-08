//
//  FreeSearchResultQACell.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/23.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewCell.h"

@interface FreeSearchResultQACell : AppsBaseTableViewCell {
    IBOutlet UILabel *labelQuestion,*labelAnswer;
    IBOutlet UIImageView *imgvTitle;
}
@property (weak, nonatomic) IBOutlet UIView *lineView;

- (float)getCellHeight:(NSDictionary*)data;

@end
