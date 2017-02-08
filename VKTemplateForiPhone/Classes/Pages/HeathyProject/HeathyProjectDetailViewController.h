//
//  HeathyProjectDetailViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeathyProjectDetailViewController : AppsBaseViewController {
    IBOutlet UIWebView *wView;
}

@property (nonatomic,strong) NSString *planContent;

@end
