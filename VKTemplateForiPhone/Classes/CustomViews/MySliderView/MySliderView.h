//
//  MySliderView.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseView.h"

@protocol MySliderViewDelegate;

@interface MySliderView : AppsBaseView {
    UIButton *btnCursor;
    UIImageView *imgvForeground,*imgvBackground;
}

@property (nonatomic,assign) id <MySliderViewDelegate> delegate;
@property (nonatomic,assign) CGFloat currentPercentage;//小数

- (instancetype)initWithFrame:(CGRect)frame cursorImage:(UIImage*)cImg foregroundImage:(UIImage*)fImg backgroundImage:(UIImage*)bImg;

@end


@protocol MySliderViewDelegate <NSObject>

- (void)mySliderView:(MySliderView*)mySliderView valueDidChange:(CGFloat)percentage;
- (void)mySliderViewDidFinishDragging:(MySliderView*)mySliderView;

@end