//
//  UIView+RequestSingal.h
//  UI_10_1_UIWebView
//
//  Created by 3013 on 14-3-21.
//  Copyright (c) 2014年 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RequestSingal)

-(void)showWithTitle:(NSString *)string;
-(void)finished;

//数据请求失败时
- (void)showFailedLabel;

- (void)showAlertLabel:(NSString *)text height:(CGFloat)height view:(UIView *)targetView;

- (void)finishedAlertLabel:(UIView *)targetView;

//菊花器
- (void)showActivityIndicatorView:(BOOL)style;

- (void)finishedActivityIndicatorView;

- (void)refreshFaild:(CGRect)frame title:(NSString *)title;

- (void)removeRefreshFaild:(UIView *)view;

@end
