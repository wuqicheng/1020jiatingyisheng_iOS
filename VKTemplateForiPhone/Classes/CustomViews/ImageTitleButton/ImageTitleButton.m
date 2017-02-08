//
//  ImageTitleButton.m
//  NanShaZhiChuang
//
//  Created by vescky.luo on 14-9-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "ImageTitleButton.h"

#define Margin 10.0f
#define Title_Font [UIFont systemFontOfSize:15.0]
#define Title_Color [UIColor blackColor]
#define Title_Height 30.0f

@interface ImageTitleButton() {
    UIButton *btnBackground,*btnForeground;//背景按钮，可设置状态颜色/图片
    UIImageView *imgvIcon;
    UILabel *labelTitle;
}

@end

@implementation ImageTitleButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        btnBackground = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBackground.backgroundColor = [UIColor clearColor];
        btnBackground.frame = CGRectMake(0, 0, [self viewWidth], [self viewHeight]);
        [self addSubview:btnBackground];
        
        imgvIcon = [[UIImageView alloc] initWithFrame:CGRectMake(Margin, Margin, [self viewWidth] - 2*Margin, [self viewHeight] - Title_Height - Margin)];
        imgvIcon.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imgvIcon];
        
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,[self viewHeight] - Title_Height , [self viewWidth], Title_Height)];
        labelTitle.font = Title_Font;
        labelTitle.textColor = Title_Color;
        [self addSubview:labelTitle];
        
        btnForeground = [UIButton buttonWithType:UIButtonTypeCustom];
        btnForeground.frame = CGRectMake(0, 0, [self viewWidth], [self viewHeight]);
        btnForeground.backgroundColor = [UIColor clearColor];
        [self addSubview:btnForeground];
        
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame Image:(UIImage*)image Title:(NSString*)sTitle {
    self = [self initWithFrame:frame];
    if (self) {
        imgvIcon.image = image;
        labelTitle.text = sTitle;
    }
    
    return self;
}

- (void)addTarget:(id)_target action:(SEL)_action forControlEvents:(UIControlEvents)controlEvents {
    [btnForeground addTarget:_target action:_action forControlEvents:controlEvents];
}

@end
