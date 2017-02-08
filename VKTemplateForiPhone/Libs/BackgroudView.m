//
//  ZYBackgroudView.m
//  6diandan
//
//  Created by chinalong on 15/4/3.
//  Copyright (c) 2015年 forgtime. All rights reserved.
//

#import "BackgroudView.h"

@implementation BackgroudView
 static BackgroudView *instance=nil;
 static UIView *backgroudView =nil;
 static UIView *contentView;
+(BackgroudView*)shareInstance{
    if (instance==nil) {
        instance=[[BackgroudView alloc]init];
       
    }
    return instance;
}

- (void)tap:(UITapGestureRecognizer*)sender{
    if(contentView){
        backgroudView.hidden=YES;
        contentView.hidden=YES;
        [contentView removeFromSuperview];
        [backgroudView removeFromSuperview];
        contentView=nil;
        backgroudView=nil;
    }
  
    
    
}
- (void)addView:(UIView*)view andToView:(UIView*)superView{
     contentView=nil;
     contentView=view;
    backgroudView=nil;
    backgroudView=[[UIView alloc]init];
    backgroudView.backgroundColor=[UIColor blackColor];
    backgroudView.alpha=0.5f;
    backgroudView.frame=superView.frame;
    [superView addSubview:backgroudView];
     [superView addSubview:contentView];

    if ( backgroudView.gestureRecognizers.count==0) {
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        backgroudView.userInteractionEnabled=YES;
        [backgroudView addGestureRecognizer:tap];
    }
}

- (void)hide{
    if(contentView){
        backgroudView.hidden=YES;
        contentView.hidden=YES;
        [contentView removeFromSuperview];
        [backgroudView removeFromSuperview];
        contentView=nil;
        backgroudView=nil;
    }
}

- (void)setCenter{
    if (contentView) {
        contentView.center=backgroudView.center;
    }
}



@end
