//
//  AppsBaseViewController.h
//  GDPU_Bible
//
//  Created by Vescky on 13-5-31.
//  Copyright (c) 2013年 gdpuDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsNetWorkEngine.h"
#import "MJRefresh.h"

@interface AppsBaseViewController : UIViewController<UITextFieldDelegate> {
    
}

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) bool disableRefresh,disableLoadMore;
@property (nonatomic,assign) bool isLastPage;
@property (nonatomic,strong) MJRefreshHeaderView *_header;
@property (nonatomic,strong) MJRefreshFooterView *_footer;


@property (nonatomic,strong) UILabel *noDataView;
@property (nonatomic,strong) UIView *viewForTextInput;
@property (nonatomic,strong) UITextField *textFieldForTextInput;

@property (nonatomic,assign) bool isTextInputViewOn;

//快速获取一些值
- (float)viewOriginX;
- (float)viewOriginY;
- (float)viewHeight;
- (float)viewWidth;

- (void)customBackButton;

- (void)customNavigationBarItemWithImageName:(NSString*)imgName isLeft:(bool)isLeft;
- (void)customNavigationBarItemWithTitleName:(NSString*)titleName isLeft:(bool)isLeft;

- (void)showNoData:(bool)showOn;
- (void)showNoDataWithTips:(NSString*)tipString;
- (void)nodataViewShowFrame:(CGRect)frame;

- (void)showAlertWithTitle:(NSString*)alertTitle message:(NSString*)alertMessage cancelButton:(NSString*)cancelButton sureButton:(NSString*)sureButton;
- (void)showAlertWithTitle:(NSString*)alertTitle message:(NSString*)alertMessage cancelButton:(NSString*)cancelButton sureButton:(NSString*)sureButton tag:(int)aTag;
- (void)showTextInputViewWithTag:(int)tTag defaultText:(NSString*)defaultText placeHolder:(NSString*)placeHolderText;//展示默认的输入框

///如果没有登录，就显示一个空白页+登录按钮
- (void)showLoginStyleIfNotLogged;

- (void)autoRecycleKeyboardBind:(UIView*)v;
- (void)stopRefreshing;

@end
