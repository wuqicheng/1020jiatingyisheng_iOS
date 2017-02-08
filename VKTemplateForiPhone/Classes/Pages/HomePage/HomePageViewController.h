//
//  HomePageViewController.h
//  VKTemplateForiPhone
//
//  Created by Vescky on 14/12/3.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKPhotosCycleView.h"
#import "ImageTitleButton.h"
#import "AppsBaseViewController.h"
#import"UIImageView+WebCache.h"
@interface HomePageViewController : AppsBaseViewController {
    IBOutlet VKPhotosCycleView *photoCycleView;
    IBOutlet UIView *titleView;
    IBOutlet UIScrollView *scView;
    ImageTitleButton *btn1,*btn2,*btn3,*btn4,*btn5;
    IBOutlet UIView *contentView;
}

@property (nonatomic,assign) bool disableRefresh,disableLoadMore;
@property (nonatomic,assign) bool isLastPage;
@property (nonatomic,strong) MJRefreshHeaderView *_header;
@property (nonatomic,strong) MJRefreshFooterView *_footer;

- (void)stopRefreshing;
- (IBAction)btnAction:(UIButton*)sender;
- (IBAction)menuAction:(UIButton*)sender;
- (IBAction)testAction:(UIButton*)sender;
@end