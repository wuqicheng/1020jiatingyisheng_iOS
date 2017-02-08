//
//  SplashViewController.h
//  NanShaZhiChuang
//
//  Created by vescky.luo on 14-9-8.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : AppsBaseViewController {
    IBOutlet UIScrollView *scView;
    IBOutlet UIPageControl *pageControl;
}

- (IBAction)btnAction:(UIButton*)sender;

@end
