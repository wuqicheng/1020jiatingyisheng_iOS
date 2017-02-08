//
//  VIPPageViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VIPPageViewController : AppsBaseViewController {
    IBOutlet UILabel *labelTitle,*labelDays;
    IBOutlet UIButton *btnBuy;
}

- (IBAction)btnAction:(UIButton*)sender;

@end
