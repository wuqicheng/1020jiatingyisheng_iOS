//
//  FollowUpDetailViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowUpDetailViewController : AppsBaseViewController {
    IBOutlet UILabel *labelTitle,*labelTime;
    IBOutlet UIWebView *wView;
    IBOutlet UIView *viewForTime;
}

@property (nonatomic,strong) NSDictionary *detailInfo;

@end
