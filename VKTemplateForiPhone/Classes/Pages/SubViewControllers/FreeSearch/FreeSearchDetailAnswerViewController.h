//
//  FreeSearchDetailAnswerViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/19.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FreeSearchDetailAnswerViewController : AppsBaseViewController {
    IBOutlet UILabel *labelTitle;
    IBOutlet UIWebView *wView;
    IBOutlet UIView *contentView,*headerView;
    IBOutlet UIScrollView *scView;
}


@property (nonatomic,strong) NSDictionary *detailInfo;

@end
