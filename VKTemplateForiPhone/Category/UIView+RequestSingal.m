//
//  UIView+RequestSingal.m
//  UI_10_1_UIWebView
//
//  Created by 3013 on 14-3-21.
//  Copyright (c) 2014年 Vincent. All rights reserved.
//

#import "UIView+RequestSingal.h"

@implementation UIView (RequestSingal)

-(void)showWithTitle:(NSString *)string{
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.layer.cornerRadius = 10;
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0.5;
    backView.tag = 1500;
    
    [self addSubview:backView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = string;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
    [backView addSubview:label];
    
    UIActivityIndicatorView *tip = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    tip.tag = 100;
    [backView addSubview:tip];
    
    backView.frame = CGRectMake(self.frame.size.width/2 - 50, self.frame.size.height/2-33, 100, 66);
    tip.frame = CGRectMake(28, 3, 44, 33);
    label.frame = CGRectMake(0, 33, 100, 33);
    
    [self bringSubviewToFront:backView];
    
    [tip startAnimating];
    
    
}

-(void)finished{
    
    UIActivityIndicatorView *tip = (UIActivityIndicatorView *)[self viewWithTag:100];
    [tip stopAnimating];
    [(UIView *)[self viewWithTag:1500] removeFromSuperview];
}


- (void)showFailedLabel
{
    UILabel *label = [[UILabel alloc ] initWithFrame:CGRectMake(0, (Screen_Height)/2, 320, 15)];
    label.text = @"请求失败，请重试!";
    label.tag = 101010;
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
}


- (void)showAlertLabel:(NSString *)text height:(CGFloat)height view:(UIView *)targetView;
{
    
    for(UIView *tempV in [targetView subviews])
    {
        if(tempV.tag == 987456)
        {
            [tempV removeFromSuperview];
            
            break;
        }
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, height, 320, 20)];
    label.text = text;
    label.tag = 987456;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    [targetView addSubview:label];

    
}

- (void)finishedAlertLabel:(UIView *)targetView
{
    for(UIView *tempV in [targetView subviews])
    {
        if(tempV.tag == 987456)
        {
            [tempV removeFromSuperview];
            
            break;
        }
    }

}

/*
 @overview: 开启菊花器
 */
- (void)showActivityIndicatorView:(BOOL)style
{
    
    for(UIActivityIndicatorView *ac in [self subviews])
    {
        if(ac.tag == 12345)
        {
            [ac stopAnimating];
            [ac removeFromSuperview];
        }
    }
    
    UIActivityIndicatorView *tip = [[UIActivityIndicatorView alloc] init];
    if(style)
    {
        tip.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    else
    {
        tip.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    tip.tag = 12345;
    tip.frame = CGRectMake((self.frame.size.width - 30)/2, (self.frame.size.height - 30)/2, 30, 30);
    [self addSubview:tip];

    [tip startAnimating];
}

/*
 @overview: 关闭菊花器
 */
- (void)finishedActivityIndicatorView
{
    UIActivityIndicatorView *tip = (UIActivityIndicatorView *)[self viewWithTag:12345];
    if(tip)
    {
        [tip stopAnimating];
        [tip removeFromSuperview];
    }
}

- (void)refreshFaild:(CGRect)frame title:(NSString *)title
{
    UILabel *backLabel = [[UILabel alloc] initWithFrame:frame];
    backLabel.backgroundColor = [UIColor blackColor];
    backLabel.alpha = 0.3;
    backLabel.tag = 32874;
    [self addSubview:backLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.tag = 32875;
    [self addSubview:titleLabel];
}

- (void)removeRefreshFaild:(UIView *)view
{
    for(UILabel *label in [view subviews])
    {
        if(label.tag == 32874 || label.tag ==  32875)
        {
            [label removeFromSuperview];
        }
    }
}

@end






