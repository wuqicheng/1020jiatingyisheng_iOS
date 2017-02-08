//
//  THud.m
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/11/9.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import "THud.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
@interface THud ()

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) MBProgressHUD *tiphud;
@end

@implementation THud

+ (THud *)sharedInstance{
    static THud *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[THud alloc] init];
    });
    return instance;
}

-(id)init{
    self = [super init];
    if (self) {
        _hud = [[MBProgressHUD alloc] initWithWindow:[AppDelegate sharedDelegate].window ];
        _hud.labelFont = [UIFont systemFontOfSize:16];
        _hud.mode = MBProgressHUDModeIndeterminate;
        
        _tiphud = [[MBProgressHUD alloc] initWithWindow:[AppDelegate sharedDelegate].window];
        _tiphud.labelFont = [UIFont systemFontOfSize:12];
        _tiphud.mode = MBProgressHUDModeText;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)];
        [_tiphud addGestureRecognizer:tap];
        //        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHud)];
        //        [_hud addGestureRecognizer:ges];
        
    }
    return self;
}

-(void)hideHud{
    [_hud hide:YES];
    [_hud removeFromSuperview];
}

-(void)disPlayMessage:(NSString *)message{
    _hud.labelText = message;
    [_hud show:YES];
    [[AppDelegate sharedDelegate].window addSubview:_hud];
    //    [_hud hide:YES afterDelay:2.0];
}

-(void)showtips:(NSString *)message{
    _tiphud.labelText = message;
    [_tiphud removeFromSuperview];
    [[AppDelegate sharedDelegate].window addSubview:_tiphud];
    [_tiphud show:YES];
    [_tiphud hide:YES afterDelay:2];
}

-(void)hide:(UIGestureRecognizer *)ges{
    [_tiphud hide:YES];
}


@end
