//
//  MyActionSheetView.m
//  aixiche
//
//  Created by Vescky on 14-11-8.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "MyActionSheetView.h"

#define MyActionSheetView_Background_Tag 9999

@implementation MyActionSheetView
@synthesize delegate;

- (instancetype)initWithTitles:(NSArray*)titlesArray cancelButtonTitle:(NSString*)cancelButtonTitle {
    self = [self initWithFrame:[AppKeyWindow bounds]];
    if (self) {
        [self setUpViewWithTitles:titlesArray cancelButtonTitle:cancelButtonTitle];
    }
    return self;
}

- (instancetype)initWithPhotoSelectorStyle {
    self = [self initWithFrame:[AppKeyWindow bounds]];
    if (self) {
        [self setUpViewWithTitles:@[@"拍照",@"从手机相册选择"] cancelButtonTitle:@"取消"];
    }
    return self;
}

- (void)show {
    [AppKeyWindow addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}


#pragma mark - Private
- (void)setUpViewWithTitles:(NSArray*)titlesArray cancelButtonTitle:(NSString*)cancelButtonTitle {
    
    self.backgroundColor = [UIColor clearColor];
    
    //make a mask-view
    UIView *viewMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    viewMask.backgroundColor = [UIColor blackColor];
    viewMask.alpha = 0.6;
    [self addSubview:viewMask];
    
    //make up background responder
    UIButton *btnBackground = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBackground.backgroundColor = [UIColor clearColor];
    btnBackground.frame = CGRectMake(0, 0, viewMask.frame.size.width, viewMask.frame.size.height);
    btnBackground.tag = MyActionSheetView_Background_Tag;
    [btnBackground addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewMask addSubview:btnBackground];
    
    if (!isValidArray(titlesArray)) {
        return;
    }
    //make up container
    float containerHeight = (titlesArray.count + (isValidString(cancelButtonTitle) ? 1 : 0)) * 60.0f + 15.0f;
    UIView *viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, viewMask.frame.size.height - containerHeight, viewMask.frame.size.width, containerHeight)];
    viewContainer.backgroundColor = GetColorWithRGB(197.0, 197.0, 197.0);
    [self addSubview:viewContainer];
    
    for (int i = 0; i < titlesArray.count; i++) {
        NSString *btnTitle = [NSString stringWithFormat:@"%@",[titlesArray objectAtIndex:i]];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"btnn_light_gray.png"] forState:UIControlStateNormal];
        [btn setTitle:btnTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(20.0, 15.0 + 60.0 * i, viewContainer.frame.size.width - 20.0 * 2, 45.0);
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i + 1;
        [viewContainer addSubview:btn];
    }
    
    if (isValidString(cancelButtonTitle)) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_dark_gray.png"] forState:UIControlStateNormal];
        [btn setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(20.0, viewContainer.frame.size.height - 15.0 - 45.0, viewContainer.frame.size.width - 20.0 * 2, 45.0);
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 0;
        [viewContainer addSubview:btn];
    }
}

- (IBAction)btnAction:(UIButton*)sender {
    [self dismiss];
    if (sender.tag != MyActionSheetView_Background_Tag) {
        if ([delegate respondsToSelector:@selector(btnDidClick:)]) {
            [delegate btnDidClick:sender.tag];
        }
    }
}

@end
