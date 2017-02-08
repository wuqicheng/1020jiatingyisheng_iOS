//
//  PhotoMessageDetailViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoMessageDetailViewController : AppsBaseViewController {
    IBOutlet UILabel *labelTitle,*labelTime;
    IBOutlet UIWebView *wView;
    IBOutlet UIScrollView *scView;
}

@property (nonatomic,strong) NSDictionary *detailInfo;

@end
